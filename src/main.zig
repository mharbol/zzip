const std = @import("std");
const rle = @import("rle");
const util = @import("util");

pub fn main() !void {
    std.debug.print("{any}\n", .{util.bytes.bigEndU16(0x10ff)});
    std.debug.print("{any}\n", .{util.bytes.bigEndU32(0x10ff)});
    std.debug.print("{any}\n", .{util.bytes.bigEndU64(0x10ff)});

    var arr = [_]u8{ 1, 2, 3 };
    for (&arr) |*val| {
        val.* = 3;
    }

    var x: u8 = 8;
    x *%= 99;
    std.debug.print("{}\n", .{x});

    var i: u8 = 0;
    while (i < 10) : (i += 1) {
        std.debug.print("{} ", .{i});
    }
    std.debug.print("\n", .{});

    const big : u256 = 34;
    std.debug.print("{} - {}\n", .{big, @sizeOf(@TypeOf(big))});
}
