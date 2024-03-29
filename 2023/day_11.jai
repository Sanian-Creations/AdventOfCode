main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input));
	print("Part 2: %\n", part_2(input));
}

part_1 :: (input: string) -> int { return same_calculation(input, 2); }
part_2 :: (input: string) -> int { return same_calculation(input, 1_000_000); }

same_calculation :: (input: string, empty_space_multiplier: int) -> int {
	galaxies: [..] Galaxy; defer array_free(galaxies);

	{
		grid := grid_view(input);
		row_map := NewArray(grid.height + grid.width, int); defer array_free(row_map);
		col_map := chop_off_end(*row_map, grid.width);

		for row: 0..grid.height-1 for col: 0..grid.width-1 {
			if get(grid, row, col, false) == #char "#" {
				col_map[col] = 1;
				row_map[row] = 1;
				array_add(*galaxies, .{row, col});
			}
		}

		{ prev := 0; for * row_map { prev, it.* = prev + ifx it.* then 1 else empty_space_multiplier; } }
		{ prev := 0; for * col_map { prev, it.* = prev + ifx it.* then 1 else empty_space_multiplier; } }

		for * galaxies {
			it.*.row = row_map[it.row];
			it.*.col = col_map[it.col];
		}
	}

	total := 0;
	for galaxies for other: it_index+1..galaxies.count-1 {
		total += distance(it, galaxies[other]);
	}

	return total;
}

Galaxy :: struct {
	row, col: int;
}

distance :: (a: Galaxy, b: Galaxy) -> int {
	return abs(a.col - b.col) + abs(a.row - b.row);
}


testinput :: #string TESTINPUT
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
TESTINPUT;

#run example("1", 374, part_1(testinput));
#run example("2a", 1030, same_calculation(testinput, 10));
#run example("2b", 8410, same_calculation(testinput, 100));


#load "../aoc_util.jai";
