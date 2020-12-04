// Compile:
//     rustc main.rs
// Use:
//     ./main < input.txt

use std::io::{self, BufRead};
use std::vec::Vec;

fn main() {
	let (map, map_width) = read_input();
	part_1(&map, map_width);
	part_2(&map, map_width);
}

fn read_input() -> (Vec<Vec<bool>>, usize) {
	let mut rows = Vec::new();

	let mut first_row_width: Option<usize> = None;

	let stdin = io::stdin();
	for wrapped_line in stdin.lock().lines() {
		let line = wrapped_line.unwrap();

		if first_row_width == None {
			first_row_width = Some(line.len());
		} else if first_row_width != Some(line.len()) {
			panic!("Invalid input");
		}

		let mut columns = Vec::new();

		for item in line.chars() {
			columns.push(item == '#')
		}

		rows.push(columns);
	}

	(rows, first_row_width.unwrap())
}

fn part_1(map: &Vec<Vec<bool>>, map_width: usize) {
	let tree_count = traverse_map(&map, map_width, 3, 1);
	println!("Number of trees when traversing (3, 1); Part 1: {}", tree_count)
}

fn part_2(map: &Vec<Vec<bool>>, map_width: usize) {
	let mut tree_count = 1;
	tree_count *= traverse_map(&map, map_width, 1, 1);
	tree_count *= traverse_map(&map, map_width, 3, 1);
	tree_count *= traverse_map(&map, map_width, 5, 1);
	tree_count *= traverse_map(&map, map_width, 7, 1);
	tree_count *= traverse_map(&map, map_width, 1, 2);

	println!("Number of trees when traversing; Part 2: {}", tree_count)
}

fn traverse_map(map: &Vec<Vec<bool>>, map_width: usize, dir_x: usize, dir_y: usize) -> u32 {

	let (mut pos_x, mut pos_y) = (0, 0);
	let target_y = map.len();
	let mut tree_count = 0;

	while pos_y < target_y {

		let wrapped_x = pos_x % map_width;

		let has_tree = map[pos_y][wrapped_x];
		if has_tree {
			tree_count += 1;
		}

		pos_x += dir_x;
		pos_y += dir_y;
	}

	tree_count
}
