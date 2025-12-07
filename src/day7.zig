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

    const beam_start: usize = std.mem.findScalar(u8, input, 'S') orelse unreachable;

    var buffer: [256]bool = undefined;
    assert(width < buffer.len);

    @memset(buffer[0..width], false);
    var beams = buffer[0..width];
    beams[beam_start] = true;

    {
        // NOTE: Observing the inputs it seems that splitters only exist on alternating rows.
        // Should this not be the case the algorithm will need to be modified. This also means
        // the number of rws should be even.
        // Also assuming that the two splitters are not next to each other and we can always split into two.
        const splitters_alternating: bool = true;
        assert(splitters_alternating and height & 1 == 0);
    }

    var result: u64 = 0;
    var i: usize = 2;
    var start_displacement: usize = 0;
    while (i < height - 1) : (i += 2) {
        const line = input[i * (width + 1) ..][0..width];
        var position: usize = beam_start - start_displacement;
        while (position < beam_start + start_displacement + 1) : (position += 1) {
            if (!(line[position] == '^' and beams[position])) continue;
            // NOTE: Assuming there are no splitters at the edges
            // NOTE: Because a `^` is always followed by a `.` modifying position + 1 is safe as it will be skipped
            result += 1;
            beams[position - 1] = true;
            beams[position + 1] = true;
            beams[position] = false;
            position += 1;
        }
        start_displacement += 1;
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

    var buffer: [256]usize = undefined;
    assert(width < buffer.len);

    @memset(&buffer, 0);
    var beams = buffer[0..width];
    beams[beam_start] = 1;

    {
        // NOTE: Observing the inputs it seems that splitters only exist on alternating rows.
        // Should this not be the case the algorithm will need to be modified. This also means
        // the number of rws should be even.
        // Also assuming that the two splitters are not next to each other and we can always split into two.
        const splitters_alternating: bool = true;
        assert(splitters_alternating and height & 1 == 0);
    }

    var i: usize = 2;
    var start_displacement: usize = 0;
    while (i < height - 1) : (i += 2) {
        const line = input[i * (width + 1) ..][0..width];
        var position: usize = beam_start - start_displacement;
        while (position < beam_start + start_displacement + 1) : (position += 1) {
            if (!(line[position] == '^' and beams[position] > 0)) continue;
            // NOTE: Assuming there are no splitters at the edges
            // NOTE: Because a `^` is always followed by a `.` modifying position + 1 is safe as it will be skipped
            const split_1 = position - 1;
            const split_2 = position + 1;
            beams[split_1] += beams[position];
            beams[split_2] += beams[position];
            beams[position] = 0;
        }
        start_displacement += 1;
    }
    const result: @Vector(256, usize) = buffer;

    return @reduce(.Add, result);
}

test "part2" {
    try std.testing.expectEqual(40, part2(test_input));
}
