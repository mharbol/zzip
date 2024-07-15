const std = @import("std");
const tree = @import("huffman.zig").tree;

/// Purpose-built binary heap to order nodes while building the Huffman tree
pub const NodePriorityQueue = struct {
    heap: std.ArrayList(*tree.HuffmanTreeNode),

    pub fn init(allocator: std.mem.Allocator) NodePriorityQueue {
        return .{
            .heap = std.ArrayList(*tree.HuffmanTreeNode).init(allocator),
        };
    }

    pub fn deinit(self: NodePriorityQueue) void {
        for (self.heap.items) |item| {
            item.deinit();
        }
        self.heap.deinit();
    }

    pub fn push(self: *NodePriorityQueue, node: *tree.HuffmanTreeNode) !void {
        var idx = self.len();
        try self.heap.append(node);
        while (idx > 0 and self.heap.items[(idx - 1) / 2].compareTo(self.heap.items[idx]) > 0) {
            self.swap((idx - 1) / 2, idx);
            idx = (idx - 1) / 2;
        }
    }

    pub fn pop(self: *NodePriorityQueue) *tree.HuffmanTreeNode {
        const sz = self.len();
        const lowest = self.heap.items[0];
        self.heap.items[0] = self.heap.items[sz - 1];
        _ = self.heap.pop();
        self.heapify(0);
        return lowest;
    }

    pub inline fn len(self: *NodePriorityQueue) usize {
        return self.heap.items.len;
    }

    fn heapify(self: *NodePriorityQueue, idx: usize) void {
        const sz = self.len();

        if (sz <= 1) {
            return;
        }

        const leftIdx = idx * 2 + 1;
        const rightIdx = idx * 2 + 2;
        var smallestIdx = idx;

        if (leftIdx < sz and self.heap.items[leftIdx].compareTo(self.heap.items[smallestIdx]) < 0) {
            smallestIdx = leftIdx;
        }
        if (rightIdx < sz and self.heap.items[rightIdx].compareTo(self.heap.items[smallestIdx]) < 0) {
            smallestIdx = rightIdx;
        }

        if (smallestIdx != idx) {
            self.swap(idx, smallestIdx);
            self.heapify(smallestIdx);
        }
    }

    fn swap(self: *NodePriorityQueue, i: usize, j: usize) void {
        const temp = self.heap.items[i];
        self.heap.items[i] = self.heap.items[j];
        self.heap.items[j] = temp;
    }

    pub fn initFromByteCount(allocator: std.mem.Allocator, array_in: [0x100]usize) !NodePriorityQueue {
        var queue_out = NodePriorityQueue.init(allocator);
        errdefer queue_out.deinit();
        for (array_in, 0..) |value, idx| {
            if (value > 0) {
                try queue_out.push(try tree.HuffmanTreeNode.init(allocator, @intCast(idx), value));
            }
        }
        return queue_out;
    }
};

test "Test All Priority Queue" {
    _ = @import("priority_queue_test.zig");
}
