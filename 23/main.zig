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
fn RemoveAfterResult(comptime T: type) type {
    return struct {
        removed_values: std.ArrayList(T),
        new_head: *DoublyLinkedCircularList(T).Node,
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
        head: ?*Node,

        pub fn get_node(self: DoublyLinkedCircularList(T), value: T) ?*Node {

            const head = self.head.?;

            if (head.value == value) {
                return head;
            }

            var current = head.next;
            while (current != null and current != self.head) {
                if (current.?.value == value) {
                    return current.?;
                }
                current = current.?.next;
            }
            return null;
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

        pub fn insert_values(self: DoublyLinkedCircularList(T), preceeding_node: *Node, values: []const u8) !void {
            const new_last = preceeding_node.next.?;
            new_last.prev = null;

            var current_prev = preceeding_node;
            for (values) |v| {
                const item = try self.allocator.create(Node);
                item.value = v;
                item.prev = current_prev;

                current_prev.next = item;
                current_prev = item;
            }

            current_prev.next = new_last;
            new_last.prev = current_prev;
        }

        pub fn remove_after(self: DoublyLinkedCircularList(T), start_value: T, count: usize) !RemoveAfterResult(T) {
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

            const new_next = node_to_remove.next.?;

            new_next.prev = pre_node;
            pre_node.next = new_next;

            return RemoveAfterResult(T){
                .removed_values = removed_values,
                .new_head = (if(set_head) new_next else self.head.?),
            };
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

fn build_list(allocator: *std.mem.Allocator, input: []const u8) !DoublyLinkedCircularList(u8) {

    var head: ?*DoublyLinkedCircularList(u8).Node = null;
    var prev: ?*DoublyLinkedCircularList(u8).Node = null;
    var last_item: ?*DoublyLinkedCircularList(u8).Node = null;

    for (input) |number| {

        const item = try allocator.create(DoublyLinkedCircularList(u8).Node);
        item.value = number;
        item.prev = prev;
        item.next = null;

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

    return DoublyLinkedCircularList(u8) {
        .allocator = allocator,
        .head = head,
    };
}

fn part1(allocator: *std.mem.Allocator, numbers: [] const u8) !std.ArrayList(u8) {
    var list = try build_list(allocator, numbers);

    const min_max = list.get_min_and_max_value();

    var current_cup: u8 = numbers[0];
    var moves: i32 = 0;

    while (moves < 100) {
        const cups_removed = try list.remove_after(current_cup, 3);
        list.head = cups_removed.new_head;

        var destination_value = current_cup - 1;
        var destination_entry: ?*DoublyLinkedCircularList(u8).Node = null;
        while (destination_entry == null) {
            if (destination_value < min_max.min) {
                destination_value = min_max.max;
            }

            destination_entry = list.get_node(destination_value);
            if (destination_entry == null) {
                destination_value -= 1;
            }
        }

        try list.insert_values(destination_entry.?, cups_removed.removed_values.items);

        current_cup = list.get_node(current_cup).?.next.?.value;

        moves += 1;
    }

    return try list.get_values_after(1);
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
    std.debug.warn("Cup values after 100 moves, excluding but starting at 1; Part 1: ", .{});
    for (values_after_1.items) |v| {
        std.debug.warn("{}", .{v});
    }
    std.debug.warn("\n", .{});

}
