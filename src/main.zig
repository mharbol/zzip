const std = @import("std");
const util = @import("util");
const rle = @import("rle");

pub fn main() !void {
    std.debug.print("{any}\n", .{util.bigEndU16(0x10ff)});
    std.debug.print("{any}\n", .{util.bigEndU32(0x10ff)});
    std.debug.print("{any}\n", .{util.bigEndU64(0x10ff)});

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
}
