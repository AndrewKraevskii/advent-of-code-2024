const std = @import("std");

pub fn findEquasion(comptime Operator: type, numbers: []const u64, current_sum: u64, target_sum: u64, output_operators: []Operator) bool {
    std.debug.assert(numbers.len == output_operators.len);

    if (numbers.len == 0) return current_sum == target_sum;

    inline for (@typeInfo(Operator).@"enum".fields) |op_info| {
        const op = @field(Operator, op_info.name);

        output_operators[0] = op;

        const result = op.apply(current_sum, numbers[0]);

        switch (std.math.order(result, target_sum)) {
            .gt => {},
            .lt, .eq => if (findEquasion(Operator, numbers[1..], result, target_sum, output_operators[1..]))
                return true,
        }
    }
    return false;
}

pub fn solution(comptime Operator: type, text: []const u8) !u64 {
    var line_iter = std.mem.tokenizeScalar(u8, text, '\n');
    var sum: u64 = 0;
    while (line_iter.next()) |line| {
        var number_iter = std.mem.tokenizeAny(u8, line, ": ");
        const target = std.fmt.parseInt(u64, number_iter.next() orelse unreachable, 10) catch unreachable;
        var numbers: std.BoundedArray(u64, 0x20) = .{};

        while (number_iter.next()) |num| {
            numbers.appendAssumeCapacity(std.fmt.parseInt(u64, num, 10) catch unreachable);
        }
        var operators_buffer: [0x20]Operator = undefined;
        if (findEquasion(Operator, numbers.slice()[1..], numbers.get(0), target, operators_buffer[0 .. numbers.len - 1])) {
            sum += target;
        }
    }
    return sum;
}

pub fn solution1(_: std.mem.Allocator, text: []const u8) !u64 {
    const Operator = enum {
        add,
        mul,

        fn apply(op: @This(), lhs: u64, rhs: u64) u64 {
            return switch (op) {
                .add => lhs + rhs,
                .mul => lhs * rhs,
            };
        }
    };
    return solution(Operator, text);
}

pub fn solution2(_: std.mem.Allocator, text: []const u8) !u64 {
    const Operator = enum {
        add,
        mul,
        con,

        fn apply(op: @This(), lhs: u64, rhs: u64) u64 {
            return switch (op) {
                .add => lhs + rhs,
                .mul => lhs * rhs,
                .con => lhs * (std.math.powi(u64, 10, std.math.log10_int(rhs) + 1) catch unreachable) + rhs,
            };
        }
    };
    return solution(Operator, text);
}
