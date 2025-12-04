const std = @import("std");

const test_input: []const u8 = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

// NOTE: a u64 number can only have a maximum of 20 digit numbers.
const prime_factors = [_][]const u64{
    &[_]u64{},
    &[_]u64{},
    &[_]u64{2},
    &[_]u64{3},
    &[_]u64{2},
    &[_]u64{5},
    &[_]u64{ 2, 3 },
    &[_]u64{7},
    &[_]u64{2},
    &[_]u64{3},
    &[_]u64{ 2, 5 },
    &[_]u64{11},
    &[_]u64{ 2, 3 },
    &[_]u64{13},
    &[_]u64{ 2, 7 },
    &[_]u64{ 3, 5 },
    &[_]u64{2},
    &[_]u64{17},
    &[_]u64{ 2, 3 },
    &[_]u64{19},
    &[_]u64{ 2, 5 },
};

pub fn totalCandidatesAtNumber(
    noalias first_number: []const u8,
    noalias second_number: []const u8,
    digits: u64,
    prime: usize,
    hash_set: ?*std.AutoHashMap(u64, void),
) u64 {
    var result: u64 = 0;
    // std.log.err("Prime: {}", .{prime});
    const candidate_digits = @divExact(digits, prime);
    var candidate_start = std.math.pow(u64, 10, candidate_digits - 1);
    const shift_multiplier = std.math.pow(u64, 10, candidate_digits);
    var candidate_end = shift_multiplier - 1;

    if (first_number.len == digits) {
        const first_number_first_part: u64 = std.fmt.parseInt(u64, first_number[0..candidate_digits], 10) catch unreachable;
        candidate_start = first_number_first_part;

        const part: u64 = std.fmt.parseInt(u64, first_number[candidate_digits .. 2 * candidate_digits], 10) catch unreachable;
        if (first_number_first_part < part) {
            candidate_start = first_number_first_part + 1;
        }
    }

    if (second_number.len == digits) {
        const second_number_first_part: u64 = std.fmt.parseInt(u64, second_number[0..candidate_digits], 10) catch unreachable;
        candidate_end = second_number_first_part;

        const part: u64 = std.fmt.parseInt(u64, second_number[candidate_digits .. 2 * candidate_digits], 10) catch unreachable;
        if (second_number_first_part > part) {
            candidate_end = second_number_first_part - 1;
        }
    }

    // std.log.err("Start - End: {d} - {d}", .{ candidate_start, candidate_end });

    var candidate: u64 = candidate_start;

    if (hash_set != null and prime_factors[digits].len > 1 and prime_factors[digits][0] == 2) {
        // NOTE: When we have 2 as a prime factor of the number of digits it is possible
        // that other prime factors could cause duplicates when the same digit is repeated.
        // eg. 111111 is a candidate for 2 repeats and 3 repeats. So we can create a hash set when processing
        // the split 2 group when there are more than 1 prime factors.
        if (prime == 2) {
            while (candidate <= candidate_end) : (candidate += 1) {
                var value: u64 = 0;
                for (0..prime) |_| {
                    value = value * shift_multiplier + candidate;
                }
                hash_set.?.put(value, {}) catch unreachable;
                // std.log.err("removed: {}", .{value});
                result += value;
            }
        } else {
            while (candidate <= candidate_end) : (candidate += 1) {
                var value: u64 = 0;
                for (0..prime) |_| {
                    value = value * shift_multiplier + candidate;
                }
                if (!hash_set.?.contains(value)) {
                    // std.log.err("removed: {}", .{value});
                    result += value;
                    // } else {
                    //     std.log.err("Duplicate: {}", .{value});
                }
            }
        }
    } else {
        while (candidate <= candidate_end) : (candidate += 1) {
            var value: u64 = 0;
            for (0..prime) |_| {
                value = value * shift_multiplier + candidate;
            }
            // std.log.err("removed: {}", .{value});
            result += value;
        }
    }

    // std.log.err("", .{});

    return result;
}

pub fn part1(input: []const u8) !u64 {
    var result: u64 = 0;

    var data = if (input[input.len - 1] == '\n') input[0 .. input.len - 1] else input;

    while (data.len > 0) {
        var index: usize = @intFromBool(data[0] == ',');

        const first_number_start = index;
        while (data[index] != '-') : (index += 1) {}
        const first_number: []const u8 = data[first_number_start..index];

        index += 1;
        const second_number_start = index;
        while (index < data.len and data[index] != ',') : (index += 1) {}
        const second_number: []const u8 = data[second_number_start..index];
        // std.log.err("First number:  {s}", .{first_number});
        // std.log.err("Second number: {s}", .{second_number});

        var digits = first_number.len;
        while (digits <= second_number.len) : (digits += 1) {
            if (digits & 1 == 1) continue;
            result += totalCandidatesAtNumber(first_number, second_number, digits, 2, null);
        }
        data = data[index..];
    }

    return result;
}

test "part 1" {
    try std.testing.expectEqual(@as(u64, 1227775554), try part1(test_input));
}

pub fn part2(input: []const u8) !u64 {
    var result: u64 = 0;

    var data = if (input[input.len - 1] == '\n') input[0 .. input.len - 1] else input;
    const allocator = std.heap.page_allocator;
    var hash_set = std.AutoHashMap(u64, void).init(allocator);
    hash_set.ensureUnusedCapacity(256) catch unreachable;

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
        // std.log.err("+++++++++++++", .{});
        // std.log.err("First number:  {s}", .{first_number});
        // std.log.err("Second number: {s}", .{second_number});

        var digits = first_number_digits;
        while (digits <= second_number_digits) : (digits += 1) {
            // std.log.err("-------------", .{});
            // std.log.err("Digits : {d} ", .{digits});
            for (prime_factors[digits]) |prime| {
                result += totalCandidatesAtNumber(first_number, second_number, digits, prime, &hash_set);
            }
            hash_set.clearRetainingCapacity();
        }
        data = data[index..];
    }
    return result;
}

test "part 2" {
    try std.testing.expectEqual(@as(u64, 4174379265), try part2(test_input));
}

test "part 2-2" {
    const input = "4338572-4507716";
    try std.testing.expectEqual(@as(u64, 4444444), try part2(input));
}
