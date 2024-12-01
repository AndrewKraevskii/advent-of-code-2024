const std = @import("std");

const Part = enum {
    @"1",
    @"2",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const day = b.option(u5, "day", "Day to run") orelse 1;
    const part = b.option(Part, "part", "Part of day to run") orelse .@"1";
    const is_test = b.option(bool, "test", "Run with example input for testing") orelse false;
    const benchmark = b.option(bool, "benchmark", "Run solution muitiple times and measure time") orelse false;

    if (day < 1 or 25 < day) {
        std.debug.panic("Only days from 1 to 25 supported", .{});
    }

    const folder_name = std.fmt.allocPrint(b.allocator, "day-{}", .{day}) catch @panic("OOM");

    const exe = b.addExecutable(.{
        .name = "advent-of-code-2024",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib_name = std.fmt.allocPrint(b.allocator, "day-{d}", .{day}) catch @panic("OOM");
    const solution = b.addStaticLibrary(.{
        .name = lib_name,
        .root_source_file = b.path(b.pathJoin(&.{ "src", folder_name, "solution.zig" })),
        .target = target,
        .optimize = optimize,
    });

    const options = b.addOptions();
    options.addOption(u5, "day", day);
    options.addOption(bool, "is_test", is_test);
    options.addOption(Part, "part", part);
    options.addOption(bool, "benchmark", benchmark);

    exe.root_module.addOptions("config", options);
    exe.root_module.addImport("solution", &solution.root_module);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
