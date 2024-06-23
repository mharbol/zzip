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
