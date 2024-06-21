const testing = @import("std").testing;

inline fn shiftMask(number: anytype, comptime bytesShifted: u8) u8 {
    return @intCast((number >> 8 * bytesShifted) & 0xff);
}

pub fn bigEndU16(number: u16) [2]u8 {
    return .{ shiftMask(number, 1), shiftMask(number, 0) };
}

pub fn bigEndU32(number: u32) [4]u8 {
    return .{ shiftMask(number, 3), shiftMask(number, 2), shiftMask(number, 1), shiftMask(number, 0) };
}

pub fn bigEndU64(number: u64) [8]u8 {
    return .{ shiftMask(number, 7), shiftMask(number, 6), shiftMask(number, 5), shiftMask(number, 4),
        shiftMask(number, 3), shiftMask(number, 2), shiftMask(number, 1), shiftMask(number, 0) };
}

test "Test u16" {
    try testing.expectEqualSlices(u8, &[_]u8{ 0x10, 0xff }, &bigEndU16(0x10ff));
    try testing.expectEqualSlices(u8, &[_]u8{ 0, 0 }, &bigEndU16(0));
    try testing.expectEqualSlices(u8, &[_]u8{ 0xff, 0 }, &bigEndU16(0xff00));
}

test "Test u32" {
    try testing.expectEqualSlices(u8, &[_]u8{ 0x50, 0xa7, 0xc7, 0xdd }, &bigEndU32(0x50a7c7dd));
}

test "Test u64" {
    try testing.expectEqualSlices(u8, &[_]u8{ 0x05, 0x7d, 0xf3, 0xa0, 0x4b, 0xc7, 0x10, 0x34}, &bigEndU64(0x057df3a04bc71034));
}
