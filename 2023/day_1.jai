main :: () {
	input, ok := read_input();
	if !ok return;

	print_expr(part_1(input));
	print_expr(part_2(input));
}

part_1 :: (input: string) -> int {
	digit_to_int :: (digit: u8) -> int {
		return digit - #char "0";
	}

	total := 0;
	for :lines line, line_num: input {
		first_digit, last_digit: u8;
		for   cast([]u8) line if is_digit(it) { first_digit = it; break; }
		for < cast([]u8) line if is_digit(it) { last_digit  = it; break; }
		value := 10 * digit_to_int(first_digit) + digit_to_int(last_digit);
		total += value;
	}

	return total;
}

part_2 :: (input: string) -> int {
	check_digit :: (char: u8, num: *int) -> bool {
		if is_digit(char) {
			num.* = char - #char "0";
			return true;
		} else return false;
	}
	check_spelled_number :: (line: string, char_index: int, num: *int) -> bool {
		numbers :: string.["one", "two", "three", "four", "five", "six", "seven", "eight","nine"];

		for numbers if char_index + it.count <= line.count && view(line, char_index, it.count) == it {
			num.* = it_index + 1;
			return true;
		}
		return false;
	}

	total := 0;
	for :lines line, line_num: input {
		num1, num2: int;
		for   cast([]u8) line if check_digit(it, *num1) || check_spelled_number(line, it_index, *num1) break;
		for < cast([]u8) line if check_digit(it, *num2) || check_spelled_number(line, it_index, *num2) break;
		value := 10 * num1 + num2;
		total += value;
	}

	return total;
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


#load "../aoc_util/aoc_util.jai";