const std = @import("std");

/// Encoding of a specific byte to a bit sequence as determined
/// by the byte array's Huffman tree.
pub const ByteEncoding = struct {
    // the byte to encode
    byte: u8,

    // the bit sequence associated with said byte.
    // left node is 0, right node is 1.
    // pushed on bit_seq in the order the tree will be traversed.
    //
    // ex: if the tree goes left, right, right, left, right; the encoding is:
    // 0b000...01101
    //
    // The maximum Huffman tree depth (albeit very hard to do) for bytes
    // is 255 so 256 is the size of the bit sequence in this first iteration
    // of the application.
    bit_seq: u256,

    // number of bits which make up the sequence
    num_bits: u8,

    /// Creates a new instance of ByteEncoding.
    pub fn new(byte: u8, bit_sequence: u256, num_bits: u8) ByteEncoding {
        return .{
            .byte = byte,
            .bit_seq = bit_sequence,
            .num_bits = num_bits,
        };
    }

    /// Writes the byte encoding to an ArrayList based on the number of bits.
    /// Array out in order is {byte, num_bits, <bit sequence in as few bytes possible>...}
    ///
    /// The bit_seq bytes out will be ordered most significant bit byte first.
    ///
    /// So if num_bits = 9, bit_seq = 0b00...010110010, and byte = 12 the output would be:
    /// {0b00001100 (byte), 0b00001001 (num_bits), 0b00000000, 0b10110010 (bit_seq)}
    pub fn serialize(self: *const ByteEncoding, allocator: std.mem.Allocator) !std.ArrayList(u8) {
        var list_out = std.ArrayList(u8).init(allocator);
        errdefer list_out.deinit();

        try list_out.append(self.byte);
        try list_out.append(self.num_bits);

        // to avoid a lot of funky shifts, append 0 the-number-of-bytes-needed times
        // and then assign the bytes backwards
        // Number of bytes needed is ceiling(num_bits / 8)
        var num_bytes_needed: u8 = self.num_bits / 8;
        if (0 != self.num_bits % 8) {
            num_bytes_needed += 1;
        }
        for (0..num_bytes_needed) |_| {
            try list_out.append(0);
        }

        // assign backwards
        var seq = self.bit_seq;
        const idx_end = list_out.items.len - 1;
        for (0..num_bytes_needed) |idx_offset| {
            list_out.items[idx_end - idx_offset] = @truncate(seq);
            seq >>= 8;
        }

        return list_out;
    }
};

test "Test Encoder" {
    _ = @import("byte_encoding_test.zig");
}
