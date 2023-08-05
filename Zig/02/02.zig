// Idea: generate hashes of the 9 possible combinations and their scores (e.g.,
// 'A X' = Tie => 1 + 3 = 4), and iterate over the input file.

const std = @import("std");
const pageAlloc = std.heap.page_allocator;

// Hash the possible values of a 3 x 3 input parameter matrix
fn prepareTable(scorer: *const fn (line: []const u8) u32) !std.StringHashMap(u32) {
    const stringTable = [_][]const u8{ "A X", "A Y", "A Z", "B X", "B Y", "B Z", "C X", "C Y", "C Z" };
    var table = std.StringHashMap(u32).init(pageAlloc);
    var score: u32 = 0;

    for (stringTable) |line| {
        // Score each case
        //score = rps(line);
        score = scorer(line);

        // Hash each line
        try table.put(line, score);
    }

    return table;
}

// Function that plays Rock-Paper-Scissors
fn rps(line: []const u8) u32 {
    //const offset: u8 = 23;
    var score: u32 = 0;

    // Check if win or lose
    // This was nice for when line[2] <= line[0] :(
    //if (line[2] - offset > line[0]) {
    //    // Win condition
    //    score += 6;
    //} else if (line[2] - offset == line[0]) {
    //    // Tie condition
    //    score += 3;
    //} else {
    //    // loss
    //}
    if (line[0] == 'A') {
        if (line[2] == 'X') {
            score += 3; // tie
        } else if (line[2] == 'Y') {
            score += 6;
        } else {
            score += 0;
        }
    } else if (line[0] == 'B') {
        if (line[2] == 'X') {
            score += 0;
        } else if (line[2] == 'Y') {
            score += 3;
        } else {
            score += 6;
        }
    } else {    // line[0] == 'C'
        if (line[2] == 'X') {
            score += 6;
        } else if (line[2] == 'Y') {
            score += 0;
        } else {
            score += 3;
        }
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

// Part 2 scoring function
fn rpsAlt(line: []const u8) u32 {
    var score: u32 = 0;

    if (line[0] == 'A') {
        if (line[2] == 'X') {
            score = 3;
        } else if (line[2] == 'Y') {
            score = 4;
        } else {
            score = 8;
        }
    } else if (line[0] == 'B') {
        if (line[2] == 'X') {
            score = 1;
        } else if (line[2] == 'Y') {
            score = 5;
        } else {
            score = 9;
        }
    } else {
        if (line[2] == 'X') {
            score = 2;
        } else if (line[2] == 'Y') {
            score = 6;
        } else {
            score = 7;
        }
    }

    return score;
}

pub fn main() !void {
    // Generate the hash table
    const table: std.StringHashMap(u32) = try prepareTable(rps);
    const table2: std.StringHashMap(u32) = try prepareTable(rpsAlt);

    // The variable the will store the final score
    var score: u32 = 0;
    var score2: u32 = 0;
    var numLines: u32 = 0;

    // Specify the file that will be read from
    var file = try std.fs.cwd().openFile("02.dat", .{.mode = std.fs.File.OpenMode.read_only});
    defer file.close(); // Defer the closing of said file

    var reader = file.reader();
    var output: [5]u8 = undefined;
    var output_fbs = std.io.fixedBufferStream(&output);
    const writer = output_fbs.writer();

    while(true) {
        reader.streamUntilDelimiter(writer, '\n', null) catch { break; };
        var line = output_fbs.getWritten();
        numLines = numLines + 1;
        score = score + (table.get(line) orelse 0);
        score2 = score2 + (table2.get(line) orelse 0);
        //std.debug.print("Line: {s}\n", .{line});
        output_fbs.reset();
    }

    std.debug.print("Final score: {}\n", .{score});
    std.debug.print("Part 2 score: {}\n", .{score2});
    std.debug.print("Num lines read: {}\n", .{numLines});
}

test "hash map" {
    // Hash test file - read in each line, compute its score, then hash it
    std.debug.print("\n", .{});

    const table: std.StringHashMap(u32) = try prepareTable();
    try std.testing.expectEqual(rps("A X"), 4);
    try std.testing.expectEqual(rps("A Y"), 8);
    try std.testing.expectEqual(rps("A Z"), 3);
    try std.testing.expectEqual(rps("B X"), 1);
    try std.testing.expectEqual(rps("B Y"), 5);
    try std.testing.expectEqual(rps("B Z"), 9);
    try std.testing.expectEqual(rps("C X"), 7);
    try std.testing.expectEqual(rps("C Y"), 2);
    try std.testing.expectEqual(rps("C Z"), 6);
    try std.testing.expectEqual(table.get("A X").?, 4);
    try std.testing.expectEqual(table.get("B Y"), 5);
    try std.testing.expectEqual(table.get("B X"), 1);
}

test "test_data" {
    std.debug.print("\n", .{});

    var score: u32 = 0;
    var numLines: u32 = 0;

    const table: std.StringHashMap(u32) = try prepareTable();

    var file = try std.fs.cwd().openFile("02.test", .{.mode = std.fs.File.OpenMode.read_only});
    var reader = file.reader();
    var output: [5]u8 = undefined;
    var output_fbs = std.io.fixedBufferStream(&output);
    const writer = output_fbs.writer();

    while(true) {
        reader.streamUntilDelimiter(writer, '\n', null) catch {break;};
        var line = output_fbs.getWritten();
        numLines = numLines + 1;
        score = score + (table.get(line) orelse 0);
        output_fbs.reset();
    }
    
    try std.testing.expectEqual(score, 15);
}
