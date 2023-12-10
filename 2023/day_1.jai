main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input)); // Part 1: 54634
	print("Part 2: %\n", part_2(input)); // Part 2: 53855
}

part_1 :: (input: string) -> int {
	total := 0;

	for :lines line: input {
		first_num, last_num: int;
		for   cast([]u8) line if check_digit(it, *first_num) break;
		for < cast([]u8) line if check_digit(it, *last_num)  break;
		total += 10 * first_num + last_num;
	}

	return total;
}

part_2 :: (input: string) -> int {

	total := 0;
	for :lines line: input {
		first_num, last_num: int;
		for   cast([]u8) line if check_digit(it, *first_num) || check_spelled_number(line, it_index, *first_num) break;
		for < cast([]u8) line if check_digit(it, *last_num)  || check_spelled_number(line, it_index, *last_num) break;
		total += 10 * first_num + last_num;
	}

	return total;
}

check_digit :: (char: u8, num: *int) -> bool {
	if is_digit(char) {
		num.* = char - #char "0";
		return true;
	} else return false;
}

check_spelled_number :: (line: string, char_index: int, num: *int) -> bool {
	numbers :: string.["one", "two", "three", "four", "five", "six", "seven", "eight","nine"];
	for numbers {
		here := iview(line, char_index, min(char_index + it.count, line.count), false);
		if it == here {
			num.* = it_index + 1;
			return true;
		}
	}
	return false;
}


#run example("1", part_1, 142, #string TESTINPUT
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
TESTINPUT);

#run example("2", part_2, 281, #string TESTINPUT
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
TESTINPUT);


#load "../aoc_util.jai";