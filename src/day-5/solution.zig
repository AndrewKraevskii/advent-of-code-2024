const std = @import("std");

pub const Entry = extern struct {
    num: [2]u8,
    _: u8,

    pub fn format(value: Entry, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.print("{d}", .{value.num});
    }
};

pub fn solution1(alloc: std.mem.Allocator, text: []const u8) !u64 {
    const end = (std.mem.indexOf(u8, text, "\n\n") orelse return error.MalformedInput) + 1;
    const mapping = mapping: {
        const mapping = std.mem.bytesAsSlice([2]Entry, text[0..end]);

        const packed_mapping = try alloc.alloc(u32, mapping.len);
        for (packed_mapping, mapping) |*p, m| {
            p.* = @bitCast(m[0].num ++ m[1].num);
        }
        break :mapping try std.AutoArrayHashMapUnmanaged(u32, void).init(
            alloc,
            packed_mapping,
            undefined,
        );
    };
    var counter: u64 = 0;
    var pos = end + 1;
    outer: while (true) {
        const end_of_line = std.mem.indexOfScalarPos(u8, text, pos, '\n') orelse break;
        defer pos = end_of_line + 1;

        const list = std.mem.bytesAsSlice(Entry, text[pos .. end_of_line + 1]);
        for (list[0 .. list.len - 1], 1..) |first, index| {
            for (list[index..]) |second| {
                const entry: u32 = @bitCast(second.num ++ first.num);
                if (mapping.contains(entry)) {
                    continue :outer;
                }
            }
        }
        const middle = list[list.len >> 1].num;
        const digits: [2]u8 = middle;
        counter += 10 * (digits[0] - '0') + digits[1] - '0';
    }
    return counter;
}

pub fn solution2(_: std.mem.Allocator, _: []const u8) !u64 {}
