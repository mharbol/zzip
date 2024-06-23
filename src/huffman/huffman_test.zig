const huffman = @import("huffman.zig");
const std = @import("std");
const allocator = std.testing.allocator;

test "Test init Huff Tree" {
    const tree = try huffman.HuffmanTreeNode.init(allocator, 3, 0);
    defer tree.deinit(allocator);
    try std.testing.expect(tree.isLeafNode());
}

test "Test compareTo()" {
    const tree0 = try huffman.HuffmanTreeNode.init(allocator, 2, 9);
    const tree1 = try huffman.HuffmanTreeNode.init(allocator, 6, 9);
    const tree2 = try huffman.HuffmanTreeNode.init(allocator, 4, 14);
    const tree3 = try huffman.HuffmanTreeNode.init(allocator, 6, 9);
    defer {
        tree0.deinit(allocator);
        tree1.deinit(allocator);
        tree2.deinit(allocator);
        tree3.deinit(allocator);
    }
    try std.testing.expect(tree0.compareTo(tree1) == -4);
    try std.testing.expect(tree2.compareTo(tree3) == 5);
}

test "Test Combine two Leaves" {
    const node0 = try huffman.HuffmanTreeNode.init(allocator, 0, 4);
    const node1 = try huffman.HuffmanTreeNode.init(allocator, 1, 1);
    const combined = try huffman.HuffmanTreeNode.combine(allocator, node0, node1);
    defer {
        combined.deinit(allocator);
    }
    try std.testing.expect(combined.getByte() == 0);
    try std.testing.expect(combined.getCount() == 5);
    try std.testing.expect(combined.getLeft().?.getByte() == 1);
    try std.testing.expect(combined.getLeft().?.getCount() == 1);
    try std.testing.expect(combined.getRight().?.getByte() == 0);
    try std.testing.expect(combined.getRight().?.getCount() == 4);
}

test "Test Combine two Leaves with Same Count" {
    const node0 = try huffman.HuffmanTreeNode.init(allocator, 12, 50);
    const node1 = try huffman.HuffmanTreeNode.init(allocator, 34, 50);
    const combined = try huffman.HuffmanTreeNode.combine(allocator, node0, node1);
    defer {
        combined.deinit(allocator);
    }
    try std.testing.expect(combined.getByte() == 12);
    try std.testing.expect(combined.getCount() == 100);
    try std.testing.expect(combined.getLeft().?.getByte() == 12);
    try std.testing.expect(combined.getLeft().?.getCount() == 50);
    try std.testing.expect(combined.getRight().?.getByte() == 34);
    try std.testing.expect(combined.getRight().?.getCount() == 50);
}
