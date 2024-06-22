const util = @import("util");

const HUFFMAN_FLAG: u8 = 1;
const RLE_FLAG: u8 = 1 << 1;

const Header = struct {
    version: u8,
    comp_flags: u8,
    tree_size: u16,

    fn new(compression_flags: u8, huffman_tree_size: u16) Header {
        return .{
            .version = 1,
            .comp_flags = compression_flags,
            .tree_size = huffman_tree_size,
        };
    }

    fn serialize(self: Header) [4]u8 {
        return self.version ++ self.comp_flags ++ util.bytes.bigEndU16(self.tree_size);
    }
};
