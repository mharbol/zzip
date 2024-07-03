const std = @import("std");
const huffman = @import("huffman.zig");
const queue = @import("priority_queue.zig");

const allocator = std.testing.allocator;

test "Test Priority Queue Functionality" {
    const node0 = try huffman.tree.HuffmanTreeNode.init(allocator, 'A', 12);
    const node1 = try huffman.tree.HuffmanTreeNode.init(allocator, 'B', 12);
    const node2 = try huffman.tree.HuffmanTreeNode.init(allocator, 'C', 24);
    const node3 = try huffman.tree.HuffmanTreeNode.init(allocator, 'D', 3);
    const node4 = try huffman.tree.HuffmanTreeNode.init(allocator, 'E', 323);
    var pqueue = queue.NodePriorityQueue.init(allocator);

    defer {
        node0.deinit();
        node1.deinit();
        node2.deinit();
        node3.deinit();
        node4.deinit();
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

test "Test Priority Queue With Trees and Leaves" {
    const node0 = try huffman.tree.HuffmanTreeNode.init(allocator, 'A', 3);
    const node1 = try huffman.tree.HuffmanTreeNode.init(allocator, 'B', 32);
    const node2 = try huffman.tree.HuffmanTreeNode.init(allocator, 'C', 25);
    const node3 = try huffman.tree.HuffmanTreeNode.init(allocator, 'D', 66);
    const node4 = try huffman.tree.HuffmanTreeNode.init(allocator, 'E', 6);
    const node5 = try huffman.tree.HuffmanTreeNode.init(allocator, 'F', 200);
    const node6 = try huffman.tree.HuffmanTreeNode.init(allocator, 'G', 100);
    const node7 = try huffman.tree.HuffmanTreeNode.init(allocator, 'H', 100);

    // byte: A, count: 35
    var node8 = try huffman.tree.HuffmanTreeNode.combine(allocator, node0, node1);
    // byte: G, count: 200
    var node9 = try huffman.tree.HuffmanTreeNode.combine(allocator, node6, node7);

    var pqueue = queue.NodePriorityQueue.init(allocator);

    try pqueue.push(node2);
    try pqueue.push(node3);
    try pqueue.push(node4);
    try pqueue.push(node5);
    try pqueue.push(node8);
    try pqueue.push(node9);

    defer {
        pqueue.deinit();
        node2.deinit();
        node3.deinit();
        node4.deinit();
        node5.deinit();
        node8.deinit();
        node9.deinit();
    }

    var next = pqueue.pop();
    try std.testing.expectEqual('E', next.getByte());
    try std.testing.expectEqual(6, next.getCount());
    try std.testing.expectEqual(5, pqueue.len());

    next = pqueue.pop();
    try std.testing.expectEqual('C', next.getByte());
    try std.testing.expectEqual(25, next.getCount());
    try std.testing.expectEqual(4, pqueue.len());

    next = pqueue.pop();
    try std.testing.expectEqual('A', next.getByte());
    try std.testing.expectEqual(35, next.getCount());
    try std.testing.expectEqual(3, pqueue.len());

    next = pqueue.pop();
    try std.testing.expectEqual('D', next.getByte());
    try std.testing.expectEqual(66, next.getCount());
    try std.testing.expectEqual(2, pqueue.len());

    next = pqueue.pop();
    try std.testing.expectEqual('F', next.getByte());
    try std.testing.expectEqual(200, next.getCount());
    try std.testing.expectEqual(1, pqueue.len());

    next = pqueue.pop();
    try std.testing.expectEqual('G', next.getByte());
    try std.testing.expectEqual(200, next.getCount());
    try std.testing.expectEqual(0, pqueue.len());
}

