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
		grid := text_grid(input);
		col_has_galaxies := NewArray(grid.width + grid.height, bool); defer array_free(col_has_galaxies);
		row_has_galaxies := chop_off_end(*col_has_galaxies, grid.height);


		for row: 0..grid.height-1 {
			for col: 0..grid.width-1 {
				if get(grid, row, col) == #char "#" {
					col_has_galaxies[col] = true;
					row_has_galaxies[row] = true;
				}
			}
		}

		add_offset := empty_space_multiplier-1;
		row_offset := 0;
		for row: 0..grid.height-1 {
			if !row_has_galaxies[row] { row_offset += add_offset; continue; }
			col_offset := 0;
			for col: 0..grid.width-1 {
				if !col_has_galaxies[col] { col_offset += add_offset; continue; }
				if get(grid, row, col) == #char "#" {
					array_add(*galaxies, .{row + row_offset, col + col_offset});
				}
			}
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
