const std = @import("std");
const huffman = @import("huffman.zig");
const allocator = @import("std").testing.allocator;

const example_bytes = "A_DEAD_DAD_CEDED_A_BAD_BABE_A_BEADED_ABACA_BED";

test "Test Encode Bytes" {
    const array_in = huffman.countBytes(example_bytes);
    const tree = try huffman.tree.HuffmanTreeNode.initTreeFromByteCount(allocator, array_in);
    var enc = try tree.getEncoder(allocator);
    const bits_out = try enc.encodeBytes(allocator, example_bytes);

    defer {
        tree.deinit();
        enc.deinit();
        bits_out.deinit();
    }
    const expected = [_]u8{ 0b10010011, 0b01000010, 0b01000011, 0b11011000, 0b11000011, 0b00111111,
                            0b00001111, 0b11011111, 0b10011001, 0b11111101, 0b00011000, 0b01101111,
                            0b10111010, 0b01111111, 0b00000000};
    try std.testing.expectEqualSlices(u8, &expected, bits_out.items);
}
