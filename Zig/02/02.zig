// Idea: generate hashes of the 9 possible combinations and their scores (e.g.,
// 'A X' = Tie => 1 + 3 = 4), and iterate over the input file.

const std = @import("std");
const testData = @embedFile("02.test");
const pageAlloc = std.heap.page_allocator;

// Hash the possible values of a 3 x 3 input parameter matrix
fn prepareTable() !std.StringHashMap(u32) {
    const stringTable = [_][]const u8{ "A X", "A Y", "A Z", "B X", "B Y", "B Z", "C X", "C Y", "C Z" };
    var table = std.StringHashMap(u32).init(pageAlloc);
    var score: u32 = 0;

    for (stringTable) |line| {
        // Score each case
        score = rps(line);

        // Hash each line
        try table.put(line, score);
    }

    return table;
}

// Function that plays Rock-Paper-Scissors
fn rps(line: []const u8) u32 {
    const offset: u8 = 23;
    var score: u32 = 0;

    // Check if win or lose
    //std.debug.print("line[2] = {}\n", .{line[2]});
    //std.debug.print("line[2] - offset = {}\n", .{line[2] - offset});
    if (line[2] - offset > line[0]) {
        // Win condition
        score += 6;
    } else if (line[2] - offset == line[0]) {
        // Tie condition
        score += 3;
    } else {
        // loss
    }

    // Check what played for score
    if (line[2] == 'X') {
        // Rock
        score += 1;
    } else if (line[2] == 'Y') {
        // Paper
        score += 2;
    } else {
        // Scissors
        score += 3;
    }
    return score;
}

pub fn main() !void {
    // Generate the hash table
    const table: std.StringHashMap(u32) = try prepareTable();

    // Preapare and read the file
    var score: u32 = 0;

    var file = try std.fs.cwd().openFile("02.dat", .{});
    defer file.close();

    const out = std.io.getStdOut();
    var buf_writer = std.io.bufferedWriter(out.writer());
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    const stream_max_size: ?usize = 16;
    //var buf: [5]u8 = undefined;

    while (try in_stream.streamUntilDelimiter(buf_writer, '\n', stream_max_size)) |line| {
        score += table.get(line);
    }

    std.debug.print("Final score: {}\n", .{score});
}

test "hash map" {
    // Hash test file - read in each line, compute its score, then hash it
    std.debug.print("\n", .{});

    const table: std.StringHashMap(u32) = try prepareTable();
    try std.testing.expectEqual(rps("A X"), 4);
    try std.testing.expectEqual(rps("B Y"), 5);
    try std.testing.expectEqual(rps("C Z"), 6);
    try std.testing.expectEqual(rps("B X"), 1);
    try std.testing.expectEqual(table.get("A X").?, 4);
    try std.testing.expectEqual(table.get("B Y"), 5);
    try std.testing.expectEqual(table.get("B X"), 1);
}
