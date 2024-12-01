const std = @import("std");

pub fn solution1(arena: std.mem.Allocator, text: []const u8) !u64 {
    var arrays: [2]std.ArrayList(u32) = .{
        .init(arena),
        .init(arena),
    };

    var iter = std.mem.tokenizeAny(u8, text, &std.ascii.whitespace);
    var i: u1 = 0;
    while (iter.next()) |token| : (i +%= 1) {
        try arrays[i].append(try std.fmt.parseInt(u32, token, 10));
    }

    for (arrays) |array| {
        std.mem.sort(u32, array.items, {}, std.sort.desc(u32));
    }

    var sum: u64 = 0;
    for (arrays[0].items, arrays[1].items) |first, second| {
        sum += @abs(@as(i32, @intCast(first)) - @as(i32, @intCast(second)));
    }

    return sum;
}

pub fn solution2(arena: std.mem.Allocator, text: []const u8) !u64 {
    // ArrayHashMap is faster then regular hashmap by 3% here.
    var times: std.AutoArrayHashMapUnmanaged(u32, [2]u32) = .{};

    var iter = std.mem.tokenizeAny(u8, text, &std.ascii.whitespace);
    var i: u1 = 0;
    while (iter.next()) |token| : (i +%= 1) {
        const num = try std.fmt.parseInt(u32, token, 10);
        const gop = try times.getOrPutValue(
            arena,
            num,
            @splat(0),
        );
        gop.value_ptr.*[i] += 1;
    }
    var sum: u64 = 0;
    for (times.keys(), times.values()) |key, value| {
        sum += key * value[0] * value[1];
    }

    return sum;
}
