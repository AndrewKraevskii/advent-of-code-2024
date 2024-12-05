const std = @import("std");

pub fn solution1(_: std.mem.Allocator, text: []const u8) !u64 {
    const width = std.mem.indexOfScalar(u8, text, '\n') orelse return error.NoLineBreak;

    const stride = width + 1; // +1 for \n
    const strides = [_]isize{
        1,
        -1,
        @as(isize, @intCast(stride)),
        @as(isize, @intCast(stride + 1)),
        @as(isize, @intCast(stride - 1)),
        -@as(isize, @intCast(stride)),
        -@as(isize, @intCast(stride + 1)),
        -@as(isize, @intCast(stride - 1)),
    };
    var counter: u64 = 0;
    for (strides) |s| {
        counter += countText(text, "XMAS", s);
    }
    return counter;
}

fn containsStride(slice: []const u8, needle: []const u8, start: usize, stride: isize) bool {
    var index: usize = 0;
    var pos: isize = @intCast(start);
    while (true) : ({
        index += 1;
        if (index >= needle.len) return true;
        pos += stride;
        if (pos < 0 or pos >= slice.len) return false;
    }) {
        if (needle[index] != slice[@intCast(pos)]) return false;
    }
}

fn countText(slice: []const u8, needle: []const u8, stride: isize) u64 {
    var counter: u64 = 0;
    for (0..slice.len) |start| {
        if (containsStride(slice, needle, start, stride))
            counter += 1;
    }
    return counter;
}

pub fn solution2(_: std.mem.Allocator, text: []const u8) !u64 {
    const width = std.mem.indexOfScalar(u8, text, '\n') orelse return error.NoLineBreak;
    const height = std.mem.count(u8, text, "\n");

    const stride = width + 1; // +1 for \n
    const strides = [_]isize{
        @as(isize, @intCast(stride + 1)),
        @as(isize, @intCast(stride - 1)),
        -@as(isize, @intCast(stride + 1)),
        -@as(isize, @intCast(stride - 1)),
    };

    var counter: usize = 0;
    for (1..width - 1) |start_x| {
        for (1..height - 1) |start_y| {
            var mases_in_x: u2 = 0;
            for (strides) |s| {
                const start: isize = @intCast(stride * start_y + start_x);
                const offseted_start = start - s;
                if (offseted_start < 0 or offseted_start >= text.len) continue;
                mases_in_x += @intFromBool(containsStride(
                    text,
                    "MAS",
                    @intCast(offseted_start),
                    s,
                ));
            }

            counter += @intFromBool(mases_in_x == 2);
        }
    }

    return counter;
}
