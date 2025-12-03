const std = @import("std");
const test_input: []const u8 = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

pub fn part1(input: []const u8) !u64 {
    var result: u64 = 0;

    var data = if (input[input.len - 1] == '\n') input[0 .. input.len - 1] else input;

    while (data.len > 0) {
        var index: usize = @intFromBool(data[0] == ',');

        const first_number_start = index;
        while (data[index] != '-') : (index += 1) {}
        const first_number: []const u8 = data[first_number_start..index];
        const first_number_digits = first_number.len;

        index += 1;
        const second_number_start = index;
        while (index < data.len and data[index] != ',') : (index += 1) {}
        const second_number: []const u8 = data[second_number_start..index];
        const second_number_digits = second_number.len;

        var digits = first_number_digits;
        while (digits <= second_number_digits) : (digits += 1) {
            if (digits & 1 == 1) continue;

            const half_digits: usize = digits / 2;

            var candidate_half_start = std.math.pow(usize, 10, half_digits - 1);
            const upper_number_position: u64 = std.math.pow(u64, 10, half_digits);
            var candidate_half_end = upper_number_position - 1;

            if (first_number_digits == digits) {
                const first_number_first_half: u64 = try std.fmt.parseInt(u64, first_number[0..half_digits], 10);
                const first_number_second_half: u64 = try std.fmt.parseInt(u64, first_number[half_digits..], 10);
                if (first_number_first_half < first_number_second_half) {
                    candidate_half_start = first_number_first_half + 1;
                } else {
                    candidate_half_start = first_number_first_half;
                }
            }

            if (second_number_digits == digits) {
                const second_number_first_half: u64 = try std.fmt.parseInt(u64, second_number[0..half_digits], 10);
                const second_number_second_half: u64 = try std.fmt.parseInt(u64, second_number[half_digits..], 10);
                if (second_number_first_half <= second_number_second_half) {
                    candidate_half_end = second_number_first_half;
                } else {
                    candidate_half_end = second_number_first_half - 1;
                }
            }

            var half_number: u64 = candidate_half_start;
            while (half_number <= candidate_half_end) : (half_number += 1) {
                const candidate = half_number * upper_number_position + half_number;
                result += candidate;
            }
        }
        data = data[index..];
    }

    return result;
}

test "part 1" {
    try std.testing.expectEqual(@as(u64, 1227775554), try part1(test_input));
}

// NOTE: a u64 number can only have a maximum of 20 digit numbers.
const prime_factors = [_]u64{ 2, 3, 5, 7, 11, 13, 17, 19 };

pub fn part2(input: []const u8) void {
    _ = input;
}
