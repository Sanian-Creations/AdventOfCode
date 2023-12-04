package aoc_util

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

// Procedure to read the input file and print clear messages if something goes wrong. 
// NOTE: Technically requires you call delete() on data, but for AoC we typically
//       only need one file for the whole duration of the program, so not freeing
//       it is totally fine.
read_input :: proc() -> (data: string, ok: bool) {
	if len(os.args) != 2 {
		fmt.printf("Please provide the input filename as a single argument.\n")
		return "", false
	}

	input := os.args[1]
	_data, _ok := os.read_entire_file(input)

	if !_ok {
		fmt.printf("Error reading file \"%v\"\n", input)
		return "", false
	}
	
	return string(_data), true
}

// Takes an int off the front of a string, gives back the parsed result
// NOTE: ignores '-' chars, only returns positive values
get_int :: proc(str: string) -> (result, int_strlen: int) {

	i := 0

	for ; i < len(str); i += 1 {
		if !is_digit(str[i]) { break } // find the end of the number
	}
	
	ok: bool 
	result, ok = strconv.parse_int(str[:i])
	return result, (ok ? i : 0)
}

// Same as get_int, but clips the characters containing the number off the string
consume_int_here :: proc(str: ^string) -> (result: int, ok: bool) {
	consumed: int
	result, consumed = get_int(str^)
	str^ = str[consumed:]
	return result, consumed != 0
}

// Clips off all characters up to and including the next number in a string.
consume_next_int :: proc(str: ^string) -> (result: int, ok: bool) {
	for i in 0..<len(str) {
		if is_digit(str[i]) {
			result, consumed := get_int(str[i:])
			str^ = str[i+consumed:]
			return result, consumed != 0
		}
	}
	return 0, false
}

// Shortens the given string until it has encountered len(target) numbers.
// Every number encountered is parsed and stored in the target slice.
consume_next_N_ints :: proc(str: ^string, target: []int) -> (ok: bool) {
	for i in 0..<len(target) {
		target[i], ok = consume_next_int(str)
		if !ok { return false }
	}
	return true
}

is_digit :: #force_inline proc(c: u8) -> bool {
	return c >= '0' && c <= '9'
}

// Splits a string in half on the first instance of a char/byte.
// Does not include the given character in the resulting 2 strings.
split_on_byte :: proc(str: string, split_on: u8) -> (str1, str2: string) {
	index := strings.index_byte(str, split_on)
	if index == -1 { return "", str }
	return str[:index], str[index+1:]
}

// Procedures for looping over all lines in a string.
// Of the string passed, one line is consumed every iteration, so if
// you wish to keep the original string, make a copy and pass that. 
// To loop with an index, a String_Iterator struct is required.
iter_lines :: proc{ iter_lines_basic, iter_lines_indexed }

iter_lines_basic :: proc(str: ^string) -> (line: string, ok: bool) {

	consumed: int
	line, consumed = get_line(str^)
	str^ = str[consumed:]
		
	return line, consumed != 0
}

// Get all characters up until the first newline, or end of string
// The returned string does not include the newline
// 'total_len' is the amount of bytes that were taken up by the line INCLUDING newline char(s)
get_line :: proc(str: string) -> (line: string, total_len: int) {
	
	i := strings.index_byte(str, '\n')

	if i != -1 {
		// Account for files using \r\n as newline
		// AoC files all use Unix file format and don't have this problem,
		// but files made by myself do have this problem (such as ones I paste the examples into)
		line = (i > 0 && str[i-1] == '\r') ? str[:i-1] : str[:i]
		total_len = i+1
	} else {
		line = str
		total_len = len(str)
	}
	
	return line, total_len
}

String_Iterator :: struct {
	data:  string,
	index: int,
}

// The index given on the first iteration is the value that iterator.index is set to initially.
// Given iterator.index starts as 0, its value after the for-loop represents the loop-count.
// ex: iterator.index = 10 means there were 10 lines
iter_lines_indexed :: proc(iterator: ^String_Iterator) -> (line: string, index: int, ok: bool) {
	line, ok = iter_lines_basic(&iterator.data)
	index = iterator.index
	if ok { iterator.index += 1 }
	return line, index, ok
}

// Inserts the value in the list if it is higher than a value in it.
// Assumes the list is sorted high to low. If a value is inserted, everything after it is moved over 1 spot.
insert_highest :: proc(list: []int, value: int) {
	for nth_best, n in list {
		if value <= nth_best { continue }

		// move everything over, then insert
		for i := len(list)-1; i > n; i -= 1 {
			list[i] = list[i-1]
		}

		list[n] = value
		break
	}
}
