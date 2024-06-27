/// Encoding of a specific byte to a bit sequence as determined
/// by the byte array's Huffman tree.
pub const ByteEncoding = struct {
    // the byte to encode
    byte: u8,

    // the bit sequence associated with said byte (type subject to change)
    // left is 0, right is 1
    // pushed in in the order the tree will be traversed
    //
    // ex: if the tree goes left, right, right, left, right; the encoding is:
    // 0b000...01101
    bit_seq: u64,

    // number of bits which make up the sequence
    num_bits: u8,

    /// Creates a new instance of ByteEncoding.
    pub fn new(byte: u8, bit_sequence: u64, num_bits: u8) ByteEncoding {
        return .{
            .byte = byte,
            .bit_seq = bit_sequence,
            .num_bits = num_bits,
        };
    }
};
