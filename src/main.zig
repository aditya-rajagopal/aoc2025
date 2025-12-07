const std = @import("std");
const builtin = @import("builtin");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");
const day5 = @import("day5.zig");
const day6 = @import("day6.zig");
const day7 = @import("day7.zig");
const day1_data: []const u8 = @embedFile("data/day1.txt");
const day2_data: []const u8 = @embedFile("data/day2.txt");
const day3_data: []const u8 = @embedFile("data/day3.txt");
const day4_data: []const u8 = @embedFile("data/day4.txt");
const day5_data: []const u8 = @embedFile("data/day5.txt");
const day6_data: []const u8 = @embedFile("data/day6.txt");
const day7_data: []const u8 = @embedFile("data/day7.txt");

const iterations: u64 = 10000;

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const result_day1_1 = try day1.part1(day1_data);
    var end = timer.lap();
    std.log.info("Day 1 Part 1\n\tPassword is: {d}\n\tTime: {d}ms", .{ result_day1_1, @as(f32, @floatFromInt(end)) / @as(f32, std.time.ns_per_ms) });
    timer.reset();
    const result_day1_2 = try day1.part2(day1_data);
    end = timer.lap();
    std.log.info("Day 1 Part 2\n\tPassword is: {d}\n\tTime: {d}ms", .{ result_day1_2, @as(f32, @floatFromInt(end)) / @as(f32, std.time.ns_per_ms) });
    timer.reset();
    const result_day2_1 = try day2.part1(day2_data);
    end = timer.lap();
    std.log.info("Day 2 Part 1\n\tTotal removed is: {d} \n\tTime: {d}ms", .{ result_day2_1, @as(f32, @floatFromInt(end)) / @as(f32, std.time.ns_per_ms) });
    timer.reset();
    const result_day2_2 = try day2.part2(day2_data);
    end = timer.lap();
    std.log.info("Day 2 Part 2\n\tTotal removed is: {d} \n\tTime: {d}ms", .{ result_day2_2, @as(f32, @floatFromInt(end)) / @as(f32, std.time.ns_per_ms) });
    timer.reset();
    const result_day3_1 = try day3.part1(day3_data);
    end = timer.lap();
    std.log.info("Day 3 Part 1\n\tTotal joltage is: {d} \n\tTime: {d}ms", .{ result_day3_1, @as(f32, @floatFromInt(end)) / @as(f32, std.time.ns_per_ms) });
    timer.reset();
    const result_day3_2 = try day3.part2(day3_data);
    end = timer.lap();
    std.log.info("Day 3 Part 2\n\tTotal joltage is: {d} \n\tTime: {d}ms", .{ result_day3_2, @as(f32, @floatFromInt(end)) / @as(f32, std.time.ns_per_ms) });
    timer.reset();
    const result_day4_1 = day4.part1(day4_data);
    end = timer.lap();
    std.log.info("Day 4 Part 1\n\tTotal rolls are: {d} \n\tTime: {d}ms", .{ result_day4_1, @as(f32, @floatFromInt(end)) / @as(f32, std.time.ns_per_ms) });
    timer.reset();
    const result_day4_2 = day4.part2(day4_data);
    end = timer.lap();
    std.log.info("Day 4 Part 2\n\tTotal rolls are: {d} \n\tTime: {d}ms", .{ result_day4_2, @as(f32, @floatFromInt(end)) / @as(f32, std.time.ns_per_ms) });
    timer.reset();
    const result_day5_1 = day5.part1(day5_data);
    end = timer.lap();
    std.log.info("Day 5 Part 1\n\tTotal ingredients: {d} \n\tTime: {d}ms", .{ result_day5_1, @as(f32, @floatFromInt(end)) / @as(f32, std.time.ns_per_ms) });
    timer.reset();
    const result_day5_2 = day5.part2(day5_data);
    end = timer.lap();
    std.log.info("Day 5 Part 2\n\tTotal ingredients: {d} \n\tTime: {d}ms", .{ result_day5_2, @as(f32, @floatFromInt(end)) / @as(f32, std.time.ns_per_ms) });
    timer.reset();
    var result_day6_1: u64 = 0;
    for (0..iterations) |_| {
        result_day6_1 = day6.part1(day6_data);
    }
    end = timer.lap();
    std.log.info("Day 6 Part 1\n\tTotal: {d} \n\tTime: {d}ms", .{ result_day6_1, @as(f32, @floatFromInt(end)) / @as(f32, std.time.ns_per_ms) / iterations });
    timer.reset();
    var result_day6_2: u64 = 0;
    for (0..iterations) |_| {
        result_day6_2 = day6.part2(day6_data);
    }
    end = timer.lap();
    std.log.info("Day 6 Part 2\n\tTotal: {d} \n\tTime: {d}ms", .{ result_day6_2, @as(f32, @floatFromInt(end)) / @as(f32, std.time.ns_per_ms) / iterations });
    timer.reset();
    var result_day7_1: u64 = 0;
    for (0..iterations) |_| {
        result_day7_1 = day7.part1(day7_data);
    }
    end = timer.lap();
    std.log.info("Day 7 Part 1\n\tTotal: {d} \n\tTime: {d}ms", .{ result_day7_1, @as(f32, @floatFromInt(end)) / @as(f32, std.time.ns_per_ms) / iterations });
    timer.reset();
    var result_day7_2: u64 = 0;
    for (0..iterations) |_| {
        result_day7_2 = day7.part2(day7_data);
    }
    end = timer.lap();
    std.log.info("Day 7 Part 2\n\tTotal: {d} \n\tTime: {d}ms", .{ result_day7_2, @as(f32, @floatFromInt(end)) / @as(f32, std.time.ns_per_ms) / iterations });
}
