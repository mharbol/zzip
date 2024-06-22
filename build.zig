const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zzip",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib_rle = b.addStaticLibrary(.{
        .name = "rle",
        .root_source_file = b.path("src/rle/rle.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib_rle);

    const mod_rle = b.addModule("rle", .{ .root_source_file = b.path("src/rle/rle.zig") });
    exe.root_module.addImport("rle", mod_rle);

    const lib_file = b.addStaticLibrary(.{
        .name = "rle",
        .root_source_file = b.path("src/file/file.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib_file);

    const mod_file = b.addModule("file", .{ .root_source_file = b.path("src/file/file.zig") });
    exe.root_module.addImport("file", mod_file);

    const lib_util = b.addStaticLibrary(.{
        .name = "util",
        .root_source_file = b.path("src/util/util.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib_util);

    const mod_util = b.addModule("util", .{ .root_source_file = b.path("src/util/util.zig") });
    exe.root_module.addImport("util", mod_util);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
    const lib_rle_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/rle/rle.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_lib_rle_unit_tests = b.addRunArtifact(lib_rle_unit_tests);

    const lib_util_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/util/util.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_lib_util_unit_tests = b.addRunArtifact(lib_util_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    b.installArtifact(exe);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
    test_step.dependOn(&run_lib_rle_unit_tests.step);
    test_step.dependOn(&run_lib_util_unit_tests.step);
}
