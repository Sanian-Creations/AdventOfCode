main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input)); // Part 1: 20513
	print("Part 2: %\n", part_2(input)); // Part 2: 15995167053923
}

part_1 :: (input__: string) -> int {
	input := input__; // param is immutable

	instructions := consume_one_line(*input);
	consume_one_line(*input);

	line_len    := S.find_index_from_left(input, #char "\n") + 1;
	node_count := input.count / line_len;

	nodes := NewArray(node_count, struct { left, right: s16; });
	defer array_free(nodes);

	ghost, end_index: s16;

	for 0..node_count-1 {
		line_start := input.data + it * line_len;

		if equal(name(line_start), cast([3]u8)"AAA") then ghost     = xx it;
		if equal(name(line_start), cast([3]u8)"ZZZ") then end_index = xx it;

		nodes[it].left  = xx find_name(input, line_len, node_count, left(line_start));
		nodes[it].right = xx find_name(input, line_len, node_count, right(line_start));
	}

	instr  := 0;
	steps  := 0;
	while ghost != end_index {
		if instr >= instructions.count  instr = 0;
		go_left := instructions[instr] == #char "L";
		instr += 1;
		steps += 1;
		ghost = ifx go_left then nodes[ghost].left else nodes[ghost].right;
	}

	return steps;
}

part_2 :: (input__: string) -> int {
	input := input__; // param is immutable

	instructions := consume_one_line(*input);
	consume_one_line(*input);

	line_len   := S.find_index_from_left(input, #char "\n") + 1;
	node_count := input.count / line_len;

	Node :: struct {
		left, right: s16;
		is_end: bool;
	}

	nodes := NewArray(node_count, Node);
	defer array_free(nodes);

	ghosts: [..] int;
	defer array_free(ghosts);

	for 0..node_count-1 {
		line_start := input.data + it * line_len;

		if name(line_start)[2] == #char "A" { array_add(*ghosts, it); }
		if name(line_start)[2] == #char "Z" { nodes[it].is_end = true; }

		nodes[it].left  = xx find_name(input, line_len, node_count, left(line_start));
		nodes[it].right = xx find_name(input, line_len, node_count, right(line_start));
	}

	for * ghosts {
		ghost := it.*;
		instr := 0;
		steps := 0;
		while 1 {
			if instr >= instructions.count  instr = 0;
			go_left := instructions[instr] == #char "L";
			instr += 1;
			steps += 1;
			ghost = ifx go_left then nodes[ghost].left else nodes[ghost].right;
			if nodes[ghost].is_end {
				it.* = steps; // set ghost value equal to the steps it took to get here.
				break;
			}
		}
	}

	// 'ghosts' no longer holds ghost indeces, but the cycle count for each ghost.
	// That is, according to these weird ass fucking assumptions
	// 1. The steps it took to get to each exit are also the same amount of steps that it will take to get there AGAIN if you keep going. (it's a cycle)
	// 2. The next time a ghost reaches an exit will be on the SAME instruction index as it was the time before.
	// 3. ONE ghost only ever passes ONE exit.

	// IF and ONLY IF you make those assumptions, will the following code work.
	total := ghosts[0];
	for 1..ghosts.count-1 total = lcm(total, ghosts[it]);
	return total;

	// Honestly this part 2 is wack, the explanation should have explicitly listed those assumptions, because they are quite a leap imo.
}

find_name :: (input: string, line_len: int, node_count: int, name_to_find: [3]u8) -> int {
	for 0..node_count-1 {
		if equal(name(input.data + it * line_len), name_to_find) then return it;
	}
	return -1;
}

equal :: (a: [3]u8, b: [3]u8) -> bool {
	return a[0]==b[0] && a[1]==b[1] && a[2]==b[2];
}

name ::  (line_start: *u8) -> [3]u8 #expand { return << cast(*[3]u8) (line_start); }
left ::  (line_start: *u8) -> [3]u8 #expand { return << cast(*[3]u8) (line_start + "AAA = (".count); }
right :: (line_start: *u8) -> [3]u8 #expand { return << cast(*[3]u8) (line_start + "AAA = (AAA, ".count); }


#run example("1", part_1, 6, #string TESTINPUT
LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
TESTINPUT);

#run example("2", part_2, 6, #string TESTINPUT
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
TESTINPUT);


#load "../aoc_util.jai";
