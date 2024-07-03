const std = @import("std");
const queue = @import("priority_queue.zig");

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
    pub fn compareTo(self: *HuffmanTreeNode, other: *HuffmanTreeNode) i32 {
        var diff: i32 = @intCast(self.count);
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

    pub fn initTreeFromByteCount(allocator: std.mem.Allocator, array_in: [0xff]usize) !*HuffmanTreeNode {
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
};

test "Test All Huffman Tree" {
    _ = @import("huffman_tree_test.zig");
}
