const std = @import("std");
const huffman = @import("huffman.zig");

/// Purpose-built binary heap to order nodes while building the Huffman tree
pub const NodePriorityQueue = struct {
    heap: std.ArrayList(*huffman.HuffmanTreeNode),

    pub fn init(allocator: std.mem.Allocator) NodePriorityQueue {
        return .{
            .heap = std.ArrayList(*huffman.HuffmanTreeNode).init(allocator),
        };
    }

    pub fn deinit(self: NodePriorityQueue) void {
        self.heap.deinit();
    }

    pub fn push(self: *NodePriorityQueue, node: *huffman.HuffmanTreeNode) !void {
        var idx = self.len();
        try self.heap.append(node);
        while (idx > 0 and self.heap.items[(idx - 1) / 2].compareTo(self.heap.items[idx]) > 0) {
            self.swap((idx - 1) / 2, idx);
            idx = (idx - 1) / 2;
        }
    }

    pub fn pop(self: *NodePriorityQueue) *huffman.HuffmanTreeNode {
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
};
