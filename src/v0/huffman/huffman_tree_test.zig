const std = @import("std");
const huffman = @import("huffman.zig");
const queue = @import("priority_queue.zig");
const encoder = @import("byte_encoder.zig");

const allocator = std.testing.allocator;

test "Test init Huff Tree" {
    const tree = try huffman.tree.HuffmanTreeNode.init(allocator, 3, 0);
    defer tree.deinit();
    try std.testing.expect(tree.isLeafNode());
}

test "Test compareTo()" {
    const tree0 = try huffman.tree.HuffmanTreeNode.init(allocator, 2, 9);
    const tree1 = try huffman.tree.HuffmanTreeNode.init(allocator, 6, 9);
    const tree2 = try huffman.tree.HuffmanTreeNode.init(allocator, 4, 14);
    const tree3 = try huffman.tree.HuffmanTreeNode.init(allocator, 6, 9);
    defer {
        tree0.deinit();
        tree1.deinit();
        tree2.deinit();
        tree3.deinit();
    }
    try std.testing.expect(tree0.compareTo(tree1) == -4);
    try std.testing.expect(tree2.compareTo(tree3) == 5);
}

test "Test Combine two Leaves" {
    const node0 = try huffman.tree.HuffmanTreeNode.init(allocator, 0, 4);
    const node1 = try huffman.tree.HuffmanTreeNode.init(allocator, 1, 1);
    const combined = try huffman.tree.HuffmanTreeNode.combine(allocator, node0, node1);
    defer combined.deinit();

    try std.testing.expect(combined.getByte() == 0);
    try std.testing.expect(combined.getCount() == 5);
    try std.testing.expect(combined.getLeft().?.getByte() == 1);
    try std.testing.expect(combined.getLeft().?.getCount() == 1);
    try std.testing.expect(combined.getRight().?.getByte() == 0);
    try std.testing.expect(combined.getRight().?.getCount() == 4);
}

test "Test Combine two Leaves with Same Count" {
    const node0 = try huffman.tree.HuffmanTreeNode.init(allocator, 12, 50);
    const node1 = try huffman.tree.HuffmanTreeNode.init(allocator, 34, 50);
    const combined = try huffman.tree.HuffmanTreeNode.combine(allocator, node0, node1);
    defer combined.deinit();
    try std.testing.expect(combined.getByte() == 12);
    try std.testing.expect(combined.getCount() == 100);
    try std.testing.expect(combined.getLeft().?.getByte() == 12);
    try std.testing.expect(combined.getLeft().?.getCount() == 50);
    try std.testing.expect(combined.getRight().?.getByte() == 34);
    try std.testing.expect(combined.getRight().?.getCount() == 50);
}

test "Test Combine with 3" {
    const node_c = try huffman.tree.HuffmanTreeNode.init(allocator, 'C', 2);
    const node_b = try huffman.tree.HuffmanTreeNode.init(allocator, 'B', 6);
    const node_e = try huffman.tree.HuffmanTreeNode.init(allocator, 'E', 7);
    const node_cb = try huffman.tree.HuffmanTreeNode.combine(allocator, node_c, node_b);
    const node_cbe = try huffman.tree.HuffmanTreeNode.combine(allocator, node_e, node_cb);
    defer node_cbe.deinit();

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
    try std.testing.expect(data_out['_'] == 10);
    try std.testing.expect(data_out['A'] == 11);
    try std.testing.expect(data_out['B'] == 6);
    try std.testing.expect(data_out['C'] == 2);
    try std.testing.expect(data_out['D'] == 10);
    try std.testing.expect(data_out['E'] == 7);
    try std.testing.expect(data_out['R'] == 0);
}

test "Test Byte Count To Queue" {
    const array_in = huffman.countBytes("A_DEAD_DAD_CEDED_A_BAD_BABE_A_BEADED_ABACA_BED");
    var pqueue = try queue.NodePriorityQueue.initFromByteCount(allocator, array_in);
    defer pqueue.deinit();

    var next = pqueue.pop();
    try std.testing.expectEqual('C', next.getByte());
    try std.testing.expectEqual(2, next.getCount());
    next.deinit();

    next = pqueue.pop();
    try std.testing.expectEqual('B', next.getByte());
    try std.testing.expectEqual(6, next.getCount());
    next.deinit();

    next = pqueue.pop();
    try std.testing.expectEqual('E', next.getByte());
    try std.testing.expectEqual(7, next.getCount());
    next.deinit();

    next = pqueue.pop();
    try std.testing.expectEqual('D', next.getByte());
    try std.testing.expectEqual(10, next.getCount());
    next.deinit();

    next = pqueue.pop();
    try std.testing.expectEqual('_', next.getByte());
    try std.testing.expectEqual(10, next.getCount());
    next.deinit();

    next = pqueue.pop();
    try std.testing.expectEqual('A', next.getByte());
    try std.testing.expectEqual(11, next.getCount());
    next.deinit();

    try std.testing.expectEqual(0, pqueue.len());
}

test "Test Construct Tree from Byte Count" {
    const array_in = huffman.countBytes("A_DEAD_DAD_CEDED_A_BAD_BABE_A_BEADED_ABACA_BED");
    const tree = try huffman.tree.HuffmanTreeNode.initTreeFromByteCount(allocator, array_in);
    // should be a tree that looks like this:
    //               46
    //              /  \
    //             /    \
    //            20     \
    //           /  \     \
    //       D(10)  _(10)  \
    //                     26
    //                    /  \
    //                A(11)  15
    //                       / \
    //                   E(7)   8
    //                         / \
    //                     C(2)   B(6)
    defer tree.deinit();

    try std.testing.expectEqual(46, tree.getCount());
    try std.testing.expect(!tree.isLeafNode());

    try std.testing.expectEqual(20, tree.getLeft().?.getCount());
    try std.testing.expect(!tree.getLeft().?.isLeafNode());

    try std.testing.expectEqual(10, tree.getLeft().?.getLeft().?.getCount());
    try std.testing.expectEqual('D', tree.getLeft().?.getLeft().?.getByte());
    try std.testing.expect(tree.getLeft().?.getLeft().?.isLeafNode());

    try std.testing.expectEqual(10, tree.getLeft().?.getRight().?.getCount());
    try std.testing.expectEqual('_', tree.getLeft().?.getRight().?.getByte());
    try std.testing.expect(tree.getLeft().?.getRight().?.isLeafNode());

    try std.testing.expectEqual(26, tree.getRight().?.getCount());
    try std.testing.expect(!tree.getRight().?.isLeafNode());

    try std.testing.expectEqual(11, tree.getRight().?.getLeft().?.getCount());
    try std.testing.expectEqual('A', tree.getRight().?.getLeft().?.getByte());
    try std.testing.expect(tree.getRight().?.getLeft().?.isLeafNode());

    try std.testing.expectEqual(15, tree.getRight().?.getRight().?.getCount());
    try std.testing.expect(!tree.getRight().?.getRight().?.isLeafNode());

    try std.testing.expectEqual(7, tree.getRight().?.getRight().?.getLeft().?.getCount());
    try std.testing.expectEqual('E', tree.getRight().?.getRight().?.getLeft().?.getByte());
    try std.testing.expect(tree.getRight().?.getRight().?.getLeft().?.isLeafNode());

    try std.testing.expectEqual(8, tree.getRight().?.getRight().?.getRight().?.getCount());
    try std.testing.expect(!tree.getRight().?.getRight().?.getRight().?.isLeafNode());

    try std.testing.expectEqual(2, tree.getRight().?.getRight().?.getRight().?.getLeft().?.getCount());
    try std.testing.expectEqual('C', tree.getRight().?.getRight().?.getRight().?.getLeft().?.getByte());
    try std.testing.expect(tree.getRight().?.getRight().?.getRight().?.getLeft().?.isLeafNode());

    try std.testing.expectEqual(6, tree.getRight().?.getRight().?.getRight().?.getRight().?.getCount());
    try std.testing.expectEqual('B', tree.getRight().?.getRight().?.getRight().?.getRight().?.getByte());
    try std.testing.expect(tree.getRight().?.getRight().?.getRight().?.getRight().?.isLeafNode());
}

test "Test Build Encoder" {
    const array_in = huffman.countBytes("A_DEAD_DAD_CEDED_A_BAD_BABE_A_BEADED_ABACA_BED");
    const tree = try huffman.tree.HuffmanTreeNode.initTreeFromByteCount(allocator, array_in);
    var enc = try tree.getEncoder(allocator);

    defer {
        tree.deinit();
        enc.deinit();
    }

    try std.testing.expectEqual(6, enc.map.count());

    try std.testing.expectEqual('A', enc.getEncoding('A').?.byte);
    try std.testing.expectEqual(0b10, enc.getEncoding('A').?.bit_seq);
    try std.testing.expectEqual(2, enc.getEncoding('A').?.num_bits);

    try std.testing.expectEqual('B', enc.getEncoding('B').?.byte);
    try std.testing.expectEqual(0b1111, enc.getEncoding('B').?.bit_seq);
    try std.testing.expectEqual(4, enc.getEncoding('B').?.num_bits);

    try std.testing.expectEqual('C', enc.getEncoding('C').?.byte);
    try std.testing.expectEqual(0b1110, enc.getEncoding('C').?.bit_seq);
    try std.testing.expectEqual(4, enc.getEncoding('C').?.num_bits);

    try std.testing.expectEqual('D', enc.getEncoding('D').?.byte);
    try std.testing.expectEqual(0b00, enc.getEncoding('D').?.bit_seq);
    try std.testing.expectEqual(2, enc.getEncoding('D').?.num_bits);

    try std.testing.expectEqual('E', enc.getEncoding('E').?.byte);
    try std.testing.expectEqual(0b110, enc.getEncoding('E').?.bit_seq);
    try std.testing.expectEqual(3, enc.getEncoding('E').?.num_bits);

    try std.testing.expectEqual('_', enc.getEncoding('_').?.byte);
    try std.testing.expectEqual(0b01, enc.getEncoding('_').?.bit_seq);
    try std.testing.expectEqual(2, enc.getEncoding('_').?.num_bits);
}

test "Test Decode Bytes" {
    const example_bytes = "A_DEAD_DAD_CEDED_A_BAD_BABE_A_BEADED_ABACA_BED";
    const array_in = huffman.countBytes(example_bytes);
    const tree = try huffman.tree.HuffmanTreeNode.initTreeFromByteCount(allocator, array_in);
    const bits_in = [_]u8{ 0b10010011, 0b01000010, 0b01000011, 0b11011000, 0b11000011, 0b00111111,
                            0b00001111, 0b11011111, 0b10011001, 0b11111101, 0b00011000, 0b01101111,
                            0b10111010, 0b01111111, 0b00000000 };
    const bytes_out = try tree.decodeBytes(allocator, &bits_in, @intCast(example_bytes.len));
    defer {
        tree.deinit();
        bytes_out.deinit();
    }

    try std.testing.expectEqualSlices(u8, example_bytes, bytes_out.items);
}
