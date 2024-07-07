const std = @import("std");
const ByteEncoding = @import("byte_encoding.zig").ByteEncoding;

/// Structure to encode bytes in accordance with the Huffman Tree.
pub const ByteEncoder = struct {
    allocator: std.mem.Allocator,
    map: std.AutoHashMap(u8, ByteEncoding),

    pub fn init(allocator: std.mem.Allocator) ByteEncoder {
        return .{
            .allocator = allocator,
            .map = std.AutoHashMap(u8, ByteEncoding).init(allocator),
        };
    }

    pub fn deinit(self: *ByteEncoder) void {
        self.map.deinit();
    }

    pub fn putEncoding(self: *ByteEncoder, encoding: ByteEncoding) !void {
        try self.map.put(encoding.byte, encoding);
    }

    pub fn getEncoding(self: *ByteEncoder, byte: u8) ?ByteEncoding {
        return self.map.get(byte);
    }
};

test "Test All Encoder" {
    _ = @import("byte_encoder_test.zig");
}
