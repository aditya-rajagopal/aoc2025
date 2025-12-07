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

    var buffer: [1024]bool = undefined;
    assert(width * 2 < buffer.len);

    @memset(buffer[0 .. 2 * width], false);

    var beams = [_][]bool{ buffer[0..width], buffer[width .. 2 * width] };
    var current: usize = 0;
    var next: usize = 1;

    beams[current][beam_start] = true;

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
            for (beams[current], 0..) |beam, index| {
                if (beam) {
                    grid_line[index] = '|';
                }
            }
        }

        const line = input[i * (width + 1) ..][0..width];
        for (beams[current], 0..) |beam, position| {
            if (beam) {
                if (line[position] == '^') {
                    result += 1;
                    // NOTE: Assuming there are no splitters at the edges
                    const split_1 = position - 1;
                    const split_2 = position + 1;
                    beams[next][split_1] = true;
                    beams[next][split_2] = true;
                } else {
                    beams[next][position] = true;
                }
            }
        }
        @memset(beams[current], false);

        if (builtin.mode == .Debug) {
            const grid_line = grid[i * (width + 1) ..][0..width];
            for (beams[next], 0..) |beam, index| {
                if (beam) {
                    grid_line[index] = '|';
                }
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
    var buffer: [1024]usize = undefined;
    assert(width * 2 < buffer.len);

    @memset(buffer[0 .. 2 * width], 0);

    var beams = [_][]usize{ buffer[0..width], buffer[width .. 2 * width] };
    var current: usize = 0;
    var next: usize = 1;

    beams[current][beam_start] = 1;

    // NOTE: Observing the inputs it seems that splitters only exist on alternating rows.
    // Should this not be the case the algorithm will need to be modified. This also means
    // the number of rws should be even.
    // Also assuming that the two splitters are not next to each other and we can always split into two.
    const splitters_alternating: bool = true;
    assert(splitters_alternating and height & 1 == 0);
    var i: usize = 2;
    while (i < height - 1) : (i += 2) {
        const line = input[i * (width + 1) ..][0..width];
        for (beams[current], 0..) |superpositions, position| {
            if (superpositions == 0) continue;
            if (line[position] == '^') {
                // NOTE: Assuming there are no splitters at the edges
                const split_1 = position - 1;
                const split_2 = position + 1;
                beams[next][split_1] += superpositions;
                beams[next][split_2] += superpositions;
            } else {
                beams[next][position] += superpositions;
            }
        }
        @memset(beams[current], 0);

        current ^= 1;
        next ^= 1;
    }
    var result: u64 = 0;
    for (beams[current]) |superpositions| {
        result += superpositions;
    }

    return result;
}

test "part2" {
    try std.testing.expectEqual(40, part2(test_input));
}
