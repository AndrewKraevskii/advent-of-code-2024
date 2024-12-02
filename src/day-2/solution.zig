const std = @import("std");

pub fn parseSimple(token: []const u8) u8 {
    std.debug.assert(1 <= token.len and token.len <= 2);
    return if (token.len == 2) (token[0] - '0') * 10 + (token[1] - '0') else token[0] - '0';
}

pub fn numbersDistanceIs3(num1: u8, num2: u8) bool {
    const diff = @abs(@as(i9, num1) - @as(i9, num2));
    return switch (diff) {
        1...3 => true,
        else => false,
    };
}

pub fn solution1(_: std.mem.Allocator, text: []const u8) !u64 {
    var number_of_valid_lines: u64 = 0;
    var line_iter = std.mem.tokenizeScalar(u8, text, '\n');
    line: while (line_iter.next()) |line| {
        var token_iter = std.mem.tokenizeAny(u8, line, &std.ascii.whitespace);
        const prev_prev: u8 = parseSimple(token_iter.next() orelse unreachable);
        var prev: u8 = parseSimple(token_iter.next() orelse unreachable);
        if (!numbersDistanceIs3(prev_prev, prev)) continue :line;
        const prev_increasing: bool = prev > prev_prev;
        while (token_iter.next()) |token| {
            const num = parseSimple(token);
            const sign = num > prev;
            if (sign != prev_increasing or !numbersDistanceIs3(num, prev))
                continue :line;

            prev = num;
        }

        number_of_valid_lines += 1;
    }
    return number_of_valid_lines;
}

pub fn lineValid(line: []u8, skip: ?usize) ?usize {
    var i: usize = 0;
    if (skip == 0) {
        i += 1;
    }

    var prev_prev: u8 = line[i];
    i += 1;
    if (skip == 1) {
        i += 1;
    }

    var prev: u8 = line[i];
    i += 1;
    if (!numbersDistanceIs3(prev_prev, prev)) return 1;
    const prev_increasing: bool = prev > prev_prev;

    while (i < line.len) : (i += 1) {
        if (i == skip) continue;
        const num = line[i];
        const sign = num > prev;
        if (sign != prev_increasing or
            !numbersDistanceIs3(num, prev))
        {
            i -= 1;
            return i;
        }

        prev_prev = prev;
        prev = num;
    }

    return null;
}

pub fn solution2(_: std.mem.Allocator, text: []const u8) !u64 {
    var number_of_valid_lines: u64 = 0;
    var line_iter = std.mem.tokenizeScalar(u8, text, '\n');
    while (line_iter.next()) |line| {
        var token_iter = std.mem.tokenizeAny(u8, line, &std.ascii.whitespace);
        var bounded_array: std.BoundedArray(u8, 8) = .{};
        while (token_iter.next()) |token| {
            bounded_array.appendAssumeCapacity(parseSimple(token));
        }
        for (0..4) |i| {
            const a = lineValid(bounded_array.slice(), i);
            if (a == null) break;
        } else continue;
        number_of_valid_lines += 1;
    }
    return number_of_valid_lines;
}
