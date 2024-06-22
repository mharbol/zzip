const std = @import("std");
const rle = @import("rle.zig");

const allocator = std.testing.allocator;
 
test "Basic RLE Test" {
    const arr = [5]u8{ 1, 2, 3, 4, 5 };
    const actual: std.ArrayList(u8) = try rle.rleEncodeSlice(allocator, &arr);
    defer actual.deinit();
    const expected = [10]u8{ 1, 1, 2, 1, 3, 1, 4, 1, 5, 1 };
    try std.testing.expectEqualSlices(u8, &expected, actual.items);
}

test "Singe item Test" {
    const arr = [1]u8{9};
    const actual: std.ArrayList(u8) = try rle.rleEncodeSlice(allocator, &arr);
    defer actual.deinit();
    const expected = [2]u8{ 9, 1 };
    try std.testing.expectEqualSlices(u8, &expected, actual.items);
}

test "Simple RLE Test" {
    const arr = [14]u8{ 1, 1, 1, 1, 2, 2, 2, 3, 4, 4, 5, 6, 7, 7 };
    const actual: std.ArrayList(u8) = try rle.rleEncodeSlice(allocator, &arr);
    defer actual.deinit();
    const expected = [14]u8{ 1, 4, 2, 3, 3, 1, 4, 2, 5, 1, 6, 1, 7, 2 };
    try std.testing.expectEqualSlices(u8, &expected, actual.items);
}

test "Test Greater than 255 RLE" {
    const arr: [260]u8 = [1]u8{'a'} ** 260;
    const actual: std.ArrayList(u8) = try rle.rleEncodeSlice(allocator, &arr);
    defer actual.deinit();
    const expected = [4]u8{'a', 255, 'a',  5};
    try std.testing.expectEqualSlices(u8, &expected, actual.items);
}
