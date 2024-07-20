const std = @import("std");
const allocator = std.testing.allocator;

const encoder = @import("byte_encoding.zig");

test "Test Serialize 1" {
    const enc = encoder.ByteEncoding.new('A', 0b100110110010, 12);
    const out = try enc.serialize(allocator);
    defer out.deinit();
    const expected = [_]u8{ 'A', 12, 0b00001001, 0b10110010 };
    try std.testing.expectEqualSlices(u8, &expected, out.items);
}

test "Test Serialize 2" {
    const enc = encoder.ByteEncoding.new('B', 0b10010110, 8);
    const out = try enc.serialize(allocator);
    defer out.deinit();
    const expected = [_]u8{ 'B', 8, 0b10010110 };
    try std.testing.expectEqualSlices(u8, &expected, out.items);
}

test "Test Serialize 3" {
    const enc = encoder.ByteEncoding.new('C', 0b10010110, 16);
    const out = try enc.serialize(allocator);
    defer out.deinit();
    const expected = [_]u8{ 'C', 16, 0, 0b10010110 };
    try std.testing.expectEqualSlices(u8, &expected, out.items);
}

test "Test Serialize 4" {
    const enc = encoder.ByteEncoding.new('D', 0b00010110, 6);
    const out = try enc.serialize(allocator);
    defer out.deinit();
    const expected = [_]u8{ 'D', 6, 0b010110 };
    try std.testing.expectEqualSlices(u8, &expected, out.items);
}

test "Test Bit is One A" {
    const enc = encoder.ByteEncoding.new('A', 0b00110010, 6);
    try std.testing.expect(enc.isBitOneAtIdx(0));
    try std.testing.expect(enc.isBitOneAtIdx(1));
    try std.testing.expect(!enc.isBitOneAtIdx(2));
    try std.testing.expect(!enc.isBitOneAtIdx(3));
    try std.testing.expect(enc.isBitOneAtIdx(4));
    try std.testing.expect(!enc.isBitOneAtIdx(5));
}

test "Test Bit is One B" {
    const enc = encoder.ByteEncoding.new('B', 0b10011011001100, 14);
    try std.testing.expect(enc.isBitOneAtIdx(0));
    try std.testing.expect(!enc.isBitOneAtIdx(1));
    try std.testing.expect(!enc.isBitOneAtIdx(2));
    try std.testing.expect(enc.isBitOneAtIdx(3));
    try std.testing.expect(enc.isBitOneAtIdx(4));
    try std.testing.expect(!enc.isBitOneAtIdx(5));
    try std.testing.expect(enc.isBitOneAtIdx(6));
    try std.testing.expect(enc.isBitOneAtIdx(7));
    try std.testing.expect(!enc.isBitOneAtIdx(8));
    try std.testing.expect(!enc.isBitOneAtIdx(9));
    try std.testing.expect(enc.isBitOneAtIdx(10));
    try std.testing.expect(enc.isBitOneAtIdx(11));
    try std.testing.expect(!enc.isBitOneAtIdx(12));
    try std.testing.expect(!enc.isBitOneAtIdx(13));
}
