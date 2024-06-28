const std = @import("std");
const rle = @import("rle.zig");

const allocator = std.testing.allocator;

// Encode tests
test "Basic RLE Encode Test" {
    const arr = [_]u8{ 1, 2, 3, 4, 5 };
    const actual: std.ArrayList(u8) = try rle.encodeSlice(allocator, &arr);
    defer actual.deinit();
    const expected = [_]u8{ 1, 1, 2, 1, 3, 1, 4, 1, 5, 1 };
    try std.testing.expectEqualSlices(u8, &expected, actual.items);
}

test "Singe Item Encode Test" {
    const arr = [_]u8{9};
    const actual: std.ArrayList(u8) = try rle.encodeSlice(allocator, &arr);
    defer actual.deinit();
    const expected = [_]u8{ 9, 1 };
    try std.testing.expectEqualSlices(u8, &expected, actual.items);
}

test "Simple RLE Encode Test" {
    const arr = [_]u8{ 1, 1, 1, 1, 2, 2, 2, 3, 4, 4, 5, 6, 7, 7 };
    const actual: std.ArrayList(u8) = try rle.encodeSlice(allocator, &arr);
    defer actual.deinit();
    const expected = [_]u8{ 1, 4, 2, 3, 3, 1, 4, 2, 5, 1, 6, 1, 7, 2 };
    try std.testing.expectEqualSlices(u8, &expected, actual.items);
}

test "Test Encode Greater than 255 RLE" {
    const arr = [_]u8{'a'} ** 260;
    const actual: std.ArrayList(u8) = try rle.encodeSlice(allocator, &arr);
    defer actual.deinit();
    const expected = [_]u8{ 'a', 255, 'a', 5 };
    try std.testing.expectEqualSlices(u8, &expected, actual.items);
}

test "Test Decode Exactly 254" {
    const arr = [_]u8{'f'} ++ [_]u8{'a'} ** 254 ++ "bc";
    const expected = [_]u8 {'f', 1, 'a', 254, 'b', 1, 'c', 1};
    const actual = try rle.encodeSlice(allocator, arr);
    defer actual.deinit();
    try std.testing.expectEqualSlices(u8, &expected, actual.items);
}

test "Test Decode Exactly 255" {
    const arr = [_]u8{'f'} ++ [_]u8{'a'} ** 255 ++ "bc";
    const expected = [_]u8 {'f', 1, 'a', 255, 'b', 1, 'c', 1};
    const actual = try rle.encodeSlice(allocator, arr);
    defer actual.deinit();
    try std.testing.expectEqualSlices(u8, &expected, actual.items);
}

test "Test Decode Exactly 256" {
    const arr = [_]u8{'f'} ++ [_]u8{'a'} ** 256 ++ "bc";
    const expected = [_]u8 {'f', 1, 'a', 255, 'a', 1, 'b', 1, 'c', 1};
    const actual = try rle.encodeSlice(allocator, arr);
    defer actual.deinit();
    try std.testing.expectEqualSlices(u8, &expected, actual.items);
}

// Decode tests
test "Test Basic Decode" {
    const arr = [_]u8{ 1, 1, 2, 2, 3, 3, 4, 4 };
    const actual: std.ArrayList(u8) = try rle.decodeSlice(allocator, &arr);
    defer actual.deinit();
    const expected = [_]u8{ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 };
    try std.testing.expectEqualSlices(u8, &expected, actual.items);
}

test "Test Decode Single Item" {
    const arr = [_]u8{ 5, 1 };
    const actual: std.ArrayList(u8) = try rle.decodeSlice(allocator, &arr);
    defer actual.deinit();
    const expected = [_]u8{5};
    try std.testing.expectEqualSlices(u8, &expected, actual.items);
}

test "Test Larger Decode" {
    const arr = [_]u8{ 12, 23, 34, 5, 2, 1, 0, 12, 3, 255, 3, 10, 4, 6 };
    const actual: std.ArrayList(u8) = try rle.decodeSlice(allocator, &arr);
    defer actual.deinit();
    const expected = [1]u8{12} ** 23 ++ [1]u8{34} ** 5 ++ [1]u8{2} ++ [1]u8{0} ** 12 ++ [1]u8{3} ** 265 ++ [1]u8{4} ** 6;
    try std.testing.expectEqualSlices(u8, &expected, actual.items);
}

// Encode/decode tests
test "Test Simple enc -> dec" {
    const original_arr = [_]u8{ 67, 67, 67, 3, 3, 5, 23, 23, 23, 4, 4, 2, 6, 12, 0, 0, 0, 0, 0, 12, 12, 2, 34, 4, 1, 5, 53, 44, 44, 44 };
    const encoded_arr = try rle.encodeSlice(allocator, &original_arr);
    const decoded_arr = try rle.decodeSlice(allocator, encoded_arr.items);
    defer {
        encoded_arr.deinit();
        decoded_arr.deinit();
    }
    try std.testing.expectEqualSlices(u8, &original_arr, decoded_arr.items);
}

test "Test Large enc -> dec" {
    const original_arr = [_]u8{ 1, 2, 3, 4 } ** 34 ++ [_]u8{56} ** 400 ++ [_]u8{5} ** 20 ++ [_]u8{ 234, 22, 54, 234 };
    const encoded_arr = try rle.encodeSlice(allocator, &original_arr);
    const decoded_arr = try rle.decodeSlice(allocator, encoded_arr.items);
    defer {
        encoded_arr.deinit();
        decoded_arr.deinit();
    }
    try std.testing.expectEqualSlices(u8, &original_arr, decoded_arr.items);
}
