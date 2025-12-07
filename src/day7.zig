const std = @import("std");
const builtin = @import("builtin");
const assert = std.debug.assert;

const test_input =
    \\.......S.......
    \\...............
    \\.......^.......
    \\...............
    \\......^.^......
    \\...............
    \\.....^.^.^.....
    \\...............
    \\....^.^...^....
    \\...............
    \\...^.^...^.^...
    \\...............
    \\..^...^.....^..
    \\...............
    \\.^.^.^.^.^...^.
    \\...............
    \\
;

pub fn part1(input: []const u8) u64 {
    const width = std.mem.findScalar(u8, input, '\n') orelse unreachable;
    const height = input.len / (width + 1);
    assert(height >= 2);
    assert(width >= 3);

    const grid: []u8 = if (builtin.mode == .Debug) std.heap.page_allocator.dupe(u8, input) catch unreachable else undefined;

    const beam_start: usize = std.mem.findScalar(u8, input, 'S') orelse unreachable;
    var buffer: [512 * 1024]u8 = undefined;
    var buffer1 = std.heap.FixedBufferAllocator.init(buffer[0 .. 128 * 1024]);
    var buffer2 = std.heap.FixedBufferAllocator.init(buffer[128 * 1024 ..]);

    const HashSet = std.AutoArrayHashMap(u8, void);

    var beams = [_]HashSet{ HashSet.init(buffer1.allocator()), HashSet.init(buffer2.allocator()) };

    var current: usize = 0;
    var next: usize = 1;
    beams[current].ensureUnusedCapacity(1024) catch unreachable;
    beams[next].ensureUnusedCapacity(1024) catch unreachable;

    beams[current].putAssumeCapacity(@truncate(beam_start), {});

    // NOTE: Observing the inputs it seems that splitters only exist on alternating rows.
    // Should this not be the case the algorithm will need to be modified. This also means
    // the number of rws should be even.
    // Also assuming that the two splitters are not next to each other and we can always split into two.
    const splitters_alternating: bool = true;
    assert(splitters_alternating and height & 1 == 0);
    var result: u64 = 0;
    var i: usize = 2;
    while (i < height - 1) : (i += 2) {
        if (builtin.mode == .Debug) {
            const grid_line = grid[(i - 1) * (width + 1) ..][0..width];
            for (beams[current].keys()) |key| {
                grid_line[key] = '|';
            }
        }

        const line = input[i * (width + 1) ..][0..width];
        for (beams[current].keys()) |beam| {
            if (line[beam] == '^') {
                result += 1;
                // NOTE: Assuming there are no splitters at the edges
                const split_1 = beam - 1;
                const split_2 = beam + 1;
                beams[next].putAssumeCapacity(split_1, {});
                beams[next].putAssumeCapacity(split_2, {});
            } else {
                beams[next].putAssumeCapacity(beam, {});
            }
        }
        beams[current].clearRetainingCapacity();

        if (builtin.mode == .Debug) {
            const grid_line = grid[i * (width + 1) ..][0..width];
            for (beams[next].keys()) |key| {
                grid_line[key] = '|';
            }
        }
        current ^= 1;
        next ^= 1;
    }

    // if (builtin.mode == .Debug) {
    //     std.log.err("Grid: \n{s}", .{grid});
    // }

    return result;
}

test "part1" {
    try std.testing.expectEqual(21, part1(test_input));
}

pub fn part2(input: []const u8) u64 {
    const width = std.mem.findScalar(u8, input, '\n') orelse unreachable;
    const height = input.len / (width + 1);
    assert(height >= 2);
    assert(width >= 3);

    const beam_start: usize = std.mem.findScalar(u8, input, 'S') orelse unreachable;
    var buffer: [512 * 1024]u8 = undefined;
    var buffer1 = std.heap.FixedBufferAllocator.init(buffer[0 .. 128 * 1024]);
    var buffer2 = std.heap.FixedBufferAllocator.init(buffer[128 * 1024 ..]);

    const Map = std.AutoArrayHashMap(u8, usize);

    var beams = [_]Map{ Map.init(buffer1.allocator()), Map.init(buffer2.allocator()) };

    var current: usize = 0;
    var next: usize = 1;
    beams[current].ensureUnusedCapacity(1024) catch unreachable;
    beams[next].ensureUnusedCapacity(1024) catch unreachable;

    beams[current].putAssumeCapacity(@truncate(beam_start), 1);

    // NOTE: Observing the inputs it seems that splitters only exist on alternating rows.
    // Should this not be the case the algorithm will need to be modified. This also means
    // the number of rws should be even.
    // Also assuming that the two splitters are not next to each other and we can always split into two.
    const splitters_alternating: bool = true;
    assert(splitters_alternating and height & 1 == 0);
    var i: usize = 2;
    while (i < height - 1) : (i += 2) {
        const line = input[i * (width + 1) ..][0..width];
        var iterator = beams[current].iterator();
        while (iterator.next()) |superposition| {
            if (line[superposition.key_ptr.*] == '^') {
                // NOTE: Assuming there are no splitters at the edges
                const split_1 = superposition.key_ptr.* - 1;
                const split_2 = superposition.key_ptr.* + 1;
                var result = beams[next].getOrPutAssumeCapacity(split_1);
                if (result.found_existing) {
                    result.value_ptr.* += superposition.value_ptr.*;
                } else {
                    result.value_ptr.* = superposition.value_ptr.*;
                }
                result = beams[next].getOrPutAssumeCapacity(split_2);
                if (result.found_existing) {
                    result.value_ptr.* += superposition.value_ptr.*;
                } else {
                    result.value_ptr.* = superposition.value_ptr.*;
                }
            } else {
                const result = beams[next].getOrPutAssumeCapacity(superposition.key_ptr.*);
                if (result.found_existing) {
                    result.value_ptr.* += superposition.value_ptr.*;
                } else {
                    result.value_ptr.* = superposition.value_ptr.*;
                }
            }
        }
        beams[current].clearRetainingCapacity();

        current ^= 1;
        next ^= 1;
    }
    var result: u64 = 0;
    for (beams[current].values()) |value| {
        result += value;
    }

    return result;
}

test "part2" {
    try std.testing.expectEqual(40, part2(test_input));
}
