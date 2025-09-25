// Copyright: Contributors to the Ansible project
// GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

const std = @import("std");
const helloworld = @import("helloworld");

const ModuleArgs = struct {
    name: ?[]const u8 = null,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const parsed = try helloworld.parseArgs(ModuleArgs, allocator);
    defer parsed.deinit();

    const module_args = parsed.value;
    const name = module_args.name orelse "World";

    const response = helloworld.Response{
        .msg = try std.fmt.allocPrint(allocator, "Hello, {s}!", .{name}),
    };

    try helloworld.exitJson(allocator, response);
}
