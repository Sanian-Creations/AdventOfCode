main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input)); // Part 1: 67027
	print("Part 2: %\n", part_2(input)); // Part 2: 197291
}

part_1 :: (input: string) -> int { buf: [1]int; return top_N_total_calories(input, buf); }
part_2 :: (input: string) -> int { buf: [3]int; return top_N_total_calories(input, buf); }

top_N_total_calories :: (input: string, top: []int) -> int {
	current_total := 0;
	for :lines line: input {
		if !line {
			// Empty line means end of one elf's list
			insert_top(top, current_total);
			current_total = 0;
		} else current_total += string_to_int(line);
	}

	// Don't forget the last elf.
	insert_top(top, current_total);

	total := 0;
	for top total += it;
	return total;
}

insert_top :: (top: []int, val: int) {
	// Early exit if we can't insert anyway
	if top.count <= 0 || top[top.count-1] >= val return;

	// We know certainly that the last element is smaller,
	// so we can safely start the loop at the second-last
	i := top.count-2;
	while i >= 0 {
		if top[i] >= val then break;

		top[i+1] = top[i];
		i -= 1;
	}

	// Even if i is -1 (all values were smaller, or array was 1 wide)
	// then this still places the value at index 0.
	top[i+1] = val;
}


testinput :: #string TESTINPUT
1000
2000
3000

4000

5000
6000

7000
8000
9000

10000
TESTINPUT;

#run example("1", 24000, part_1(testinput));
#run example("2", 45000, part_2(testinput));


#load "../aoc_util.jai";
