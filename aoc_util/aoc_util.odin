package aoc_util

import "core:os"
import "core:fmt"
import "core:strings"

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

// Procedure to split a string in half on the first instance of a char/byte.
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

iter_lines_basic :: proc(data: ^string) -> (line: string, ok: bool) {

	if len(data) == 0 { return "", false }
	
	i := strings.index_byte(data^, '\n')

	if i != -1 {
		// Account for files using \r\n as newline
		// AoC files all use Unix file format and don't have this problem,
		// but I like knowing that this code will work on all files.
		line = (i > 0 && data[i-1] == '\r') ? data[:i-1] : data[:i]
		data^ = data[i+1:]
	} else {
		line = data[:]
		data^ = data[len(data):]
	}
	
	return line, true
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

