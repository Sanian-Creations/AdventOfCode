main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input)); // Part 1: 535351
	print("Part 2: %\n", part_2(input)); // Part 2: 87287096
}

part_1 :: (input: string) -> int {

	total := 0;
	line_length := 1 + S.find_index_from_left(input, #char "\n");

	is_symbol :: (c: u8) -> bool { // anything other than digit, '.' or newline
		return !is_digit(c) && c != #char "." && c != #char "\r" && c != #char "\n";
	}

	prev_char_was_digit := false;
	num_start := 0;
	for cast([]u8) input {
		on_digit := is_digit(it);
		defer prev_char_was_digit = on_digit;

		if on_digit {
			if !prev_char_was_digit  num_start = it_index;
		} else {
			if prev_char_was_digit {
				left  := num_start - 1;
				right := it_index;
				num   := string_to_int(iview(input, num_start, right));

				if left > 0 && is_symbol(input[left])             { total += num; continue it; }
				if right < input.count && is_symbol(input[right]) { total += num; continue it; }

				for s: max(0, left - line_length)..right - line_length {
					if is_symbol(input[s]) { total += num; continue it; }
				}
				for s: left + line_length..min(input.count-1, right + line_length) {
					if is_symbol(input[s]) { total += num; continue it; }
				}
			}
		}
	}

	return total;
}

part_2 :: (input: string) -> int {

	total := 0;
	line_length := 1 + S.find_index_from_left(input, #char "\n");

	for cog, cog_index: cast([]u8) input {
		if cog != #char "*" continue;

		parts: Fixed_Size_Stack(2, int);
		// Although there can technically be 6 parts connected to a cog,
		// it seems that no cog is connected to more than 2 parts.
		// It's easily accounted for though, just change the stack size and remove the early continues.

		check_row :: (start: int, end: int) #expand {
			for start..end {
				if !is_digit(input[it]) continue;
				num_start := find_num_start(input, it);
				num_end   := find_num_end(input, it + 1);
				num       := string_to_int(iview(input, num_start, num_end));
				push(*parts, num);
				if parts.count == 2 { total += parts[0] * parts[1]; continue cog; }
				it = num_end; // ensure we don't count the same part twice
			}
		}

		left  := cog_index - 1;
		right := cog_index + 1;

		if left > 0 && is_digit(input[left]) {
			num_start := find_num_start(input, left);
			num       := string_to_int(iview(input, num_start, cog_index));
			push(*parts, num);
		}

		if right < input.count && is_digit(input[right]) {
			num_end := find_num_end(input, right + 1);
			num     := string_to_int(iview(input, right, num_end));
			push(*parts, num);
			if parts.count == 2 { total += parts[0] * parts[1]; continue cog; }
		}

		// rows above and below
		check_row(max(left - line_length, 0),     right - line_length);
		check_row(    left + line_length,     min(right + line_length, input.count-1));
	}

	return total;
}


testinput :: #string TESTINPUT
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
TESTINPUT;

#run example("1", 4361, part_1(testinput));
#run example("2", 467835, part_2(testinput));


#load "../aoc_util.jai";
