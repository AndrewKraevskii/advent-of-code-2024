const std = @import("std");

const Operator = enum {
    add,
    mul,

    fn apply(op: Operator, lhs: u64, rhs: u64) u64 {
        return switch (op) {
            .add => lhs + rhs,
            .mul => lhs * rhs,
        };
    }
};

pub fn findEquasion(numbers: []const u64, current_sum: u64, target_sum: u64, output_operators: []Operator) bool {
    std.debug.assert(numbers.len == output_operators.len);

    if (numbers.len == 0) return current_sum == target_sum;

    for (&[_]Operator{ .add, .mul }) |op| {
        output_operators[0] = op;

        const result = op.apply(current_sum, numbers[0]);

        switch (std.math.order(result, target_sum)) {
            .gt => {},
            .lt, .eq => if (findEquasion(numbers[1..], result, target_sum, output_operators[1..]))
                return true,
        }
    }
    return false;
}

pub fn solution1(_: std.mem.Allocator, text: []const u8) !u64 {
    var line_iter = std.mem.tokenizeScalar(u8, text, '\n');
    var sum: u64 = 0;
    while (line_iter.next()) |line| {
        var number_iter = std.mem.tokenizeAny(u8, line, ": ");
        const target = std.fmt.parseInt(u64, number_iter.next() orelse unreachable, 10) catch unreachable;
        var numbers: std.BoundedArray(u64, 0x20) = .{};

        while (number_iter.next()) |num| {
            numbers.appendAssumeCapacity(std.fmt.parseInt(u64, num, 10) catch unreachable);
        }
        // std.debug.print("{d}: {any}\n", .{ target, numbers.slice() });
        var operators_buffer: [0x20]Operator = undefined;
        if (findEquasion(numbers.slice()[1..], numbers.get(0), target, operators_buffer[0 .. numbers.len - 1])) {
            // std.debug.print("{any}\n", .{operators_buffer[0 .. numbers.len - 1]});
            sum += target;
        }
    }
    return sum;
}

pub fn solution2(_: std.mem.Allocator, text: []const u8) !u64 {
    _ = text; // autofix
    return 0;
}
