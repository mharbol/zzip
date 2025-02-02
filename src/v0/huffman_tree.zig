const std = @import("std");
const queue = @import("priority_queue.zig");
const encoder = @import("byte_encoder.zig");
const encoding = @import("byte_encoding.zig");
const BitIterator = @import("bit_iterator.zig").BitIterator;

pub const HuffmanTreeNode = struct {
    left: ?*HuffmanTreeNode,
    right: ?*HuffmanTreeNode,
    count: usize,
    byte: u8,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, byte: u8, count: usize) !*HuffmanTreeNode {
        const huff_tree = try allocator.create(HuffmanTreeNode);
        huff_tree.allocator = allocator;
        huff_tree.byte = byte;
        huff_tree.count = count;
        huff_tree.left = null;
        huff_tree.right = null;
        return huff_tree;
    }

    pub fn deinit(self: *HuffmanTreeNode) void {
        if (self.left) |left| {
            left.deinit();
        }
        if (self.right) |right| {
            right.deinit();
        }
        self.allocator.destroy(self);
    }

    /// Combines two HuffmanTreeNodes as part of constructing the overall tree.
    pub fn combine(allocator: std.mem.Allocator, node0: *HuffmanTreeNode, node1: *HuffmanTreeNode) !*HuffmanTreeNode {
        // new node's byte is set to the lower of the two
        // the byte will be unique for each because each individual node at the start was made off of a unique byte
        var node_out = try HuffmanTreeNode.init(allocator, if (node0.byte < node1.byte) node0.byte else node1.byte, node0.count + node1.count);
        // left node is the lesser of the two as determined by compareTo().
        if (node0.compareTo(node1) < 0) {
            node_out.setLeft(node0);
            node_out.setRight(node1);
        } else {
            node_out.setLeft(node1);
            node_out.setRight(node0);
        }
        return node_out;
    }

    /// Compares only individual nodes for the sake of a priority queue and insertion.
    /// NOT for comparing whole trees
    pub fn compareTo(self: *HuffmanTreeNode, other: *HuffmanTreeNode) isize {
        var diff: isize = @intCast(self.count);
        diff -= @intCast(other.count);
        if (0 == diff) {
            diff = @intCast(self.byte);
            diff -= @intCast(other.byte);
        }
        return diff;
    }

    pub inline fn isLeafNode(self: *HuffmanTreeNode) bool {
        return null == self.left and null == self.right;
    }

    pub inline fn getByte(self: *HuffmanTreeNode) u8 {
        return self.byte;
    }

    pub inline fn getCount(self: *HuffmanTreeNode) usize {
        return self.count;
    }

    pub inline fn setLeft(self: *HuffmanTreeNode, left: *HuffmanTreeNode) void {
        self.left = left;
    }

    pub inline fn setRight(self: *HuffmanTreeNode, right: *HuffmanTreeNode) void {
        self.right = right;
    }

    pub inline fn getLeft(self: *HuffmanTreeNode) ?*HuffmanTreeNode {
        return self.left;
    }

    pub inline fn getRight(self: *HuffmanTreeNode) ?*HuffmanTreeNode {
        return self.right;
    }

    pub fn initTreeFromByteCount(allocator: std.mem.Allocator, array_in: [0x100]usize) !*HuffmanTreeNode {
        var pqueue = try queue.NodePriorityQueue.initFromByteCount(allocator, array_in);
        defer pqueue.deinit();
        errdefer pqueue.deinit();

        while (1 < pqueue.len()) {
            const node0 = pqueue.pop();
            const node1 = pqueue.pop();
            errdefer {
                node0.deinit();
                node1.deinit();
            }
            try pqueue.push(try combine(allocator, node0, node1));
        }
        return pqueue.pop();
    }

    pub fn getEncoder(self: *HuffmanTreeNode, allocator: std.mem.Allocator) !encoder.ByteEncoder {
        var encoder_out = encoder.ByteEncoder.init(allocator);
        errdefer encoder_out.deinit();
        try self.walkTreeWithEncoder(&encoder_out, 0, 0);
        return encoder_out;
    }

    /// Tree walk to get the full ByteEncoder.
    /// The bit sequence is the sequence that took place to get to the current working node.
    /// Similarly, the depth is the depth to get there.
    /// This means that both will be set by the recursive calls.
    fn walkTreeWithEncoder(self: *HuffmanTreeNode, enc_ptr: *encoder.ByteEncoder, bit_seq: u256, depth: u8) !void {
        // add encoding if at leaf node
        if (self.isLeafNode()) {
            try enc_ptr.putEncoding(encoding.ByteEncoding.new(self.getByte(), bit_seq, depth));
        } else {
            // recursive step, encode left and right nodes
            if (self.left) |left| {
                // left is 0 to the sequence
                const new_seq: u256 = bit_seq << 1;
                try left.walkTreeWithEncoder(enc_ptr, new_seq, depth + 1);
            }
            if (self.right) |right| {
                // right is 1 to the sequence
                const new_seq: u256 = (bit_seq << 1) | 1;
                try right.walkTreeWithEncoder(enc_ptr, new_seq, depth + 1);
            }
        }
    }

    /// Uses this tree to decode the encoded bytes.
    pub fn decodeBytes(self: *HuffmanTreeNode, allocator: std.mem.Allocator, encoded_bytes: []const u8, num_decoded: u64) !std.ArrayList(u8) {
        var arr_out = std.ArrayList(u8).init(allocator);
        errdefer arr_out.deinit();

        var iter = BitIterator.new(encoded_bytes);

        for (0..num_decoded) |_| {
            try arr_out.append(try self.decodeNextByte(&iter));
        }

        return arr_out;
    }

    fn decodeNextByte(self: *HuffmanTreeNode, iter: *BitIterator) !u8 {
        var curr_node = self;
        while (!curr_node.isLeafNode()) {
            if (iter.isNextBitOne()) {
                curr_node = curr_node.right.?;
            } else {
                curr_node = curr_node.left.?;
            }
        }
        return curr_node.getByte();
    }

    /// Serializes this tree in a consise way. The length of the output ArrayList will be needed in the
    /// tree's header to know when the output information starts.
    ///
    /// Each node is put into a "slot" which holds the node's information.
    /// Each new slot is appended to the end; its "address" is its offset from the start of the list
    ///
    /// If a node is a leaf node, the slot consists of two u16s: {1, <byte-contained-as-u16>}
    /// If a node is not a leaf node, the slot consists of three u16s: {0, <left-address>, <right-address>}
    pub fn serialize(self: *HuffmanTreeNode, allocator: std.mem.Allocator) !std.ArrayList(u16) {
        var arr_out = std.ArrayList(u16).init(allocator);
        errdefer arr_out.deinit();
        _ = try self.appendNode(&arr_out);
        return arr_out;
    }

    fn appendNode(self: *HuffmanTreeNode, arr: *std.ArrayList(u16)) !u16 {
        const address: u16 = @intCast(arr.items.len);

        if (self.isLeafNode()) {
            try arr.append(1);
            try arr.append(@intCast(self.getByte()));
        } else {
            try arr.append(0);
            try arr.append(0); // empty left
            try arr.append(0); // empty right
            const left_addr = try self.getLeft().?.appendNode(arr);
            const right_addr = try self.getRight().?.appendNode(arr);
            arr.items[address + 1] = left_addr;
            arr.items[address + 2] = right_addr;
        }
        return address;
    }

    pub fn deserialize(allocator: std.mem.Allocator, bytes: []const u8) !*HuffmanTreeNode {
        const arr_in = try u8ArrToU16Arr(allocator, bytes);
        defer arr_in.deinit();
        if (0 == arr_in.items[0]) {
            return try deserializeFork(allocator, arr_in.items, 0);
        } else {
            return try deserializeLeaf(allocator, arr_in.items, 0);
        }
    }

    /// New fork from arr_in
    /// Assumes idx points to a fork slot
    fn deserializeFork(allocator: std.mem.Allocator, arr_in: []const u16, idx: u16) !*HuffmanTreeNode {
        var node = try init(allocator, 0, 0);
        errdefer node.deinit();
        const left_addr = arr_in[idx + 1];
        const right_addr = arr_in[idx + 2];
        if (1 == arr_in[left_addr]) {
            node.setLeft(try deserializeLeaf(allocator, arr_in, left_addr));
        } else {
            node.setLeft(try deserializeFork(allocator, arr_in, left_addr));
        }
        if (1 == arr_in[right_addr]) {
            node.setRight(try deserializeLeaf(allocator, arr_in, right_addr));
        } else {
            node.setRight(try deserializeFork(allocator, arr_in, right_addr));
        }
        return node;
    }

    /// New leaf from the arr_in
    /// Assumes idx points to a leaf node slot
    inline fn deserializeLeaf(allocator: std.mem.Allocator, arr_in: []const u16, idx: u16) !*HuffmanTreeNode {
        return init(allocator, @truncate(arr_in[idx + 1]), 0);
    }

    pub fn u16ArrToU8Arr(allocator: std.mem.Allocator, arr_in: []const u16) !std.ArrayList(u8) {
        var arr_out = std.ArrayList(u8).init(allocator);
        errdefer arr_out.deinit();

        for (arr_in) |value| {
            try arr_out.append(@truncate(value >> 8));
            try arr_out.append(@truncate(value));
        }

        return arr_out;
    }

    fn u8ArrToU16Arr(allocator: std.mem.Allocator, arr_in: []const u8) !std.ArrayList(u16) {
        var arr_out = std.ArrayList(u16).init(allocator);
        errdefer arr_out.deinit();

        var first_byte: u8 = 0;
        for (arr_in, 0..) |byte, idx| {
            if (idx % 2 == 0) {
                first_byte = byte;
            } else {
                try arr_out.append((@as(u16, first_byte) << 8) | @as(u16, byte));
            }
        }

        return arr_out;
    }
};

test "Test All Huffman Tree" {
    _ = @import("huffman_tree_test.zig");
}
