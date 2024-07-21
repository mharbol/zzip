const std = @import("std");

pub const queue = @import("priority_queue.zig");
pub const tree = @import("huffman_tree.zig");
pub const encoding = @import("byte_encoding.zig");
pub const encoder = @import("byte_encoder.zig");

pub fn countBytes(data_in: []const u8) [0x100]usize {
    var bytes_count = [_]usize{0} ** 0x100;
    for (data_in) |value| {
        bytes_count[value] += 1;
    }
    return bytes_count;
}

test "Test All Huffman Tree" {
    _ = @import("huffman_tree.zig");
}

test "Test All Queue" {
    _ = @import("priority_queue.zig");
}

test "Test All Byte Encoding" {
    _ = @import("byte_encoding.zig");
}

test "Test All Byte Encoder" {
    _ = @import("byte_encoder.zig");
}

test "Test Bit Iterator" {
    _ = @import("bit_iterator.zig");
}
