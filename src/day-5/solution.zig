const std = @import("std");

pub const Entry = extern struct {
    num: u16 align(1),
    _: u8,

    pub fn format(value: Entry, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.print("{d}", .{value.num});
    }
};

pub fn solution1(_: std.mem.Allocator, text: []const u8) !u64 {
    const end = (std.mem.indexOf(u8, text, "\n\n") orelse return error.MalformedInput) + 1;
    const mapping = std.mem.bytesAsSlice([2]Entry, text[0..end]);

    var counter: u64 = 0;
    var pos = end + 1;
    outer: while (true) {
        const end_of_line = std.mem.indexOfScalarPos(u8, text, pos, '\n') orelse break;
        defer pos = end_of_line + 1;

        const list = std.mem.bytesAsSlice(Entry, text[pos .. end_of_line + 1]);
        for (list[0 .. list.len - 1], 1..) |first, index| {
            for (list[index..]) |second| {
                for (mapping) |map| {
                    if (map[1].num == first.num and map[0].num == second.num) {
                        continue :outer;
                    }
                }
            }
        }
        // NOTE: If I move this line before for loop runtime gets flower by 30%.
        // But if measued using poop time is the same. It's really sus.
        const middle = list[list.len >> 1].num;
        const digits: [2]u8 = @bitCast(middle);
        counter += 10 * (digits[0] - '0') + digits[1] - '0';
    }
    return counter;
}

pub fn solution2(_: std.mem.Allocator, text: []const u8) !u64 {
    _ = text; // autofix
}
