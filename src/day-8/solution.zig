const std = @import("std");

const Vec = @Vector(2, u8);

fn addDiff(from: Vec, torwards: Vec, size: Vec) ?Vec {
    const res, const overflow = @subWithOverflow(torwards + torwards, from);
    if (@reduce(.Or, overflow != @as(Vec, @splat(0))) or
        @reduce(.Or, res >= size)) return null;

    return res;
}

pub fn solution1(arena: std.mem.Allocator, text: []const u8) !u64 {
    const result = try arena.dupe(u8, text);

    const width = std.mem.indexOfScalar(u8, text, '\n') orelse return error.NoLineBreak;
    const height = std.mem.count(u8, text, "\n");
    const size: Vec = .{ @intCast(width), @intCast(height) };

    const stride = width + 1;

    var frequencies: std.BoundedArray(u8, 0x30) = .{};
    var positions: std.BoundedArray(std.BoundedArray(Vec, 10), 0x30) = .{};
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
                    if (addDiff(points[0], points[1], size)) |pos| {
                        const char = &result[pos[0] + pos[1] * stride];
                        if (char.* != '#') {
                            counter += 1;
                            char.* = '#';
                        }
                    }
                }
            }
        }
    }

    return counter;
}
pub fn solution2(arena: std.mem.Allocator, text: []const u8) !u64 {
    const result = try arena.dupe(u8, text);

    const width = std.mem.indexOfScalar(u8, text, '\n') orelse return error.NoLineBreak;
    const height = std.mem.count(u8, text, "\n");
    const size: Vec = .{ @intCast(width), @intCast(height) };

    const stride = width + 1;

    var frequencies: std.BoundedArray(u8, 0x30) = .{};
    var positions: std.BoundedArray(std.BoundedArray(Vec, 10), 0x30) = .{};
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
                    { // cover antennas
                        const char = &result[points[0][0] + points[0][1] * stride];
                        if (char.* != '#') {
                            counter += 1;
                            char.* = '#';
                        }
                    }
                    var from = points[0];
                    var to = points[1];
                    while (addDiff(from, to, size)) |pos| {
                        const char = &result[pos[0] + pos[1] * stride];
                        if (char.* != '#') {
                            counter += 1;
                            char.* = '#';
                        }
                        from = to;
                        to = pos;
                    }
                }
            }
        }
    }

    return counter;
}
