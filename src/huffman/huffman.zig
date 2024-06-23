const std = @import("std");

pub const HuffmanTreeNode = struct {
    left: ?*HuffmanTreeNode,
    right: ?*HuffmanTreeNode,
    count: u32,
    byte: u8,

    pub fn init(allocator: std.mem.Allocator, byte: u8, count: u32) !*HuffmanTreeNode {
        const huff_tree = try allocator.create(HuffmanTreeNode);
        huff_tree.byte = byte;
        huff_tree.count = count;
        huff_tree.left = null;
        huff_tree.right = null;
        return huff_tree;
    }

    pub fn deinit(self: *HuffmanTreeNode, allocator: std.mem.Allocator) void {
        if (self.left) |left| {
            left.deinit(allocator);
        }
        if (self.right) |right| {
            right.deinit(allocator);
        }
        allocator.destroy(self);
    }

    pub fn compareTo(self: *HuffmanTreeNode, other: *HuffmanTreeNode) i32 {
        var diff: i32 = @intCast(self.count);
        diff -= @intCast(other.count);
        if (0 == diff) {
            diff = @intCast(self.byte);
            diff -= @intCast(other.byte);
        }
        return diff;
    }

    pub fn isLeafNode(self: *HuffmanTreeNode) bool {
        return null == self.left and null == self.right;
    }

    pub fn getByte(self: *HuffmanTreeNode) u8 {
        return self.byte;
    }

    pub fn setLeft(self: *HuffmanTreeNode, left: *HuffmanTreeNode) void {
        self.left = left;
    }

    pub fn setRight(self: *HuffmanTreeNode, right: *HuffmanTreeNode) void {
        self.right = right;
    }
};
