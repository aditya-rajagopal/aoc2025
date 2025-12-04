const std = @import("std");

const test_input =
    \\..@@.@@@@.
    \\@@@.@.@.@@
    \\@@@@@.@.@@
    \\@.@@@@..@.
    \\@@.@@@@.@@
    \\.@@@@@@@.@
    \\.@.@.@.@@@
    \\@.@@@.@@@@
    \\.@@@@@@@@.
    \\@.@.@@@.@.
;

fn parseGrid(noalias input: []const u8, noalias grid: []u8, width: usize, height: usize) void {
    var iter = std.mem.splitScalar(u8, input, '\n');
    const first_row = iter.next().?;

    for (first_row, 0..) |cell, col| {
        if (cell == '@') {
            if (col < width - 1) {
                grid[col + 1] += 1;
                grid[width + col + 1] += 1;
            }
            if (col > 0) {
                grid[col - 1] += 1;
                grid[width + col - 1] += 1;
            }
            grid[width + col] += 1;
        }
    }

    var row: usize = 1;
    while (row < height - 1) {
        const line = iter.next().?;
        for (line, 0..) |cell, col| {
            if (cell == '@') {
                if (col < width - 1) {
                    grid[width * (row - 1) + col + 1] += 1;
                    grid[width * row + col + 1] += 1;
                    grid[width * (row + 1) + col + 1] += 1;
                }
                if (col > 0) {
                    grid[width * (row - 1) + col - 1] += 1;
                    grid[width * row + col - 1] += 1;
                    grid[width * (row + 1) + col - 1] += 1;
                }
                grid[width * (row - 1) + col] += 1;
                grid[width * (row + 1) + col] += 1;
            }
        }
        row += 1;
    }

    const last_row = iter.next().?;
    for (last_row, 0..) |cell, col| {
        if (cell == '@') {
            if (col < width - 1) {
                grid[width * (height - 2) + col + 1] += 1;
                grid[width * (height - 1) + col + 1] += 1;
            }
            if (col > 0) {
                grid[width * (height - 2) + col - 1] += 1;
                grid[width * (height - 1) + col - 1] += 1;
            }
            grid[width * (height - 2) + col] += 1;
        }
    }
}

pub fn part1(input: []const u8) u64 {
    const data = if (input[input.len - 1] == '\n') input[0 .. input.len - 1] else input;
    const width = std.mem.find(u8, data, "\n").?;
    const height = std.mem.count(u8, data, "\n") + 1;
    if (height == 1) return 0;

    // std.log.err("Width: {d}, Height: {d}", .{ width, height });

    const grid: []u8 = std.heap.page_allocator.alloc(u8, width * height) catch unreachable;
    @memset(grid, 0);

    parseGrid(data, grid, width, height);

    var result: u64 = 0;
    for (grid, 0..) |val, i| {
        const row = @divTrunc(i, width);
        const col = @mod(i, width);
        result += @intFromBool(val < 4 and input[row * (width + 1) + col] == '@');
    }
    // for (0..height) |i| {
    //     std.log.err("{any}", .{grid[i * width .. (i + 1) * width]});
    // }
    return result;
}

test "Part 1" {
    try std.testing.expectEqual(@as(u64, 13), part1(test_input));
}

pub fn part2(input: []const u8) u64 {
    var result: u64 = 0;
    const data: []u8 =
        if (input[input.len - 1] == '\n')
            std.heap.page_allocator.dupe(u8, input[0 .. input.len - 1]) catch unreachable
        else
            std.heap.page_allocator.dupe(u8, input) catch unreachable;

    const width = std.mem.find(u8, data, "\n").?;
    const height = std.mem.count(u8, data, "\n") + 1;
    if (height == 1) return 0;

    // std.log.err("Width: {d}, Height: {d}", .{ width, height });

    const grid: []u8 = std.heap.page_allocator.alloc(u8, width * height) catch unreachable;

    var new_result: u64 = 1;
    while (new_result != 0) {
        @memset(grid, 0);
        parseGrid(data, grid, width, height);

        new_result = 0;
        for (grid, 0..) |val, i| {
            const row = @divTrunc(i, width);
            const col = @mod(i, width);
            const condition = val < 4 and data[row * (width + 1) + col] == '@';
            new_result += @intFromBool(condition);
            if (condition) {
                data[row * (width + 1) + col] = '.';
            }
        }
        // debugPrintGrid(data, grid, width, height);
        result += new_result;
        // std.log.err("new_result: {d}", .{new_result});
    }

    return result;
}

fn debugPrintGrid(input: []const u8, grid: ?[]const u8, width: usize, height: usize) void {
    var buffer: [1024]u8 = undefined;
    var index: usize = 0;
    for (0..height) |row| {
        for (0..width) |col| {
            buffer[index] = input[row * (width + 1) + col];
            if (grid) |g| {
                if (g[row * width + col] < 4 and input[row * (width + 1) + col] == '@') {
                    buffer[index] = 'x';
                }
            }
            index += 1;
        }
        buffer[index] = '\n';
        index += 1;
    }
    std.log.err("Grid: \n{s}", .{buffer[0..index]});
}

test "Part 2" {
    try std.testing.expectEqual(@as(u64, 43), part2(test_input));
}
