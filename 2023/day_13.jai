main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input)); // Part 1: 29165
	print("Part 2: %\n", part_2(input)); // Part 2: 32192
}

part_1 :: (input__: string) -> int {
	input := input__;
	total := 0;

	columns: [..]u8;
	defer array_free(columns);

	while next_text_grid := input.count > 0 {
		gv := consume_grid_view(*input);

		prev_row := get_row(gv, 0);
		for r: 1..gv.height-1 { // loop rows
			row := get_row(gv, r);
			if row != prev_row {
				prev_row = row;
				continue;
			}

			rows_below := (gv.height-1) - r;
			rows_above := r-1;
			rows_to_compare := min(rows_below, rows_above);

			for 1..rows_to_compare {
				if get_row(gv, r+it) != get_row(gv, r-1-it) {
					continue r;
				}
			}
			total += r * 100;
			continue next_text_grid;
		}

		array_resize(*columns,  gv.height * 4);
		current_col := cast(string)cast([]u8)columns;
		prev_col    := cast(string)chop_off_end(*cast([]u8)current_col, gv.height);
		cmp1        := cast(string)chop_off_end(*cast([]u8)current_col, gv.height);
		cmp2        := cast(string)chop_off_end(*cast([]u8)current_col, gv.height);

		get_col(gv, 0, prev_col);
		for c: 1..gv.width-1 {
			get_col(gv, c, current_col);
			if current_col != prev_col {
				tmp := current_col;
				current_col = prev_col;
				prev_col = tmp;
				continue;
			}

			cols_right := (gv.width-1) - c;
			cols_left  := c-1;
			cols_to_compare := min(cols_right, cols_left);

			for 1..cols_to_compare {
				get_col(gv, c+it, cmp1);
				get_col(gv, c-1-it, cmp2);
				if cmp1 != cmp2 {
					continue c;
				}
			}
			total += c;
			continue next_text_grid;
		}
		assert(false, "this grid has no reflection");
	}

	return total;
}

part_2 :: (input__: string) -> int {
	// Laziest solution EVER
	// copy paste the same code once to find the initial reflection point, remember it.
	// copy paste the same code again, this time inside a loop that one-by-one flips every single character,
	// until we find a new reflection point that is not the same one as before.
	// It works though, and it's not slow since the grids are not that big. It's instant even for debug build.
	// string comparisons may also use SIMD...? I'm not sure, but that may help with speed too.

	// This one may be fun to optimize in the future. I think you should be able to turn every grid into an array of integers,
	// since every grid only contains '.' (0) and '#' (1). Comparing integers is certainly less expensive than strings.
	// They should also certainly fit inside a 64-bit int since the biggest heights/widths (from my input) were only 17 wide/high.
	// Also to avoid copying individual chars/bits into a new array/int every time to compare columns I should just make a copy of the grid
	// that is turned on its side so that ITS rows are actually the same as the columns in the other one. Its indeces are [c, r] instead of [r, c].

	input := input__;

	total := 0;

	columns: [..]u8;
	defer array_free(columns);

	while next_text_grid := input.count > 0 {
		gv := consume_grid_view(*input);

		initial := 0;
		while get_initial_reflection := true { // this loop is here only to function as a goto by calling break on it.

			prev_row := get_row(gv, 0);
			for r: 1..gv.height-1 { // loop rows
				row := get_row(gv, r);
				if row != prev_row {
					prev_row = row;
					continue;
				}

				rows_below := (gv.height-1) - r;
				rows_above := r-1;
				rows_to_compare := min(rows_below, rows_above);

				for 1..rows_to_compare {
					if get_row(gv, r+it) != get_row(gv, r-1-it) {
						continue r;
					}
				}
				initial = r * 100;
				break get_initial_reflection;
			}

			array_resize(*columns,  gv.height * 4);
			current_col := cast(string)cast([]u8)columns;
			prev_col    := cast(string)chop_off_end(*cast([]u8)current_col, gv.height);
			cmp1        := cast(string)chop_off_end(*cast([]u8)current_col, gv.height);
			cmp2        := cast(string)chop_off_end(*cast([]u8)current_col, gv.height);

			get_col(gv, 0, prev_col);
			for c: 1..gv.width-1 {
				get_col(gv, c, current_col);
				if current_col != prev_col {
					tmp := current_col;
					current_col = prev_col;
					prev_col = tmp;
					continue;
				}

				cols_right := (gv.width-1) - c;
				cols_left := c-1;
				cols_to_compare := min(cols_right, cols_left);

				for 1..cols_to_compare {
					get_col(gv, c+it, cmp1);
					get_col(gv, c-1-it, cmp2);
					if cmp1 != cmp2 {
						continue c;
					}
				}
				initial = c;
				break get_initial_reflection;
			}

			assert(false, "this grid has no reflection");
		} // get_initial_reflection

		HASH :u8: #char "#";
		DOT :u8: #char ".";
		for sm_r: 0..gv.height-1 { // smudge-row
			for sm_c: 0..gv.width-1 { // smudge-column
				char_str_index := sm_r * gv.line_len + sm_c;
				original_char := gv.source[char_str_index];
				gv.source[char_str_index] = ifx original_char == DOT then HASH else DOT;
				defer gv.source[char_str_index] = original_char;

				// ---
				prev_row := get_row(gv, 0);
				for r: 1..gv.height-1 { // loop rows
					if initial == r * 100 then continue;
					row := get_row(gv, r);
					if row != prev_row {
						prev_row = row;
						continue;
					}

					rows_below := (gv.height-1) - r;
					rows_above := r-1;
					rows_to_compare := min(rows_below, rows_above);

					for 1..rows_to_compare {
						if get_row(gv, r+it) != get_row(gv, r-1-it) {
							continue r;
						}
					}
					total += r * 100;
					continue next_text_grid;
				}

				array_resize(*columns,  gv.height * 4);
				current_col := cast(string)cast([]u8)columns;
				prev_col    := cast(string)chop_off_end(*cast([]u8)current_col, gv.height);
				cmp1        := cast(string)chop_off_end(*cast([]u8)current_col, gv.height);
				cmp2        := cast(string)chop_off_end(*cast([]u8)current_col, gv.height);

				get_col(gv, 0, prev_col);
				for c: 1..gv.width-1 {
					if initial == c then continue;
					get_col(gv, c, current_col);
					if current_col != prev_col {
						tmp := current_col;
						current_col = prev_col;
						prev_col = tmp;
						continue;
					}

					cols_right := (gv.width-1) - c;
					cols_left := c-1;
					cols_to_compare := min(cols_right, cols_left);

					for 1..cols_to_compare {
						get_col(gv, c+it, cmp1);
						get_col(gv, c-1-it, cmp2);
						if cmp1 != cmp2 {
							continue c;
						}
					}
					total += c;
					continue next_text_grid;
				}
				// ---

				// no new mirror point... repeat!
			}
		}
	}

	return total;
}


testinput :: #string TESTINPUT
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
TESTINPUT;

#run example("1", 405, part_1(testinput));
#run example("2", 400, part_2(testinput));


#load "../aoc_util.jai";
