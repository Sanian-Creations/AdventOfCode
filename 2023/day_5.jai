main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input)); // Part 1: 462648396
	print("Part 2: %\n", part_2(input)); // Part 2: 2520479
}

part_1 :: (input__: string) -> int {
	input := input__;

	values: [..] int;

	first_line := consume_one_line(*input);
	advance(*first_line, "seeds:".count);
	while first_line {
		num, ok, first_line= := string_to_int(first_line);
		array_add(*values, num);
	}

	while input.count { // there must be a next stage
		consume_one_line(*input); // empty line
		consume_one_line(*input); // header "x-to-y map:"

		mapped_count := 0; // this many values are successfully mapped, and should not be mapped again this stage
		while input.count && is_digit(input[0]) {
			mrange := parse_map_range(consume_one_line(*input));

			for mapped_count .. values.count - 1 {
				v := values[it];
				if v < mrange.from || v >= mrange.to  continue;

				values[it] = values[mapped_count]; // move the first unmapped value over to the current index, which can be overwritten because we processed it.
				values[mapped_count] = v + mrange.mapping; // put the mapped value at the start of the values array so we can skip it next time.
				mapped_count += 1;
			}
		}
	}

	lowest := values[0];
	for 1..values.count-1  if values[it] < lowest  lowest = values[it];
	return lowest;
}

part_2 :: (input__: string) -> int {
	input := input__;

	ranges: [..] Range;

	first_line := consume_one_line(*input);
	advance(*first_line, "seeds:".count);
	while first_line {
		num1, _, first_line= := string_to_int(first_line);
		num2, _, first_line= := string_to_int(first_line);
		array_add(*ranges, .{ from = num1, to = num1 + num2 });
	}

	while input.count { // there must be a next stage
		consume_one_line(*input); // empty line
		consume_one_line(*input); // "x-to-y map:"

		mapped_count := 0; // this many ranges are successfully mapped, and should not be mapped again this stage
		while input.count && is_digit(input[0]) {
			mrange := parse_map_range(consume_one_line(*input));

			for mapped_count .. ranges.count - 1 { // skip past the ranges that are mapped, start at the first index that is not yet mapped.
				u := ranges[it];
				if !intersects(u, mrange) continue;

				// We can map (at least part of) this range! Here's how we'll do it:
				/*
					M = Mapped, U = Unmapped, mc = mapped_count

					ranges before
					[M, M, M, U2, U, U, U1, U]
					          mc=3      it=6
					ranges after
					[M, M, M, M1, U, U, U2, U, U1a, U1b]
					              mc=4  it=6

					U1 gets mapped and becomes M1, the old U1 is discarded. To make place for M1, U2 is moved to where U1 used to be.
					if U1 is unable to be completely mapped, U1a and/or U1b are appended to the end.
				*/

				mapped_overlap := Range.{
					from = max(mrange.from, u.from) + mrange.mapping,
					to   = min(mrange.to,   u.to)   + mrange.mapping,
				};

				// add unmapped parts of this range to the back of the list
				if u.from < mrange.from  then array_add(*ranges, .{u.from, mrange.from}); // lower  part of this range was not mapped
				if u.to > mrange.to      then array_add(*ranges, .{mrange.to, u.to});     // higher part of this range was not mapped

				ranges[it] = ranges[mapped_count];
				ranges[mapped_count] = mapped_overlap;
				mapped_count += 1;
			}
		}
	}

	lowest := ranges[0].from;
	for 1..ranges.count-1  if ranges[it].from < lowest then lowest = ranges[it].from;
	return lowest;
}

Range :: struct {
	from: int;
	to:   int;
}

Map_Range :: struct {
	#as using range: Range;
	mapping: int;
}

parse_map_range :: inline (line: string) -> Map_Range {
	num1_end := S.find_index_from_left(line, #char " ");
	num2_end := S.find_index_from_left(line, #char " ", num1_end+1);
	dest      := string_to_int(iview(line, 0, num1_end));
	src       := string_to_int(iview(line, num1_end+1, num2_end));
	range_len := string_to_int(iview(line, num2_end+1));

	return .{
		from    = src,
		to      = src + range_len,
		mapping = dest - src,
	};
}

intersects :: (a: Range, b: Range) -> bool {
	return a.from < b. to && a.to > b.from;
}


testinput :: #string TESTINPUT
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
TESTINPUT;

#run example("1", part_1, 35, testinput);
#run example("2", part_2, 46, testinput);


#load "../aoc_util.jai";
