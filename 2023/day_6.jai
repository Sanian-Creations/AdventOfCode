main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input)); // Part 1: 2065338
	print("Part 2: %\n", part_2(input)); // Part 2: 34934171
}

part_1 :: (input__: string) -> int {
	input := input__;

	start_index :: "Distance: ".count;
	line1 := view(consume_line(*input), start_index);
	line2 := view(consume_line(*input), start_index);

	total := 1;
	while 1 {
		race_time, ok, line1=  := string_to_int(line1);
		if !ok break;
		record_dist, _, line2= := string_to_int(line2);

		// I could have used some abc-formula-shit to figure out in one calculation how long the recordholder pressed the button...
		// Screw that. I'm binary searching this mf.
		// min and max both work their way towards the value of how long the recordholder pressed the button.
		// By the end, max is the lowest time that will beat the record, min is one lower and loses.
		// Then the amount of ways to win (margin) is a single calculation.
		min := 0;
		max := race_time/2;

		while min+1 != max {
			btntime_guess := (max - min)/2 + min;
			if record_dist < calc_dist(race_time, btntime_guess)
				then max = btntime_guess;
				else min = btntime_guess;
		}

		margin := race_time - max * 2 + 1;
		total *= margin;
	}

	return total;
}

part_2 :: (input__: string) -> int {
	input := input__;

	parse_as_one_number :: (str: string) -> int {
		total := 0;
		multiplier := 1; // 1, 10, 100 etc
		for < cast([]u8) str if is_digit(it) {
			total += (it - #char "0") * multiplier;
			multiplier *= 10;
		}
		return total;
	}

	start_index :: "Distance: ".count;
	race_time   := parse_as_one_number(view(consume_line(*input), start_index));
	record_dist := parse_as_one_number(view(consume_line(*input), start_index));

	min := 0;
	max := race_time/2;

	while min+1 != max {
		btntime_guess := (max - min)/2 + min;
		if record_dist < calc_dist(race_time, btntime_guess)
			then max = btntime_guess;
			else min = btntime_guess;
	}

	return race_time - max * 2 + 1;
}

calc_dist :: (racetime: int, btntime: int) -> int {
	return (racetime - btntime) * btntime;
}


testinput :: #string TESTINPUT
Time:      7  15   30
Distance:  9  40  200
TESTINPUT;

#run example("1", 288, part_1(testinput));
#run example("2", 71503, part_2(testinput));


#load "../aoc_util.jai";
