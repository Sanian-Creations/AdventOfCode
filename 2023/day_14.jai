main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input)); // Part 1: 107951
	print("Part 2: %\n", part_2(input)); // Part 2: 95736
}

part_1 :: (input: string) -> int {
	using grid := alloc_grid(grid_view(input));
	defer free(grid);

	tilt(grid, .NORTH);

	total := 0;
	for r: 0..rows-1 for c: 0..cols-1 {
		if grid.array[r * cols + c] == #char "O" then total += rows - r;
	}

	return total;
}

part_2 :: (input: string) -> int {
	grid := alloc_grid(grid_view(input));
	defer free(grid);

	memo: HT.Table(string, int);
	defer HT.deinit(*memo);

	states: [..]string;
	defer array_free(states);
	defer reset_temporary_storage();

	result: string;

	target_state_index :: 1_000_000_000-1;

	for 0..target_state_index {
		tilt(grid, .NORTH);
		tilt(grid, .WEST);
		tilt(grid, .SOUTH);
		tilt(grid, .EAST);

		// I think the table is relatively slow because of string hashing/comparison given these large grids.
		// Oh well.
		first_occurence, found := HT.table_find(*memo, cast(string)grid.array);
		if !found {
			copy := copy_temporary_string(cast(string)grid.array);
			array_add(*states, copy);
			HT.table_add(*memo, copy, it);
			continue;
		}

		cycles_per_repeat := it - first_occurence;
		remaining_cycles  := target_state_index - it;
		cycles_until_target_state := remaining_cycles % cycles_per_repeat;
		result = states[first_occurence + cycles_until_target_state];

		break;
	}

	total := 0;
	for r: 0..grid.rows-1 for c: 0..grid.cols-1 {
		if result[r * grid.cols + c] == #char "O" then total += grid.rows - r;
	}

	return total;
}

tilt :: (using grid: Grid(u8), $direction: enum{NORTH; EAST; SOUTH; WEST;}) {

	addr :: (r: int, c: int) -> *u8 #expand { return *array[r * cols + c]; }

	#if direction == .NORTH || direction == .SOUTH {
		backwards :: direction == .SOUTH;
		first_row := #ifx direction == .SOUTH then rows-1; else 0;
		last_row  := #ifx direction == .NORTH then rows-1; else 0;
		for c: 0..cols-1 {
			free_row := -1;
			for <=backwards r: first_row..last_row {
				if addr(r,c).* == {
					case #char"O";
						if free_row != -1 {
							addr(r,c).* = #char ".";
							addr(free_row, c).* = #char "O";
							free_row += #ifx direction == .NORTH then 1; else -1;
						}

					case #char"#"; free_row = -1;
					case #char"."; if free_row == -1 then free_row = r;
					case;
					assert(false, "unexpected character '%' at r %, c %\n", addr(r,c).*, r, c);
				}
			}
		}
	} else #if direction == .WEST || direction == .EAST {
		backwards :: direction == .EAST;
		first_col := #ifx direction == .EAST then cols-1; else 0;
		last_col  := #ifx direction == .WEST then cols-1; else 0;
		for r: 0..rows-1 {
			free_col := -1;
			for <=backwards c: first_col..last_col {
				if addr(r,c).* == {
					case #char"O";
						if free_col != -1 {
							addr(r,c).* = #char ".";
							addr(r, free_col).* = #char "O";
							free_col += #ifx direction == .WEST then 1; else -1;
						}

					case #char"#"; free_col = -1;
					case #char"."; if free_col == -1 then free_col = c;
					case; assert(false, "unexpected character '%'\n", addr(r,c).*);
				}
			}
		}
	} else #assert false;
}

testinput :: #string TESTINPUT
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
TESTINPUT;

#run example("1", 136, part_1(testinput));
#run example("2", 64, part_2(testinput));

HT :: #import "Hash_Table";
Hash :: #import "Hash";
#load "../aoc_util.jai";
