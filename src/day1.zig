const std = @import("std");
const assert = std.debug.assert;

const DIAL_SIZE = 100;
const DIAL_START: u64 = 50; //std.math.maxInt(i64) + 43;

comptime {
    assert(DIAL_START % 100 == 50);
}

pub fn part1(input: []const u8) !i64 {
    var data: []const u8 = input;
    assert(data.len > 3);

    var dial_position: i64 = DIAL_START;
    var result: i64 = 0;

    while (data.len > 0) {
        var length_shift: usize = 0;
        while (data[length_shift + 1] != '\n') : (length_shift += 1) {}
        // std.log.err("Dial Position: {d}, result: {d}", .{ dial_position, result });

        const shift: i64 = @intCast(std.fmt.parseUnsigned(u64, data[1 .. length_shift + 1], 10) catch unreachable);
        // std.log.err("Shift: {c} {}", .{ data[0], shift });
        switch (data[0]) {
            'L' => dial_position -= shift,
            'R' => dial_position += shift,
            else => unreachable,
        }

        dial_position = @mod(dial_position, DIAL_SIZE);
        result += @intFromBool(dial_position == 0);

        data = data[length_shift + 2 ..];
    }

    return result;
}

const test_input =
    \\L68
    \\L30
    \\R48
    \\L5
    \\R60
    \\L55
    \\L1
    \\L99
    \\R14
    \\L82
    \\
;

test "part 1" {
    try std.testing.expectEqual(@as(i64, 3), part1(test_input));
}

pub fn part2(input: []const u8) !i64 {
    var data: []const u8 = input;
    assert(data.len > 3);

    var dial_position: i64 = DIAL_START;
    var result: i64 = 0;

    while (data.len > 0) {
        var length_shift: usize = 0;
        while (data[length_shift + 1] != '\n') : (length_shift += 1) {}
        // std.log.err("Dial Position: {d}, result: {d}", .{ dial_position, result });

        const shift: i64 = @intCast(std.fmt.parseUnsigned(u64, data[1 .. length_shift + 1], 10) catch unreachable);
        // std.log.err("Shift: {c} {}", .{ data[0], shift });
        switch (data[0]) {
            'L' => dial_position -= shift,
            'R' => dial_position += shift,
            else => unreachable,
        }

        result += @intCast(
            @abs(
                @divTrunc(dial_position, DIAL_SIZE),
            ),
        );
        // NOTE: When we go negagtive we have to check if we crossed 0 or started at 0
        result += @intFromBool(dial_position <= 0 and @abs(dial_position) != shift);

        dial_position = @mod(dial_position, DIAL_SIZE);

        data = data[length_shift + 2 ..];
    }

    return result;
}

test "part 2" {
    try std.testing.expectEqual(@as(i64, 6), part2(test_input));
}

test "part 2-2" {
    const test_intput_2: []const u8 =
        \\L51
        \\R2
        \\
    ;
    try std.testing.expectEqual(@as(i64, 2), part2(test_intput_2));
}
