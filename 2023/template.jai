main :: () {
	input, ok := read_input();
	if !ok return;

	print_expr(part_1(input));
	print_expr(part_2(input));
}

part_1 :: (input: string) -> int {
	return 0;
}

part_2 :: (input: string) -> int {
	return 0;
}

#run example("1", part_1, 0, #string TESTINPUT

TESTINPUT);

#run example("2", part_2, 0, #string TESTINPUT

TESTINPUT);


#load "../aoc_util/aoc_util.jai";
