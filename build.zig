const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "libuv",
        .target = target,
        .optimize = optimize,
    });
    const t = target.result;

    lib.addCSourceFiles(.{ .files = &generic_src_files });
    lib.addIncludePath(b.path("include"));
    lib.addIncludePath(b.path("src"));
    lib.linkLibC();

    switch (t.os.tag) {
        .linux => {
            lib.defineCMacro("_FILE_OFFSET_BITS", "64");
            lib.defineCMacro("_LARGEFILE_SOURCE", "1");
            lib.defineCMacro("_GNU_SOURCE", "1");
            lib.defineCMacro("_POSIX_C_SOURCE", "200112");

            lib.linkSystemLibrary("dl");
            lib.linkSystemLibrary("rt");

            lib.addCSourceFiles(.{ .files = &unix_src_files });
            lib.addCSourceFiles(.{ .files = &linux_src_files });
        },
        .macos => {
            lib.defineCMacro("_FILE_OFFSET_BITS", "64");
            lib.defineCMacro("_LARGEFILE_SOURCE", "1");
            lib.defineCMacro("_DARWIN_UNLIMITED_SELECT", "1");
            lib.defineCMacro("_DARWIN_USE_64_BIT_INODE", "1");
            lib.addCSourceFiles(.{ .files = &unix_src_files });
            lib.addCSourceFiles(.{ .files = &macos_src_files });
        },
        else => {
            std.debug.panic("unsupported OS tag: {}", .{t.os.tag});
        },
    }
    lib.installHeadersDirectory(b.path("include"), "", .{});
    b.installArtifact(lib);
}

const generic_src_files = [_][]const u8{
    "src/fs-poll.c",
    "src/idna.c",
    "src/inet.c",
    "src/random.c",
    "src/strscpy.c",
    "src/strtok.c",
    "src/thread-common.c",
    "src/threadpool.c",
    "src/timer.c",
    "src/uv-common.c",
    "src/uv-data-getter-setters.c",
    "src/version.c",
};

const macos_src_files = [_][]const u8{
    "src/unix/proctitle.c",
    "src/unix/bsd-ifaddrs.c",
    "src/unix/kqueue.c",
    "src/unix/random-getentropy.c",
    "src/unix/darwin-proctitle.c",
    "src/unix/darwin.c",
    "src/unix/fsevents.c",
};

const linux_src_files = [_][]const u8{
    "src/unix/proctitle.c",
    "src/unix/linux.c",
    "src/unix/procfs-exepath.c",
    "src/unix/random-getrandom.c",
    "src/unix/random-sysctl-linux.c",
};

const unix_src_files = [_][]const u8{
    "src/unix/async.c",
    "src/unix/core.c",
    "src/unix/dl.c",
    "src/unix/fs.c",
    "src/unix/getaddrinfo.c",
    "src/unix/getnameinfo.c",
    "src/unix/loop-watcher.c",
    "src/unix/loop.c",
    "src/unix/pipe.c",
    "src/unix/poll.c",
    "src/unix/process.c",
    "src/unix/random-devurandom.c",
    "src/unix/signal.c",
    "src/unix/stream.c",
    "src/unix/tcp.c",
    "src/unix/thread.c",
    "src/unix/tty.c",
    "src/unix/udp.c",
};
