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

pub fn part1and2(input: []const u8) struct { u64, u64 } {
    const width = std.mem.findScalar(u8, input, '\n') orelse unreachable;
    const height = input.len / (width + 1);
    assert(height >= 2);
    assert(width >= 3);

    const beam_start: usize = std.mem.findScalar(u8, input, 'S') orelse unreachable;

    // NOTE: I am assuming that there can only be 256 columns at most. This can be changed if needed.
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

    var part1: u64 = 0;
    var i: usize = 2;
    // NOTE: We dont need to loop through the entire row. The first instance of a `^` will always be at a predictable position
    // and the last instance will always be at a predictable position for a given row.
    var start_displacement: usize = 0;
    while (i < height - 1) : (i += 2) {
        const line = input[i * (width + 1) ..][0..width];
        var position: usize = beam_start - start_displacement;
        while (position < beam_start + start_displacement + 1) : (position += 1) {
            if (!(line[position] == '^' and beams[position] > 0)) continue;
            // NOTE: Assuming there are no splitters at the edges
            // NOTE: Because a `^` is always followed by a `.` modifying position + 1 is safe as it will be skipped
            part1 += 1;
            const split_1 = position - 1;
            const split_2 = position + 1;
            beams[split_1] += beams[position];
            beams[split_2] += beams[position];
            beams[position] = 0;
            position += 1;
        }
        start_displacement += 1;
    }
    const part2: @Vector(256, usize) = buffer;

    return .{ part1, @reduce(.Add, part2) };
}

test "part1" {
    const part1, const part2 = part1and2(test_input);
    try std.testing.expectEqual(21, part1);
    try std.testing.expectEqual(40, part2);
}

test "part2" {}
