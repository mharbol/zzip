/// Really going off the beaten path with this one.
/// Iterates over the the individual bits so that the tree can decode a message easily.
///
/// Future versions will use an actual zig Iterator.

const std = @import("std");

pub const BitIterator = struct {
    bits_slice: []const u8,
    byte_idx: usize,
    bit_idx: u8,

    pub fn new(bits_slice: []const u8) BitIterator {
        return .{
            .bits_slice = bits_slice,
            .byte_idx = 0,
            .bit_idx = 7,
        };
    }

    pub fn isNextBitOne(self: *BitIterator) bool {
        const curr_byte = self.bits_slice[self.byte_idx];
        const is_one = ((curr_byte >> @intCast(self.bit_idx)) & 1) == 1;
        if (0 == self.bit_idx) {
            self.bit_idx = 7;
            self.byte_idx += 1;
        } else {
            self.bit_idx -= 1;
        }
        return is_one;
    }
};

test "Test Bit Iterator Next" {
    const bytes = [_]u8{ 0b01101010, 0b00101111, 0b10110010 };
    var iter = BitIterator.new(&bytes);

    // 0b01101010
    try std.testing.expect(!iter.isNextBitOne());
    try std.testing.expect(iter.isNextBitOne());
    try std.testing.expect(iter.isNextBitOne());
    try std.testing.expect(!iter.isNextBitOne());
    try std.testing.expect(iter.isNextBitOne());
    try std.testing.expect(!iter.isNextBitOne());
    try std.testing.expect(iter.isNextBitOne());
    try std.testing.expect(!iter.isNextBitOne());

    // 0b00101111
    try std.testing.expect(!iter.isNextBitOne());
    try std.testing.expect(!iter.isNextBitOne());
    try std.testing.expect(iter.isNextBitOne());
    try std.testing.expect(!iter.isNextBitOne());
    try std.testing.expect(iter.isNextBitOne());
    try std.testing.expect(iter.isNextBitOne());
    try std.testing.expect(iter.isNextBitOne());
    try std.testing.expect(iter.isNextBitOne());

    // 0b10110010
    try std.testing.expect(iter.isNextBitOne());
    try std.testing.expect(!iter.isNextBitOne());
    try std.testing.expect(iter.isNextBitOne());
    try std.testing.expect(iter.isNextBitOne());
    try std.testing.expect(!iter.isNextBitOne());
    try std.testing.expect(!iter.isNextBitOne());
    try std.testing.expect(iter.isNextBitOne());
    try std.testing.expect(!iter.isNextBitOne());
}
