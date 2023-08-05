const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stderr = std.debug;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const FileOpenError = error{FileNotFound};

// Leaving this block here for future reference.
//// From the documentation in the standard library.
//// Use to generate a comparator function for a given type, .e., `maxArg(u16, slice, {}, asc(u16))`
//pub fn asc(comptime T: type) fn (void, T, T) bool {
//    return struct {
//        pub fn inner(_: void, a: T, b: T) bool {
//            return a < b;
//        }
//    }.inner;
//}
//
//const asc_u32 = asc(u32);
//
//// Look into: https://ciesie.com/post/zig_learning_01/
//fn countElves(name: []const u8) !usize {
//    var numElves: u16 = 1;
//    var buf: [10]u8 = undefined;
//
//    // Open a file, read through for the number of white space lines, and
//    // return that number + 1 as the number of elves
//    var file = std.fs.cwd().openFile(name, .{}) catch |err| {
//        stderr.print("Error! Encountered error:\n{}", .{err});
//        std.process.exit(1);
//    };
//
//    var buf_reader = std.io.bufferedReader(file.reader());
//    var in_stream = buf_reader.reader();
//
//    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
//        if (line.len == 0) {
//            numElves += 1;
//        } else {
//            continue;
//        }
//    }
//
//    return numElves;
//}
//
//pub fn main() !void {
//    const name: []const u8 = "food.txt";
//    const numElves: usize = try countElves(name);
//
//    // The number of elves isn't comptime known, so it will have to be
//    // allocated somehow. The line below won't work.
//    //var elfCals: [numElves]u32 = std.mem.zeroes([numElves]u32);
//    //
//    // Going to use an ArrayList
//    const gpa = std.heap.GeneralPurposeAllocator(.{}){};
//    var elfCals = try ArrayList(u32).initCapacity(gpa, numElves);
//    defer elfCals.deinit(); // Let the compiler handle freeing
//
//    var buf = std.mem.zeroes([10]u8);
//    var counter: usize = 0;
//    var val: @TypeOf(elfCals.items[0]) = 0;
//
//    var file = std.fs.cwd().openFile("food.txt", .{}) catch |err| {
//        stderr.print("Error! Encountered error:\n{}", .{err});
//        std.process.exit(1);
//    };
//    defer file.close();
//
//    var buf_reader = std.io.bufferedReader(file.reader());
//    var in_stream = buf_reader.reader();
//
//    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
//        if (line.len == 0) {
//            val = 0;
//            counter += 1;
//            //continue;
//        } else {
//            val = try std.fmt.parseInt(@TypeOf(val), line, 10);
//            elfCals.items[counter] += val;
//        }
//    }
//
//    for (elfCals.items, 0..) |elf, index| {
//        try stdout.print("Elf {} has {} calories.\n", .{index + 1, elf});
//    }
//
//    // Print the elf with the maximum number of calories
//    const elfisMaximus: usize = try std.sort.argMax(@TypeOf(elfCals.items[0]), elfCals.items, {}, asc_u32);
//    try stdout.print("\nElf {?} has the maximum # of calories at {}.\n",
//        .{elfisMaximus + 1, elfCals[elfisMaximus.?]});
//}

const data = @embedFile("food.txt");

pub fn main() !void {
    try stdout.print("===== Part 1 - Elf Calories =====\n", .{});
    const result = try part1();
    //try stdout.print("Result: {s}\n", .{try part1()});
    try stdout.print("Result: {}\t{}\t{}\n\n", .{ result[0], result[1], result[2] });

    try stdout.print("===== Part 2 - Elf Calories =====\n", .{});
    const sum = result[0] + result[1] + result[2];
    try stdout.print("Total calories of top 3: {}\n", .{sum});
}

// Given an array of values, figure out where the "new" value fits in
fn top3(max: *[3]u32, current: u32) void {
    // If greater than greatest element (at 0), bump down
    if (current > max[0]) {
        max[2] = max[1];
        max[1] = max[0];
        max[0] = current;
        // If greater than second greatest element
    } else if (current > max[1]) {
        max[2] = max[1];
        max[1] = current;
        // If greater than third greatest element
    } else if (current > max[2]) {
        max[2] = current;
    }
}

fn part1() ![3]u32 {
    //var lines = std.mem.tokenizeAny(u8, data, "\n");
    // `lines` is now a mem.TokenIterator type
    //stderr.print("Type of lines: {}\n", .{@TypeOf(lines)});

    var lines = std.mem.split(u8, data, "\n");
    var max: [3]u32 = .{ 0, 0, 0 };
    var current: u32 = 0;

    while (lines.next()) |line| {
        if (line.len == 0) {
            top3(&max, current);
            current = 0;
        } else {
            const num = try std.fmt.parseInt(u32, line, 10);
            current += num;
        }
    }

    top3(&max, current);
    return max;
    //    var previous_depth: u32 = undefined;
    //    previous_depth = try std.fmt.parseInt(u32, lines.next().?, 10);
    //
    //    var increases: u32 = 0;
    //
    //    // This basically just counts non-blank lines
    //    while (lines.next()) |line| {
    //        if (line.len == 0) {
    //
    //        } else {
    //            var current_depth = try std.fmt.parseInt(u32, line, 10);
    //            stderr.print("slice: {}\n", .{try std.fmt.parseInt(u32, line, 10)});
    //            if (current_depth > previous_depth) increases += 1;
    //            previous_depth = current_depth;
    //        }
    //    }
    //
    //    return increases;
}

const eql = std.mem.eql;
const test_allocator = std.testing.allocator;
const expect = std.testing.expect;

test "arraylist" {
    var list = try ArrayList(u32).initCapacity(test_allocator, 100);
    defer list.deinit();

    const listCapacity = list.capacity;
    try expect(listCapacity == 100);
    stderr.print("\nList capacity: {}\n", .{list.capacity});
}
