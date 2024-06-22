const std = @import("std");

/// Returns the (non-standard) run length encoded version of the `data_in` slice.
/// For simplicity in looping, the encoding goes value then count.
/// Ex: {1, 1, 1} -> {3, 1}
/// Caller must deinit output ArrayList
pub fn encodeSlice(allocator: std.mem.Allocator, data_in: []const u8) !std.ArrayList(u8) {
    var rle_arr = std.ArrayList(u8).init(allocator);
    errdefer rle_arr.deinit();

    if (0 == data_in.len) {
        return rle_arr;
    }

    var count: u8 = 1;
    var last_val: u8 = data_in[0];

    try rle_arr.append(last_val);

    for (data_in[1..]) |value| {
        if (value != last_val) {
            try rle_arr.append(count);
            try rle_arr.append(value);
            count = 1;
            last_val = value;
        } else {
            if (0xff == count) {
                try rle_arr.append(count);
                try rle_arr.append(value);
                count = 1;
            } else {
                count += 1;
            }
        }
    }
    try rle_arr.append(count);

    return rle_arr;
}

/// Returns decoded version of `data_in` slice.
/// Caller must deinit output ArrayList
pub fn decodeSlice(allocator: std.mem.Allocator, data_in: []const u8) !std.ArrayList(u8) {
    var arr_out = std.ArrayList(u8).init(allocator);
    errdefer arr_out.deinit();
    if (0 == data_in.len) {
        return arr_out;
    }
    std.debug.assert(0 == data_in.len % 2);

    var entry_val: u8 = 0;

    for (data_in, 0..) |value, idx| {
        if (0 == idx % 2) {
            entry_val = value;
        } else {
            for (0..value) |_| {
                try arr_out.append(entry_val);
            }
        }
    }
    return arr_out;
}
