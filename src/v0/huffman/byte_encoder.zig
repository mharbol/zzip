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

    /// Bare-bones way to pack the bit representation from the encoding onto the serialized form.
    /// Pushes the bits onto the working byte literally bit by bit.
    /// Going with this approach just to get it working, will improve this process in future versions
    /// of the application.
    pub fn encodeBytes(self: *ByteEncoder, allocator: std.mem.Allocator, bytes: []const u8) !std.ArrayList(u8) {
        var arr_out = std.ArrayList(u8).init(allocator);
        errdefer arr_out.deinit();

        // the next byte to get the bits from the encoding and be pushed onto arr_out
        var working_byte: u8 = 0;

        // index of the bit to be pushed onto the working byte (least significant on the right)
        var bit_idx: isize = 7;

        // loop over all bytes and encode
        const ONE: u8 = 1;
        for (bytes) |byte| {
            // good with the ? operator since this is only used by an encoder made from the Huffman tree.
            const encoding = self.getEncoding(byte).?;
            for (0..encoding.num_bits) |bit_number| {
                // make sure working byte is good at each iteration
                if (0 > bit_idx) {
                    bit_idx = 7;
                    try arr_out.append(working_byte);
                    working_byte = 0;
                }

                // encode a 1 or 0 and step back bit idx by one
                if (encoding.isBitOneAtIdx(@intCast(bit_number))) {
                    working_byte = working_byte | (ONE << @intCast(bit_idx));
                }
                bit_idx -= 1;
            }
        }
        // tack on the working byte
        // since the working_byte is updated and appended only at the start of an iteration, it will
        // always have ncessary information.
        try arr_out.append(working_byte);
        return arr_out;
    }
};

test "Test All Encoder" {
    _ = @import("byte_encoder_test.zig");
}
