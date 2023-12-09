main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input)); // Part 1: 1762065988
	print("Part 2: %\n", part_2(input)); // Part 2: 1066
}

part_1 :: (input: string) -> int {

	nums: [..]int;
	defer array_free(nums);

	total := 0;

	for :lines line: input {
		defer nums.count = 0;
		read_nums(*nums, line);

		subview: []int = nums;
		while 1 {
			for 1..subview.count-1  subview[it-1] = subview[it] - subview[it-1];
			subview.count -= 1; // no longer include rightmost value
			if all_0(subview) break;
		}

		// point subview at all the non-0 values instead, to calculate the result
		subview = view_from(nums, subview.count);
		for subview  total += it;
	}

	return total;
}

part_2 :: (input: string) -> int {

	nums: [..]int;
	defer array_free(nums);

	total := 0;

	for :lines line: input {
		defer nums.count = 0;
		read_nums(*nums, line);

		subview: []int = nums;
		while 1 {
			for < subview.count-2..0  subview[it+1] -= subview[it];
			subview = view(subview, 1, false);
			if all_0(subview) break;
		}

		// point subview at all the non-0 values instead, to calculate the result
		subview = view(nums, 0, nums.count - subview.count);
		acc := 0;
		for < subview  acc = it - acc;
		total += acc;
	}

	return total;
}

read_nums :: (nums: *[..]int, line: string) {
	str := line;
	while 1 {
		num, ok, str= := string_to_int(str);
		if !ok break; array_add(nums, num);
	}
}

all_0 :: (arr: []int) -> bool {
	for arr if it != 0 return false;
	return true;
}

/*
part 1 does this:
input:  [(1  3  6  10  15   21)]      1  3  6 10  15   21
step 1: [(2  3  4   5   6)  21 ]      2  3  4  5   6   |
step 2: [(1  1  1   1)  6   21 ]      1  1  1  1   |   |
step 3: [(0  0  0)  1   6   21 ]      0  0  0  |   |   |
                                               1 + 6 + 21
part 2 does this:
input:  [(10  13  16  21  30  45)]     10   13   16  21  30  45
step 1: [ 10  (3   3   5   9  15)]      |    3    3   5   9  15
step 2: [ 10   3  (0   2   4   6)]      |    |    0   2   4   6
step 3: [ 10   3   0  (2   2   2)]      |    |    |   2   2   2
step 3: [ 10   3   0   2  (0   0)]      |    |    |   |   0   0
                                       10 - (3 - (0 - 2))
*/

testinput :: #string TESTINPUT
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
TESTINPUT;

#run example("1", part_1, 114, testinput);
#run example("2", part_2, 2, testinput);


#load "../aoc_util/aoc_util.jai";
