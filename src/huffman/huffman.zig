const std = @import("std");

pub const queue = @import("priority_queue.zig");
pub const tree = @import("huffman_tree.zig");

pub fn countBytes(data_in: []const u8) [0xff]usize {
    var bytes_count = [_]usize{0} ** 0xff;
    for (data_in) |value| {
        bytes_count[value] += 1;
    }
    return bytes_count;
}

test "Test All Huffman" {
    _ = @import("huffman_tree.zig");
}

test "Test All Queue" {
    _ = @import("priority_queue.zig");
}
