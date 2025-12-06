const std = @import("std");
const assert = std.debug.assert;

const test_input: []const u8 =
    \\123 328  51 64 
    \\ 45 64  387 23 
    \\  6 98  215 314
    \\*   +   *   +  
    \\
;

pub fn part1(input: []const u8) u64 {
    var buffer: [8192 * 2]u16 align(128) = undefined;
    const line_length: usize = std.mem.indexOfScalar(u8, input, '\n') orelse unreachable;
    const line_count: usize = input.len / (line_length + 1);

    // TODO: Implement something different if line_count > 5
    assert(line_count >= 2);
    assert(line_count <= 5);

    var numbers_addition: [4]std.ArrayList(u16) = undefined;
    var numbers_mult: [4]std.ArrayList(u16) = undefined;
    inline for (&numbers_addition, &numbers_mult, 0..) |*add, *mult, i| {
        add.* = std.ArrayList(u16).initBuffer(buffer[i * 2048 .. (i + 1) * 2048]);
        mult.* = std.ArrayList(u16).initBuffer(buffer[8192 + i * 2048 .. 8192 + (i + 1) * 2048]);
    }

    var lines: [5][]const u8 = undefined;
    for (0..line_count) |i| {
        lines[i] = input[i * (line_length + 1) .. (i + 1) * (line_length + 1) - 1];
    }

    const symbol_line = lines[line_count - 1];

    var index: usize = 0;
    var next_index: usize = 0;
    // TODO: Should we do the parsing first
    // var bool_buffer: [2048]bool = undefined;
    // var start_buffer: [2048]u16 = undefined;
    // var start_indices: std.ArrayList(u16) = std.ArrayList(u16).initBuffer(start_buffer[0..]);
    // var is_addition: std.ArrayList(bool) = std.ArrayList(bool).initBuffer(bool_buffer[0..]);
    // while (index < line_length) : (index += 1) {
    //     var next_operator_index: usize = index + 1;
    //     while (symbol_line[next_operator_index] == ' ') : (next_operator_index += 1) {}
    //     next_index = next_operator_index;
    //     if (symbol_line[index] == '+') {
    //         is_addition.appendAssumeCapacity(true);
    //     } else {
    //         is_addition.appendAssumeCapacity(false);
    //     }
    // }

    while (index < line_length) : (index = next_index) {
        var next_operator_index: usize = index + 1;
        while (next_operator_index < line_length and symbol_line[next_operator_index] == ' ') : (next_operator_index += 1) {}
        next_index = next_operator_index;

        if (symbol_line[index] == '*') {
            for (lines[0 .. line_count - 1], 0..) |line, i| {
                var start_index: usize = index;
                while (line[start_index] == ' ') : (start_index += 1) {}
                const end_index: usize = std.mem.indexOfScalarPos(u8, line, start_index, ' ') orelse line.len;
                numbers_mult[i].appendAssumeCapacity(std.fmt.parseUnsigned(u16, line[start_index..end_index], 10) catch unreachable);
            }
        } else {
            for (lines[0 .. line_count - 1], 0..) |line, i| {
                var start_index: usize = index;
                while (line[start_index] == ' ') : (start_index += 1) {}
                const end_index: usize = std.mem.indexOfScalarPos(u8, line, start_index, ' ') orelse line.len;
                numbers_addition[i].appendAssumeCapacity(std.fmt.parseUnsigned(u16, line[start_index..end_index], 10) catch unreachable);
            }
        }
    }

    // @PERF Find optimal vector length
    const vector_length = 16;
    const VecInt = @Vector(vector_length, u64);
    const zero: VecInt = @splat(0);
    const ones: VecInt = @splat(1);

    // NOTE: Padding the bounds with zeros so the size is aligned to our vector length. We dont have to deal with
    // special cases this way.
    {
        const num_ranges = numbers_addition[0].items.len;
        const nearest_aligned_boundry = (num_ranges + vector_length - 1) & ~@as(usize, vector_length - 1);
        for (0..line_count - 1) |i| {
            numbers_addition[i].appendNTimesAssumeCapacity(0, nearest_aligned_boundry - num_ranges);
        }
        assert(numbers_addition[0].items.len == nearest_aligned_boundry);
    }
    {
        const num_ranges = numbers_mult[0].items.len;
        const nearest_aligned_boundry = (num_ranges + vector_length - 1) & ~@as(usize, vector_length - 1);
        for (0..line_count - 1) |i| {
            numbers_mult[i].appendNTimesAssumeCapacity(0, nearest_aligned_boundry - num_ranges);
        }
        assert(numbers_mult[0].items.len == nearest_aligned_boundry);
    }

    var result: VecInt = zero;
    index = 0;
    while (index < numbers_addition[0].items.len) : (index += vector_length) {
        var inner: VecInt = zero;
        for (0..line_count - 1) |i| {
            const addition_vec: VecInt = numbers_addition[i].items[index .. index + vector_length][0..vector_length].*;
            inner += addition_vec;
        }
        result += inner;
    }
    index = 0;
    while (index < numbers_mult[0].items.len) : (index += vector_length) {
        var inner: VecInt = ones;
        for (0..line_count - 1) |i| {
            const mult_vec: VecInt = numbers_mult[i].items[index .. index + vector_length][0..vector_length].*;
            inner *= mult_vec;
        }
        result += inner;
    }

    return @reduce(.Add, result);
}

test "part1" {
    try std.testing.expectEqual(4277556, part1(test_input));
}

pub fn part2(input: []const u8) u64 {
    var buffer: [8192 * 2]u16 align(128) = undefined;
    const line_length: usize = std.mem.indexOfScalar(u8, input, '\n') orelse unreachable;
    const line_count: usize = input.len / (line_length + 1);

    // TODO: Implement something different if line_count > 5
    assert(line_count >= 2);
    assert(line_count <= 5);

    var numbers_addition: [4]std.ArrayList(u16) = undefined;
    var numbers_mult: [4]std.ArrayList(u16) = undefined;
    inline for (&numbers_addition, &numbers_mult, 0..) |*add, *mult, i| {
        add.* = std.ArrayList(u16).initBuffer(buffer[i * 2048 .. (i + 1) * 2048]);
        mult.* = std.ArrayList(u16).initBuffer(buffer[8192 + i * 2048 .. 8192 + (i + 1) * 2048]);
    }

    var lines: [5][]const u8 = undefined;
    for (0..line_count) |i| {
        lines[i] = input[i * (line_length + 1) .. (i + 1) * (line_length + 1) - 1];
    }

    const symbol_line = lines[line_count - 1];

    var index: usize = 0;
    var next_index: usize = 0;
    var bool_buffer: [2048]bool = undefined;
    var start_buffer: [2048]u16 = undefined;
    var start_indices: std.ArrayList(u16) = std.ArrayList(u16).initBuffer(start_buffer[0..]);
    var is_addition: std.ArrayList(bool) = std.ArrayList(bool).initBuffer(bool_buffer[0..]);
    while (index < line_length) : (index = next_index) {
        start_indices.appendAssumeCapacity(@truncate(index));
        var next_operator_index: usize = index + 1;
        while (next_operator_index < line_length and symbol_line[next_operator_index] == ' ') : (next_operator_index += 1) {}
        next_index = next_operator_index;
        if (symbol_line[index] == '+') {
            is_addition.appendAssumeCapacity(true);
            for (numbers_addition[0 .. line_count - 1]) |*line| {
                line.appendAssumeCapacity(0);
            }
        } else {
            is_addition.appendAssumeCapacity(false);
            for (numbers_mult[0 .. line_count - 1]) |*line| {
                line.appendAssumeCapacity(0);
            }
        }
    }
    start_indices.appendAssumeCapacity(@truncate(line_length));

    for (lines[0 .. line_count - 1]) |line| {
        var addition_index: usize = 0;
        var mult_index: usize = 0;
        for (0..start_indices.items.len - 1) |i| {
            if (is_addition.items[i]) {
                for (line[start_indices.items[i]..start_indices.items[i + 1]], 0..) |char, j| {
                    if (char != ' ') {
                        numbers_addition[j].items[addition_index] = numbers_addition[j].items[addition_index] * 10 + (char - '0');
                    }
                }
                addition_index += 1;
            } else {
                for (line[start_indices.items[i]..start_indices.items[i + 1]], 0..) |char, j| {
                    if (char != ' ') {
                        numbers_mult[j].items[mult_index] = numbers_mult[j].items[mult_index] * 10 + (char - '0');
                    }
                }
                mult_index += 1;
            }
        }
    }

    for (0..line_count - 1) |i| {
        for (numbers_mult[i].items) |*item| {
            if (item.* == 0) {
                item.* = 1;
            }
        }
    }

    // @PERF Find optimal vector length
    const vector_length = 16;
    const VecInt = @Vector(vector_length, u64);
    const zero: VecInt = @splat(0);
    const ones: VecInt = @splat(1);

    // NOTE: Padding the bounds with zeros so the size is aligned to our vector length. We dont have to deal with
    // special cases this way.
    {
        const num_ranges = numbers_addition[0].items.len;
        const nearest_aligned_boundry = (num_ranges + vector_length - 1) & ~@as(usize, vector_length - 1);
        for (0..line_count - 1) |i| {
            numbers_addition[i].appendNTimesAssumeCapacity(0, nearest_aligned_boundry - num_ranges);
        }
        assert(numbers_addition[0].items.len == nearest_aligned_boundry);
    }
    {
        const num_ranges = numbers_mult[0].items.len;
        const nearest_aligned_boundry = (num_ranges + vector_length - 1) & ~@as(usize, vector_length - 1);
        for (0..line_count - 1) |i| {
            numbers_mult[i].appendNTimesAssumeCapacity(0, nearest_aligned_boundry - num_ranges);
        }
        assert(numbers_mult[0].items.len == nearest_aligned_boundry);
    }

    var result: VecInt = zero;
    index = 0;
    while (index < numbers_addition[0].items.len) : (index += vector_length) {
        var inner: VecInt = zero;
        for (0..line_count - 1) |i| {
            const addition_vec: VecInt = numbers_addition[i].items[index .. index + vector_length][0..vector_length].*;
            inner += addition_vec;
        }
        result += inner;
    }
    index = 0;
    while (index < numbers_mult[0].items.len) : (index += vector_length) {
        var inner: VecInt = ones;
        for (0..line_count - 1) |i| {
            const mult_vec: VecInt = numbers_mult[i].items[index .. index + vector_length][0..vector_length].*;
            inner *= mult_vec;
        }
        result += inner;
    }

    return @reduce(.Add, result);
}

test "part2" {
    try std.testing.expectEqual(3263827, part2(test_input));
}

test "part2-2" {
    const input: []const u8 =
        \\27 1   527 963 3  449  1 91 3447
        \\16 3   138 874 8  855 83 89 6767
        \\13 29  94  759 56  98 98 14 815 
        \\3  882 69  449 99  79 32 53 83  
        \\*  *   *   +   +  *   +  +  +   
        \\
    ;
    try std.testing.expectEqual(3069811434, part2(input));
}
