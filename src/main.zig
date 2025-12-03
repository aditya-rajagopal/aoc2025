const std = @import("std");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day1_data: []const u8 = @embedFile("data/day1.txt");
const day2_data: []const u8 = @embedFile("data/day2.txt");

pub fn main() !void {
    const result_day1_1 = try day1.part1(day1_data);
    std.log.info("Day 1 Part 1\n Password is: {d} \n", .{result_day1_1});
    const result_day1_2 = try day1.part2(day1_data);
    std.log.info("Day 1 Part 2\n Password is: {d} \n", .{result_day1_2});
    const result_day2_1 = try day2.part1(day2_data);
    std.log.info("Day 2 Part 1\n Total removed is: {d} \n", .{result_day2_1});
}
