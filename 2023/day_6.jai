main :: () {
	input, ok := read_input();
	if !ok return;

	print_expr(part_1(input));
	print_expr(part_2(input));
}

calc_dist :: (racetime: int, btntime: int) -> int {
	return (racetime - btntime) * btntime;
}

part_1 :: (input: string) -> int {
	start_index :: "Distance:  ".count;
	line1 := view(consume_one_line(*input), start_index);
	line2 := view(consume_one_line(*input), start_index);

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

part_2 :: (input: string) -> int {
	parse_as_one_number :: (str: string) -> int {
		total := 0;
		multiplier := 1; // 1, 10, 100 etc
		for < cast([]u8) str if is_digit(it) {
			total += (it - #char "0") * multiplier;
			multiplier *= 10;
		}
		return total;
	}

	start_index :: "Distance:  ".count;
	race_time   := parse_as_one_number(view(consume_one_line(*input), start_index));
	record_dist := parse_as_one_number(view(consume_one_line(*input), start_index));

	min := 0;
	max := race_time/2;

	while min+1 != max {
		btntime_guess := (max - min)/2 + min;
		if record_dist < calc_dist(race_time, btntime_guess)
			then max = btntime_guess;
			else min = btntime_guess;
	}

	margin := race_time - max * 2 + 1;

	return margin;
}

testinput :: #string TESTINPUT
Time:      7  15   30
Distance:  9  40  200
TESTINPUT;

#run example("1", part_1, 288, testinput);
#run example("2", part_2, 71503, testinput);


#load "../aoc_util/aoc_util.jai";
