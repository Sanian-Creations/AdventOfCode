package aoc_shared

import "core:os"
import "core:fmt"

read_input :: proc() -> (data: []u8, ok: bool) {
	if len(os.args) != 2 {
		fmt.printf("Please provide the input filename as a single argument.\n")
		return nil, false
	}

	input := os.args[1]
	data, ok = os.read_entire_file_from_filename(input)

	if !ok {
		fmt.printf("Error reading file \"%v\"\n", input)
		return nil, false
	}
	
	return data, ok
}

iter_lines :: proc{
	iter_lines_u8,
	iter_lines_u8_indexed,
	iter_lines_string,
	iter_lines_string_indexed,
}

iter_lines_u8 :: proc(data: ^[]u8) -> (line: []u8, ok: bool = true) {
	for c, i in data {
		if c == '\n' {
			line = data[:i]
			len := len(line)
			if len > 0 && line[len-1] == '\r' { line = line[:len-1] }
			data^ = data[i+1:] // advance iterator
			return
		}
	}
	
	// this data has no newlines
	len := len(data)
	if len > 0 { // still use this last line
		line = data^
		if line[len-1] == '\r' { line = line[:len-1] }
		data^ = data[len:] // advance iterator
		return		
	}

	// there's no more string left to iterate over
	return nil, false
}

iter_lines_string :: #force_inline proc(data: ^string) -> (string, bool) {
	line, ok := iter_lines_u8( cast(^[]u8) data );
	return string(line), ok
}

iter_lines_u8_indexed :: #force_inline proc(iterator: ^Iterator([]u8)) -> (line: []u8, index: int, ok: bool) {
	line, ok = iter_lines_u8(&iterator.data)
	index = iterator.index;
	if ok { iterator.index += 1 }
	return
}

iter_lines_string_indexed :: #force_inline proc(iterator: ^Iterator(string)) -> (string, int, bool) {
	line, index, ok := iter_lines_u8_indexed( cast(^Iterator([]u8)) iterator );
	return string(line), index, ok
}

Iterator :: struct(T: typeid) {
	data:  T,
	index: int,
}
