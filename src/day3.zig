const std = @import("std");
const assert = std.debug.assert;

const test_input =
    \\987654321111111
    \\811111111111119
    \\234234234234278
    \\818181911112111
;

fn calculateJoltage(comptime digits: usize, line: []const u8) u64 {
    var candidate: [digits]u8 = line[0..digits].*;
    const indicies: @Vector(digits, u32) = std.simd.iota(usize, digits);
    var candidate_idx: [digits]usize = indicies;

    // std.log.err("Line: {s}", .{line});
    // std.log.err("Candidates start: {s}", .{candidate});
    var index: usize = 1;

    outter: while (index < line.len) : (index += 1) {
        // std.log.err("Cadidate: {s}", .{candidate});
        inline for (0..digits) |digit| {
            if (candidate[digit] < line[index] and
                index < (line.len - (digits - digit - 1)) and
                candidate_idx[digit] < index)
            {
                candidate[digit..].* = line[index .. index + digits - digit][0 .. digits - digit].*;
                const offsets = indicies + @as(@Vector(digits, u32), @splat(@truncate(index)));
                const offsets_data: [digits]usize = offsets;
                candidate_idx[digit..].* = offsets_data[0 .. digits - digit].*;
                continue :outter;
            }
        }
    }

    // std.log.err("Candidates: {s}", .{candidate});

    var result: u64 = 0;
    inline for (candidate) |digit| {
        result = result * 10 + (digit - '0');
    }

    return result;
}

pub fn part1(input: []const u8) !u64 {
    var result: u64 = 0;
    const data = if (input[input.len - 1] == '\n') input[0 .. input.len - 1] else input;
    var iter = std.mem.splitScalar(u8, data, '\n');

    while (iter.next()) |line| {
        result += calculateJoltage(2, line);
    }
    return result;
}

test "Part 1" {
    try std.testing.expectEqual(@as(u64, 357), try part1(test_input));
}

pub fn part2(input: []const u8) !u64 {
    var result: u64 = 0;
    const data = if (input[input.len - 1] == '\n') input[0 .. input.len - 1] else input;
    var iter = std.mem.splitScalar(u8, data, '\n');

    while (iter.next()) |line| {
        result += calculateJoltage(12, line);
        // std.log.err("--------------", .{});
    }

    return result;
}

test "Part 2" {
    try std.testing.expectEqual(@as(u64, 3121910778619), try part2(test_input));
}
