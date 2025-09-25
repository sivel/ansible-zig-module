// Copyright: Contributors to the Ansible project
// GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

const std = @import("std");
const json = std.json;

pub const Response = struct {
    msg: []const u8,
    changed: bool = false,
    failed: bool = false,
};

pub fn exitJson(allocator: std.mem.Allocator, response: Response) noreturn {
    returnResponse(allocator, response);
}

pub fn failJson(allocator: std.mem.Allocator, response_arg: Response) noreturn {
    var response = response_arg;
    response.failed = true;
    returnResponse(allocator, response);
}

pub fn returnResponse(allocator: std.mem.Allocator, response: Response) noreturn {
    const json_string = json.Stringify.valueAlloc(allocator, response, .{}) catch |err| switch (err) {
        error.OutOfMemory => {
            bufferedPrint("{{\"msg\": \"Out of memory\", \"failed\": true}}") catch {
                std.process.exit(1);
            };
            std.process.exit(1);
        },
    };
    defer allocator.free(json_string);

    bufferedPrint(json_string) catch {
        if (response.failed) {
            std.process.exit(1);
        } else {
            std.process.exit(0);
        }
    };

    if (response.failed) {
        std.process.exit(1);
    } else {
        std.process.exit(0);
    }
}

pub fn bufferedPrint(message: []const u8) !void {
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    try stdout.print("{s}\n", .{message});
    try stdout.flush();
}

pub fn parseArgs(comptime T: type, allocator: std.mem.Allocator) !json.Parsed(T) {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 2) {
        const response = Response{
            .msg = "No argument file provided",
        };
        failJson(allocator, response);
    }

    const args_file = args[1];

    const file_content = std.fs.cwd().readFileAlloc(allocator, args_file, std.math.maxInt(usize)) catch |err| switch (err) {
        error.FileNotFound => {
            const base_msg = "Could not read configuration file";
            const msg = std.fmt.allocPrint(allocator, "{s}: {s}", .{ base_msg, args_file }) catch base_msg;
            const response = Response{ .msg = msg };
            failJson(allocator, response);
        },
        error.AccessDenied => {
            const base_msg = "Access denied reading configuration file";
            const msg = std.fmt.allocPrint(allocator, "{s}: {s}", .{ base_msg, args_file }) catch base_msg;
            const response = Response{ .msg = msg };
            failJson(allocator, response);
        },
        else => {
            const base_msg = "Could not read configuration file";
            const msg = std.fmt.allocPrint(allocator, "{s}: {s}", .{ base_msg, args_file }) catch base_msg;
            const response = Response{ .msg = msg };
            failJson(allocator, response);
        },
    };
    defer allocator.free(file_content);

    const parsed = json.parseFromSlice(T, allocator, file_content, .{ .ignore_unknown_fields = true, .allocate = .alloc_always }) catch {
        const base_msg = "Configuration file not valid JSON";
        const msg = std.fmt.allocPrint(allocator, "{s}: {s}", .{ base_msg, args_file }) catch base_msg;
        const response = Response{ .msg = msg };
        failJson(allocator, response);
    };

    return parsed;
}
