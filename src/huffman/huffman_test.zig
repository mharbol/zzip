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
    defer combined.deinit(allocator);
    try std.testing.expect(combined.getByte() == 12);
    try std.testing.expect(combined.getCount() == 100);
    try std.testing.expect(combined.getLeft().?.getByte() == 12);
    try std.testing.expect(combined.getLeft().?.getCount() == 50);
    try std.testing.expect(combined.getRight().?.getByte() == 34);
    try std.testing.expect(combined.getRight().?.getCount() == 50);
}

test "Test Combine with 3" {
    const node_c = try huffman.HuffmanTreeNode.init(allocator, 'C', 2);
    const node_b = try huffman.HuffmanTreeNode.init(allocator, 'B', 6);
    const node_e = try huffman.HuffmanTreeNode.init(allocator, 'E', 7);
    const node_cb = try huffman.HuffmanTreeNode.combine(allocator, node_c, node_b);
    var node_cbe = try huffman.HuffmanTreeNode.combine(allocator, node_e, node_cb);
    defer node_cbe.deinit(allocator);

    // root
    try std.testing.expect(!node_cbe.isLeafNode());
    try std.testing.expect(node_cbe.getByte() == 'B');
    try std.testing.expect(node_cbe.getCount() == 15);

    // left node off root (just E)
    try std.testing.expect(node_cbe.getLeft().?.isLeafNode());
    try std.testing.expect(node_cbe.getLeft().?.getByte() == 'E');
    try std.testing.expect(node_cbe.getLeft().?.getCount() == 7);

    // right node off root
    try std.testing.expect(!node_cbe.getRight().?.isLeafNode());
    try std.testing.expect(node_cbe.getRight().?.getByte() == 'B');
    try std.testing.expect(node_cbe.getRight().?.getCount() == 8);

    // left off right off root
    try std.testing.expect(node_cbe.getRight().?.getLeft().?.isLeafNode());
    try std.testing.expect(node_cbe.getRight().?.getLeft().?.getByte() == 'C');
    try std.testing.expect(node_cbe.getRight().?.getLeft().?.getCount() == 2);

    // right off right off root
    try std.testing.expect(node_cbe.getRight().?.getRight().?.isLeafNode());
    try std.testing.expect(node_cbe.getRight().?.getRight().?.getByte() == 'B');
    try std.testing.expect(node_cbe.getRight().?.getRight().?.getCount() == 6);
}
