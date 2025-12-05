const std = @import("std");
const assert = std.debug.assert;

const test_input =
    \\3-5
    \\10-14
    \\16-20
    \\12-18
    \\
    \\1
    \\5
    \\8
    \\11
    \\17
    \\32
    \\
;

pub fn part1(input: []const u8) u64 {
    var result: u64 = 0;
    var buffer: [2048]i64 = undefined;
    var lower_bounds = std.ArrayList(i64).initBuffer(buffer[0..1024]);
    var upper_bounds = std.ArrayList(i64).initBuffer(buffer[1024..]);

    var lines = std.mem.splitScalar(u8, input[0 .. input.len - 1], '\n');

    while (lines.next()) |line| {
        if (line.len == 0) break;
        const hyphen_index = std.mem.indexOfScalar(u8, line, '-') orelse unreachable;
        const lower: i64 = std.fmt.parseUnsigned(i64, line[0..hyphen_index], 10) catch unreachable;
        const upper: i64 = std.fmt.parseUnsigned(i64, line[hyphen_index + 1 ..], 10) catch unreachable;
        lower_bounds.appendAssumeCapacity(lower);
        upper_bounds.appendAssumeCapacity(upper);
    }

    // @PERF Find optimal vector length
    const vector_length = 16;
    const VecInt = @Vector(vector_length, i64);
    const VecBool = @Vector(vector_length, bool);
    const zero: VecInt = @splat(0);

    // NOTE: Padding the bounds with zeros so the size is aligned to our vector length. We dont have to deal with
    // special cases this way.
    const num_ranges = lower_bounds.items.len;
    const nearest_aligned_boundry = (num_ranges + vector_length - 1) & ~@as(usize, vector_length - 1);
    lower_bounds.appendNTimesAssumeCapacity(0, nearest_aligned_boundry - num_ranges);
    upper_bounds.appendNTimesAssumeCapacity(0, nearest_aligned_boundry - num_ranges);
    assert(lower_bounds.items.len == nearest_aligned_boundry);

    while (lines.next()) |line| {
        const number: i64 = std.fmt.parseUnsigned(i64, line, 10) catch unreachable;
        var index: usize = 0;
        while (index < lower_bounds.items.len) : (index += vector_length) {
            const lower_vec: VecInt = lower_bounds.items[index .. index + vector_length][0..vector_length].*;
            const upper_vec: VecInt = upper_bounds.items[index .. index + vector_length][0..vector_length].*;
            const candidate: VecInt = @splat(number);

            const lower_bound_check: VecBool = (candidate - lower_vec) >= zero;
            const upper_bound_check: VecBool = (upper_vec - candidate) >= zero;
            const in_range_count = @reduce(.Or, lower_bound_check & upper_bound_check);

            if (in_range_count) {
                result += 1;
                break;
            }
        }
    }

    return result;
}

test "part1" {
    try std.testing.expectEqual(3, part1(test_input));
}

inline fn isOverlap(lower1: u64, upper1: u64, lower2: u64, upper2: u64) bool {
    const result = @max(lower1 - 1, lower2) <= @min(upper1 + 1, upper2);
    return result;
}

pub fn part2(input: []const u8) u64 {
    var result: u64 = 0;
    var buffer: [2048]u64 = undefined;
    // const buffer: []u64 = std.heap.page_allocator.alignedAlloc(u64, .fromByteUnits(128), 2048) catch unreachable;
    var lower_bounds = std.ArrayList(u64).initBuffer(buffer[0..1024]);
    var upper_bounds = std.ArrayList(u64).initBuffer(buffer[1024..]);

    var lines = std.mem.splitScalar(u8, input[0 .. input.len - 1], '\n');

    outter_loop: while (lines.next()) |line| {
        if (line.len == 0) break;
        const hyphen_index = std.mem.indexOfScalar(u8, line, '-') orelse unreachable;
        const lower: u64 = std.fmt.parseUnsigned(u64, line[0..hyphen_index], 10) catch unreachable;
        const upper: u64 = std.fmt.parseUnsigned(u64, line[hyphen_index + 1 ..], 10) catch unreachable;
        // std.log.err("Testing: [{}, {}]", .{ lower, upper });

        for (0..lower_bounds.items.len) |index| {
            if (isOverlap(lower_bounds.items[index], upper_bounds.items[index], lower, upper)) {
                // std.log.err("[{}, {}] overlaps with [{}, {}]", .{ lower_bounds.items[index], upper_bounds.items[index], lower, upper });
                lower_bounds.items[index] = @min(lower_bounds.items[index], lower);
                upper_bounds.items[index] = @max(upper_bounds.items[index], upper);

                // NOTE: Once we have merged the new range to the current one we iteratvely check subsequent ranges for overlap
                // and merge them down.
                const j: usize = index + 1;
                while (j < lower_bounds.items.len) {
                    if (isOverlap(lower_bounds.items[j], upper_bounds.items[j], lower_bounds.items[index], upper_bounds.items[index])) {
                        // std.log.err("\t[{}, {}] overlaps with [{}, {}]", .{ lower_bounds.items[index], upper_bounds.items[index], lower_bounds.items[j], upper_bounds.items[j] });
                        lower_bounds.items[index] = @min(lower_bounds.items[index], lower_bounds.items[j]);
                        upper_bounds.items[index] = @max(upper_bounds.items[index], upper_bounds.items[j]);
                        _ = lower_bounds.orderedRemove(j);
                        _ = upper_bounds.orderedRemove(j);
                        continue;
                    } else {
                        break;
                    }
                }
                continue :outter_loop;
            }

            // NOTE: If the new range has no overlap and has an upperbound lower than the current range then we place it
            // before the current range. With this we ensure that no range beyond will have any overlap.
            if (upper < upper_bounds.items[index]) {
                lower_bounds.insertAssumeCapacity(index, lower);
                upper_bounds.insertAssumeCapacity(index, upper);
                continue :outter_loop;
            }
        }

        lower_bounds.appendAssumeCapacity(lower);
        upper_bounds.appendAssumeCapacity(upper);
    }

    // std.log.err("Lower: {any}", .{lower_bounds});
    // std.log.err("Upper: {any}", .{upper_bounds});

    // @PERF Find optimal vector length
    const vector_length = 16;
    const VecInt = @Vector(vector_length, u64);
    const zero: VecInt = @splat(0);
    const ones: VecInt = @splat(1);

    // NOTE: Padding the bounds with zeros so the size is aligned to our vector length. We dont have to deal with
    // special cases this way.
    const num_ranges = lower_bounds.items.len;
    const nearest_aligned_boundry = (num_ranges + vector_length - 1) & ~@as(usize, vector_length - 1);
    lower_bounds.appendNTimesAssumeCapacity(0, nearest_aligned_boundry - num_ranges);
    upper_bounds.appendNTimesAssumeCapacity(0, nearest_aligned_boundry - num_ranges);
    assert(lower_bounds.items.len == nearest_aligned_boundry);

    var index: usize = 0;
    while (index < lower_bounds.items.len) : (index += vector_length) {
        const lower_vec: VecInt = lower_bounds.items[index .. index + vector_length][0..vector_length].*;
        const upper_vec: VecInt = upper_bounds.items[index .. index + vector_length][0..vector_length].*;

        result += @reduce(.Add, upper_vec - lower_vec + ones * @intFromBool(upper_vec > zero));
    }

    // NOTE: This is about as fast as doing the SIMD version but SIMD is cooler
    // for (lower_bounds.items, upper_bounds.items) |lower, upper| {
    //     result += upper - lower + 1;
    // }
    return result;
}

test "part2" {
    try std.testing.expectEqual(14, part2(test_input));
}

test "part2-2" {
    const input: []const u8 =
        \\3-5
        \\10-14
        \\7-8
        \\16-20
        \\12-18
        \\
    ;
    try std.testing.expectEqual(16, part2(input));
}
