const huffman = @import("huffman.zig");
const std = @import("std");
const queue = @import("priority_queue.zig");
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
    const node_cbe = try huffman.HuffmanTreeNode.combine(allocator, node_e, node_cb);
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

test "Test simple count bytes" {
    const data_out = huffman.countBytes("A_DEAD_DAD_CEDED_A_BAD_BABE_A_BEADED_ABACA_BED");
    try std.testing.expect(data_out['C'] == 2);
    try std.testing.expect(data_out['B'] == 6);
    try std.testing.expect(data_out['E'] == 7);
    try std.testing.expect(data_out['_'] == 10);
    try std.testing.expect(data_out['D'] == 10);
    try std.testing.expect(data_out['A'] == 11);
    try std.testing.expect(data_out['R'] == 0);
}

test "Test Priority Queue Functionality" {
    const node0 = try huffman.HuffmanTreeNode.init(allocator, 'A', 12);
    const node1 = try huffman.HuffmanTreeNode.init(allocator, 'B', 12);
    const node2 = try huffman.HuffmanTreeNode.init(allocator, 'C', 24);
    const node3 = try huffman.HuffmanTreeNode.init(allocator, 'D', 3);
    const node4 = try huffman.HuffmanTreeNode.init(allocator, 'E', 323);
    var pqueue = queue.NodePriorityQueue.init(allocator);

    defer {
        node0.deinit(allocator);
        node1.deinit(allocator);
        node2.deinit(allocator);
        node3.deinit(allocator);
        node4.deinit(allocator);
        pqueue.deinit();
    }

    try pqueue.push(node4);
    try pqueue.push(node3);
    try pqueue.push(node2);
    try pqueue.push(node1);
    try pqueue.push(node0);

    var next = pqueue.pop();
    try std.testing.expect(next.getByte() == 'D');
    next = pqueue.pop();
    try std.testing.expect(next.getByte() == 'A');
    next = pqueue.pop();
    try std.testing.expect(next.getByte() == 'B');
    next = pqueue.pop();
    try std.testing.expect(next.getByte() == 'C');
    next = pqueue.pop();
    try std.testing.expect(next.getByte() == 'E');
    try std.testing.expect(pqueue.len() == 0);
}
