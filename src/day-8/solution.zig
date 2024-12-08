const std = @import("std");

const Vec = @Vector(2, u8);

fn addDiff(from: Vec, torwards: Vec, size: Vec) ?Vec {
    const res, const overflow = @subWithOverflow(torwards + torwards, from);
    if (@reduce(.Or, overflow != @as(Vec, @splat(0))) or
        @reduce(.Or, res >= size)) return null;

    return res;
}

fn setAntinode(slice: []u8, pos: Vec, counter: *usize, stride: usize) void {
    const char = &slice[pos[0] + pos[1] * stride];
    if (char.* != '#') {
        counter.* += 1;
        char.* = '#';
    }
}

fn solution(comptime part: u1, arena: std.mem.Allocator, text: []const u8) !u64 {
    const result = try arena.dupe(u8, text);

    const width = std.mem.indexOfScalar(u8, text, '\n') orelse return error.NoLineBreak;
    const height = std.mem.count(u8, text, "\n");
    const size: Vec = .{ @intCast(width), @intCast(height) };

    const stride = width + 1;

    var frequencies: std.BoundedArray(u8, 0x26) = .{};
    var positions: std.BoundedArray(std.BoundedArray(Vec, 4), 0x26) = .{};
    for (text, 0..) |char, position| {
        if (char == '.' or char == '\n') continue;
        const index = if (std.mem.indexOfScalar(u8, frequencies.slice(), char)) |index| index else blk: {
            try frequencies.append(char);
            try positions.append(.{});
            break :blk positions.len - 1;
        };

        try positions.slice()[index].append(.{ @intCast(position % stride), @intCast(position / stride) });
    }

    var counter: usize = 0;
    for (positions.slice()) |tl| {
        const tower_locations = tl.slice();

        for (tower_locations[0 .. tower_locations.len - 1], 0..) |start, start_index| {
            for (tower_locations[start_index + 1 ..]) |end| {
                inline for (.{ .{ start, end }, .{ end, start } }) |points| {
                    if (part == 0) {
                        if (addDiff(points[0], points[1], size)) |pos| {
                            setAntinode(result, pos, &counter, stride);
                        }
                    } else {
                        // cover antennas
                        setAntinode(result, points[0], &counter, stride);

                        // rest of line
                        var from = points[0];
                        var to = points[1];
                        while (addDiff(from, to, size)) |pos| : ({
                            from = to;
                            to = pos;
                        }) {
                            setAntinode(result, pos, &counter, stride);
                        }
                    }
                }
            }
        }
    }

    return counter;
}

pub fn solution1(arena: std.mem.Allocator, text: []const u8) !u64 {
    return solution(0, arena, text);
}

pub fn solution2(arena: std.mem.Allocator, text: []const u8) !u64 {
    return solution(1, arena, text);
}
