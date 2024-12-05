const std = @import("std");

fn startsWithStride(slice: []const u8, comptime needle: []const u8, start: usize, stride: isize) bool {
    var index: usize = 0;
    var pos: isize = @intCast(start);

    const Vec = @Vector(needle.len, u8);
    var vec: Vec = undefined;
    const needle_vec = @as(Vec, needle[0..needle.len].*);

    while (true) : ({
        index += 1;
        if (index >= needle.len) return @reduce(.And, needle_vec == vec);
        pos += stride;
        if (pos < 0 or pos >= slice.len) return false;
    }) {
        vec[index] = slice[@intCast(pos)];
    }
}

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
    for (0..text.len) |start| {
        for (strides) |s| {
            if (startsWithStride(text, "XMAS", start, s))
                counter += 1;
        }
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
            const center_of_xmas: isize = @intCast(stride * start_y + start_x);
            for (strides) |s| {
                const start_of_mas = center_of_xmas - s;
                if (start_of_mas < 0 or start_of_mas >= text.len) continue;
                mases_in_x += @intFromBool(startsWithStride(
                    text,
                    "MAS",
                    @intCast(start_of_mas),
                    s,
                ));
            }

            counter += @intFromBool(mases_in_x == 2);
        }
    }

    return counter;
}
