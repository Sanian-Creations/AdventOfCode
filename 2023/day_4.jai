main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input)); // Part 1: 22674
	print("Part 2: %\n", part_2(input)); // Part 2: 5747443
}

part_1 :: (input: string) -> int {
	colon_index := S.find_index_from_left(input, #char ":", 0);
	pipe_index  := S.find_index_from_left(input, #char "|", colon_index);
	line_end    := move_right_while(input, pipe_index, c => c != #char "\r" && c != #char "\n");

	win_nums_start := colon_index + 2;
	win_nums_end   := pipe_index - 1;
	my_nums_start  := pipe_index + 2;
	my_nums_end    := line_end;

	win_nums_count := (win_nums_end - win_nums_start + 1) / 3;
	my_nums_count  := (my_nums_end  - my_nums_start  + 1) / 3;

	nums_buf := NewArray(win_nums_count + my_nums_count*2 + 1, int); defer array_free(nums_buf);
	win_nums := view(nums_buf, 0, win_nums_count);
	my_nums  := view(nums_buf, win_nums_count, my_nums_count);
	points   := view(nums_buf, win_nums_count + my_nums_count);

	// pre-calc points
	points[1] = 1;
	for 2..my_nums_count-1  points[it] = points[it-1]*2;

	read_nums :: (nums: string, buf: []int) {
		// Amount of numbers read is based on the capacity of the buffer
		for 0..buf.count-1 {
			buf[it] = string_to_int(view(nums, it * 3, 2));
		}
	}

	total := 0;

	for :lines line: input {
		read_nums(iview(line, win_nums_start, win_nums_end), win_nums);
		read_nums(iview(line, my_nums_start,  my_nums_end),  my_nums);

		winning_nums_count := 0;
		for my_nums {
			found, _ := array_find(win_nums, it);
			if found  winning_nums_count += 1;
		}
		total += points[winning_nums_count];
	}

	return total;
}

part_2 :: (input: string) -> int {
	colon_index := S.find_index_from_left(input, #char ":", 0);
	pipe_index  := S.find_index_from_left(input, #char "|", colon_index);
	line_end    := S.find_index_from_left(input, #char "\n", pipe_index);

	win_nums_start := colon_index + 2;
	win_nums_end   := pipe_index - 1;
	my_nums_start  := pipe_index + 2;
	my_nums_end    := line_end - ifx input[line_end-1] == #char "\r" then 1;

	win_nums_count := (win_nums_end - win_nums_start + 1) / 3;
	my_nums_count  := (my_nums_end  - my_nums_start  + 1) / 3;

	total_cards_count := input.count / (line_end + 1);

	nums_buf    := NewArray(win_nums_count + my_nums_count + total_cards_count, int); defer array_free(nums_buf);
	win_nums    := view(nums_buf, 0, win_nums_count);
	my_nums     := view(nums_buf, win_nums_count, my_nums_count);
	extra_cards := view(nums_buf, win_nums_count + my_nums_count, total_cards_count);

	read_nums :: (nums: string, buf: []int) {
		// Amount of numbers read is based on the capacity of the buffer
		for 0..buf.count-1 {
			buf[it] = string_to_int(view(nums, it * 3, 2));
		}
	}

	total := 0;

	for :lines line, card_index: input {
		read_nums(iview(line, win_nums_start, win_nums_end), win_nums);
		read_nums(iview(line, my_nums_start,  my_nums_end),  my_nums);

		winning_nums_count := 0;
		for my_nums {
			found, _ := array_find(win_nums, it);
			if found  winning_nums_count += 1;
		}

		this_card_count := 1 + extra_cards[card_index];
		for 1..winning_nums_count {
			// "Cards will never make you copy a card past the end of the table", shouldn't go out of bounds.
			extra_cards[card_index + it] += this_card_count;
		}

		total += this_card_count;
	}

	return total;
}


testinput :: #string TESTINPUT
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
TESTINPUT;

#run example("1", part_1, 13, testinput);
#run example("2", part_2, 30, testinput);


#load "../aoc_util/aoc_util.jai";
