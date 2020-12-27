// Compile:
//     zig build-exe main.zig
// Use:
// ./main < input.txt
// Compiler version:
//     zig version
//     0.6.0

const std = @import("std");

fn MinMax(comptime T: type) type {
    return struct {
        min: T,
        max: T,
    };
}

fn DoublyLinkedCircularList(comptime T: type) type {
    return struct {
        pub const Node = struct {
            prev: ?*Node,
            next: ?*Node,
            value: T,
        };
        allocator: *std.mem.Allocator,
        node_map: std.AutoHashMap(T, *Node),
        head: ?*Node,

        pub fn get_node(self: DoublyLinkedCircularList(T), value: T) ?*Node {

            return self.node_map.getValue(value);

        }

        pub fn get_values_after(self: DoublyLinkedCircularList(T), value: T) !std.ArrayList(T) {
            const start_opt = self.get_node(value);
            var values = std.ArrayList(T).init(self.allocator);

            if (start_opt) |start| {
                var current_opt = start.next;
                while (current_opt != start) {
                    if (current_opt) |current| {
                        try values.append(current.value);
                        current_opt = current.next;
                    }
                }
            }

            return values;
        }

        pub fn get_min_and_max_value(self: DoublyLinkedCircularList(T)) MinMax(T) {
            var max_value: ?T = null;
            var min_value: ?T = null;

            const head = self.head.?;

            if (max_value == null or head.value > max_value.?) {
                max_value = head.value;
            }
            if (min_value == null or head.value < min_value.?) {
                min_value = head.value;
            }

            var current: ?*Node = head.next;

            while (current != null and current != self.head) {
                if (current.?.value > max_value.?) {
                    max_value = current.?.value;
                }
                if (current.?.value < min_value.?) {
                    min_value = current.?.value;
                }
                current = current.?.next;
            }

            return MinMax(T) {
                .min = min_value.?,
                .max = max_value.?,
            };
        }

        pub fn insert_values(self: *DoublyLinkedCircularList(T), preceeding_node: *Node, values: []const T) !void {
            const new_last = preceeding_node.next.?;
            new_last.prev = null;

            var current_prev = preceeding_node;
            for (values) |v| {
                const item = try self.allocator.create(Node);
                item.value = v;
                item.prev = current_prev;
                _ = try self.node_map.put(v, item);

                current_prev.next = item;
                current_prev = item;
            }

            current_prev.next = new_last;
            new_last.prev = current_prev;
        }

        pub fn remove_after(self: *DoublyLinkedCircularList(T), start_value: T, count: usize) !std.ArrayList(T) {
            var set_head = false;

            var node_to_remove: *Node = self.get_node(start_value).?.next.?;

            var removed_values = std.ArrayList(T).init(self.allocator);
            try removed_values.append(node_to_remove.value);

            const pre_node = node_to_remove.prev.?;

            var i: usize = 0;
            while (i < count - 1) : (i += 1) {
                if (node_to_remove == self.head) {
                    set_head = true;
                }

                node_to_remove = node_to_remove.next.?;
                try removed_values.append(node_to_remove.value);
            }

            if (node_to_remove == self.head) {
                set_head = true;
            }

            for (removed_values.items) |rv| {
                _ = self.node_map.remove(rv);
            }

            const new_next = node_to_remove.next.?;

            new_next.prev = pre_node;
            pre_node.next = new_next;

            self.head = (if(set_head) new_next else self.head.?);
            return removed_values;
        }

        pub fn print(self: DoublyLinkedCircularList(T)) void {
            var node = self.head;
            while (node != null) {
                const n = node.?;
                std.debug.warn("{}", .{n.value});

                node = n.next;
                if (node == self.head) {
                    break;
                }
            }
            std.debug.warn("\n", .{});
        }
    };
}

fn build_list(comptime T: type, allocator: *std.mem.Allocator, input: []const T) !DoublyLinkedCircularList(T) {

    var head: ?*DoublyLinkedCircularList(T).Node = null;
    var prev: ?*DoublyLinkedCircularList(T).Node = null;
    var last_item: ?*DoublyLinkedCircularList(T).Node = null;
    var node_map = std.AutoHashMap(T, *DoublyLinkedCircularList(T).Node).init(allocator);

    for (input) |number| {

        const item = try allocator.create(DoublyLinkedCircularList(T).Node);
        item.value = number;
        item.prev = prev;
        item.next = null;
        _ = try node_map.put(number, item);

        if (prev) |p| {
            p.next = item;
        }
        prev = item;

        if (head == null) {
            head = item;
        }
        last_item = item;
    }

    if (head) |h| {
        h.prev = last_item;
    }
    if (last_item) |li| {
        li.next = head;
    }

    return DoublyLinkedCircularList(T) {
        .allocator = allocator,
        .head = head,
        .node_map = node_map,
    };
}

fn get_destination_entry(comptime T: type, numbers: *DoublyLinkedCircularList(T), min_max: MinMax(T), current_cup: T) *DoublyLinkedCircularList(T).Node {
    var destination_value = current_cup - 1;
    var destination_entry: ?*DoublyLinkedCircularList(T).Node = null;
    while (destination_entry == null) {
        if (destination_value < min_max.min) {
            destination_value = min_max.max;
        }

        destination_entry = numbers.get_node(destination_value);
        if (destination_entry == null) {
            destination_value -= 1;
        }
    }
    return destination_entry.?;
}


fn part1(allocator: *std.mem.Allocator, numbers: []const u8) !std.ArrayList(u8) {
    var list = try build_list(u8, allocator, numbers);
    const min_max = list.get_min_and_max_value();

    var current_cup: u8 = numbers[0];
    var moves: u32 = 0;
    while (moves < 100) : (moves += 1) {
        const cups_removed = try list.remove_after(current_cup, 3);

        const destination_entry = get_destination_entry(u8, &list, min_max, current_cup);

        try list.insert_values(destination_entry, cups_removed.items);

        current_cup = list.get_node(current_cup).?.next.?.value;
    }

    return try list.get_values_after(1);
}

fn part2_move(cups: *DoublyLinkedCircularList(u32), min_max: MinMax(u32), current_cup: u32) !u32 {
    const removed_values = try cups.remove_after(current_cup, 3);

    const destination_entry = get_destination_entry(u32, cups, min_max, current_cup);

    try cups.insert_values(destination_entry, removed_values.items);

    return cups.get_node(current_cup).?.next.?.value;
}

fn part2(allocator: *std.mem.Allocator, numbers: []const u8) !u64 {
    var part2_numbers = std.ArrayList(u32).init(allocator);
    for (numbers) |n| {
        try part2_numbers.append(n);
    }

    var index: u32 = 10;
    while (index <= 1000000) : (index += 1) {
        try part2_numbers.append(index);
    }

    var list = try build_list(u32, allocator, part2_numbers.items);
    const min_max = list.get_min_and_max_value();

    var current_cup: u32 = numbers[0];
    var moves: u32 = 0;
    while (moves < 10000000) : (moves += 1) {
        current_cup = try part2_move(&list, min_max, current_cup);
    }

    const one = list.get_node(1).?;
    const next_to_one: u64 = one.next.?.value;
    const next_to_next_to_one: u64 = one.next.?.next.?.value;
    return next_to_one * next_to_next_to_one;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    const stdout = std.io.getStdOut().outStream();
    const stdin = std.io.getStdIn();

    var line_buffer: [20]u8 = undefined;
    const amt = try stdin.read(&line_buffer);
    if (amt == line_buffer.len) {
        try stdout.print("Input too long.\n", .{});
        return;
    }

    const line = std.mem.trimRight(u8, line_buffer[0..amt], "\n");
    var numbers = std.ArrayList(u8).init(allocator);
    for (line) |c| {
        try numbers.append(c - 48);
    }

    const values_after_1 = try part1(allocator, numbers.items);
    try stdout.print("Cup values after 100 moves, excluding but starting at 1; Part 1: ", .{});
    for (values_after_1.items) |v| {
        try stdout.print("{}", .{v});
    }
    try stdout.print("\n", .{});

    const part2_solution = try part2(allocator, numbers.items);
    try stdout.print("Cup values after 1000000 moves etc.; Part 2: {}\n", .{part2_solution});
}
