main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input));
	print("Part 2: %\n", part_2(input));
}

part_1 :: (input: string) -> int {
	for :lines line, line_index: input {

	}
	return 0;
}

part_2 :: (input: string) -> int {
	return 0;
}


testinput :: #string TESTINPUT

TESTINPUT;

#run example("1", 0, part_1(testinput));
#run example("2", 0, part_2(testinput));


#load "../aoc_util.jai";
