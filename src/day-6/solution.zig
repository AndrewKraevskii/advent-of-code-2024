const std = @import("std");

pub fn solution1(_: std.mem.Allocator, text: []u8) !u64 {
    const width = std.mem.indexOfScalar(u8, text, '\n') orelse return error.NoLineBreak;
    const stride = width + 1; // +1 for \n

    var position: i16 = @intCast(std.mem.indexOfScalar(u8, text, '^') orelse return error.NoStartingPosition);

    const directions = [_]i16{
        -@as(i16, @intCast(stride)),
        1,
        @as(i16, @intCast(stride)),
        -1,
    };
    var current_direction_index: u2 = 0;

    var counter: usize = 0;
    outer: while (true) : (current_direction_index +%= 1) {
        const direction = directions[current_direction_index];

        while (true) : ({
            position += direction;
            if (position < 0 or position >= text.len) break :outer;
        }) {
            const char = &text[@intCast(position)];
            if (char.* == '#') {
                position -= direction;
                break;
            }
            if (char.* == '\n') break :outer;
            if (char.* != 'X') {
                counter += 1;
                char.* = 'X';
            }
        }
    }
    return counter;
}
