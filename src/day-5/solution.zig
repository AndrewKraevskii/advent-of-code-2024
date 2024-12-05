const std = @import("std");

pub const Entry = extern struct {
    num: [2]u8,
    _: u8,

    pub fn format(value: Entry, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.print("{d}", .{value.num});
    }
};

pub fn parseNum(num: [4]u8) u16 {
    return (@as(u16, (num[0] - '0')) * 10 +
        num[1] - '0') * 100 +
        (num[2] - '0') * 10 +
        num[3] - '0';
}

pub fn solution1(_: std.mem.Allocator, text: []const u8) !u64 {
    const end = (std.mem.indexOf(u8, text, "\n\n") orelse return error.MalformedInput) + 1;
    const mapping = mapping: {
        var bools: [100 * 100]bool = @splat(false);
        const mapping = std.mem.bytesAsSlice([2]Entry, text[0..end]);

        for (mapping) |entry| {
            const num = parseNum(entry[0].num ++ entry[1].num);
            bools[num] = true;
        }
        break :mapping bools;
    };

    var counter: u64 = 0;
    var pos = end + 1;

    outer: while (true) {
        const end_of_line = std.mem.indexOfScalarPos(u8, text, pos, '\n') orelse break;
        defer pos = end_of_line + 1;

        const list = std.mem.bytesAsSlice(Entry, text[pos .. end_of_line + 1]);
        for (list[0 .. list.len - 1], 1..) |first, index| {
            for (list[index..]) |second| {
                const entry: u32 = parseNum(second.num ++ first.num);
                if (mapping[entry]) {
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

pub fn solution2(_: std.mem.Allocator, text: []const u8) !u64 {
    const end = (std.mem.indexOf(u8, text, "\n\n") orelse return error.MalformedInput) + 1;
    const mapping = mapping: {
        var bools: [100 * 100]bool = @splat(false);
        const mapping = std.mem.bytesAsSlice([2]Entry, text[0..end]);

        for (mapping) |entry| {
            const num = parseNum(entry[0].num ++ entry[1].num);
            bools[num] = true;
        }
        break :mapping bools;
    };

    var counter: u64 = 0;
    var pos = end + 1;

    var bounded_array = std.BoundedArray([2]u8, 100){};
    while (true) {
        const end_of_line = std.mem.indexOfScalarPos(u8, text, pos, '\n') orelse break;
        defer pos = end_of_line + 1;

        const entries = std.mem.bytesAsSlice(Entry, text[pos .. end_of_line + 1]);
        bounded_array.clear();
        for (entries) |entry| {
            try bounded_array.append(entry.num);
        }

        const list = bounded_array.slice();
        not_sorted: {
            for (list[0 .. list.len - 1], 1..) |first, index| {
                for (list[index..]) |second| {
                    const entry: u32 = parseNum(second ++ first);
                    if (mapping[entry]) {
                        break :not_sorted;
                    }
                }
            }
            continue;
        }
        std.mem.sortUnstable(
            [2]u8,
            list,
            mapping,
            struct {
                fn lessThan(m: @TypeOf(mapping), lhs: [2]u8, rhs: [2]u8) bool {
                    const entry: u32 = parseNum(rhs ++ lhs);
                    return m[entry];
                }
            }.lessThan,
        );

        const middle = list[list.len >> 1];
        const digits: [2]u8 = middle;
        counter += 10 * (digits[0] - '0') + digits[1] - '0';
    }
    return counter;
}
