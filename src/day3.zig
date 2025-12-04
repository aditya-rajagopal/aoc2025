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
    const indicies: @Vector(digits, u8) = std.simd.iota(usize, digits);
    var candidate_idx: [digits]u8 = indicies;

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
                const offsets = indicies + @as(@Vector(digits, u8), @splat(@truncate(index)));
                const offsets_data: [digits]u8 = offsets;
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

// NOTE: Alternative solution using DP and SIMD from
// https://topaz.github.io/paste/#XQAAAQCBAgAAAAAAAAA4HUhjF1isREcvF0cBXvhafO9gvbExmRVQWqSYYJ3gU888pTp+O5qFfbUmMyVBmHaGnInC40/lzKpgtZj2CtfpjRRtg1tc5+OEUdFnIyC5wIqi1yfQcIPHcLtEXA952Vy0IF2bEonL9OMDaq9vuMA3ZOnZS4dgzLSLqWtrpXMOGaCRr+ht1g9eI8DabX94LlSuJRr0USZP+ZYslxbYFsLWsy/WamhKZuSZlK7TndgmrOoH/k2d9EznOch4l/J9tj+Hq909Cufh723SmPKz1TqBIN1Y+g/4rNTJNrKZrisyj4bGHRvjw9qPf1eDde7fRnq4YFCISirqU76Ltw1MronEJwqixnoMX3njAkDIw8MK5Qtmoikpe2n5J/v9Tx6zwdKQdkXgnBSy9Q5AUpyWS33tu87EzmkQsINBU7tE782VAZnMd/PkifJU/qWTAqSbLsQeYr5mUWmt/4DxuCA=
// Modified this to work for any random input.
pub fn alternate_function(comptime digits: usize, input: []const u8) !u64 {
    const nearest_power: usize = comptime blk: {
        var candidate = std.math.ceilPowerOfTwo(usize, digits) catch unreachable;
        while (digits + 1 > candidate) {
            candidate = std.math.ceilPowerOfTwo(usize, candidate + 1) catch unreachable;
        }
        break :blk candidate;
    };
    const right_shift_mask: @Vector(nearest_power, i32) = comptime blk: {
        var data: [nearest_power]i32 = [_]i32{-1} ++ [_]i32{0} ** digits ++ [_]i32{-1} ** (nearest_power - digits - 1);
        for (0..digits) |digit| {
            data[digit + 1] = digit;
        }
        break :blk data;
    };
    const zero: @Vector(nearest_power, u64) = @splat(0);
    const ten: @Vector(nearest_power, u64) = @splat(10);

    var result: u64 = 0;

    const data = if (input[input.len - 1] == '\n') input[0 .. input.len - 1] else input;
    var iter = std.mem.splitScalar(u8, data, '\n');

    while (iter.next()) |bank| {
        // std.log.err("Line: {s}", .{bank});
        var dp = zero;
        for (bank) |battery| {
            const digit: @Vector(nearest_power, u64) = @splat(battery - '0');
            // std.log.err("DP:  {any}", .{dp});
            // std.log.err("DP2: {any}", .{dp * ten + digit});
            dp = @max(dp, @shuffle(u64, dp * ten + digit, zero, right_shift_mask));
        }
        result += dp[digits];
        // std.log.err("", .{});
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
    try std.testing.expectEqual(@as(u64, 357), try alternate_function(2, test_input));
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
    try std.testing.expectEqual(@as(u64, 3121910778619), try alternate_function(12, test_input));
}
