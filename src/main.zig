const std = @import("std");
const config = @import("config");
const solution = if (config.part == .@"1") @import("solution").solution1 else @import("solution").solution2;
const day = config.day;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    const dir_name = std.fmt.comptimePrint("day-{d}", .{day});
    const input_path = dir_name ++ .{std.fs.path.sep} ++ "input.txt";
    const test_path = dir_name ++ .{std.fs.path.sep} ++ "test.txt";
    const test_answer_part1 = dir_name ++ .{std.fs.path.sep} ++ "1-test-answer.txt";
    const test_answer_part2 = dir_name ++ .{std.fs.path.sep} ++ "2-test-answer.txt";
    const test_answer_path = if (config.part == .@"1") test_answer_part1 else test_answer_part2;
    const input = @embedFile(if (config.is_test) test_path else input_path);

    if (config.benchmark) {
        const times_to_run = times_to_run: {
            var timer = try std.time.Timer.start();
            const res = try solution(arena.allocator(), input);
            _ = res; // autofix
            const diff = timer.read();
            const seconds_to_benchmark = 3;
            const minimum_times_to_run = 5;
            break :times_to_run @max(
                minimum_times_to_run,
                seconds_to_benchmark * std.time.ns_per_s / diff,
            );
        };

        var progress = std.Progress.start(.{});
        defer progress.end();
        var node = progress.start("Benchmarking ", times_to_run);
        var timer = try std.time.Timer.start();
        for (0..times_to_run) |_| {
            _ = arena.reset(.retain_capacity);
            _ = try solution(arena.allocator(), input);
            node.completeOne();
        }
        const time = timer.read();
        std.debug.print(
            \\runned for {d} times 
            \\average time is {} 
            \\
        , .{ times_to_run, std.fmt.fmtDuration(time / times_to_run) });
    }

    const res = try solution(arena.allocator(), input);
    if (config.is_test) {
        const expected = std.fmt.parseInt(u64, std.mem.trim(
            u8,
            @embedFile(test_answer_path),
            &std.ascii.whitespace,
        ), 10);
        try std.testing.expectEqual(expected, res);
    } else {
        try std.io.getStdOut().writer().print("{d}\n", .{res});
    }
}
