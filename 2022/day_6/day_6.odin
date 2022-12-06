package adventofcode

import "core:fmt"
import "../../aoc_util"

main :: proc() {
	data, ok := aoc_util.read_input()
	if !ok { return }

	str := transmute([]u8)data

	p1 := find_marker(str, 4)
	fmt.printf("part 1: %v\n", p1)
	p2 := find_marker(str, 14)
	fmt.printf("part 2: %v\n", p2)
}

find_marker :: proc(data: []u8, N: u8) -> (index: int) {
	Duplicates_Tracker :: struct {
		duplicates : int,
		lookup     : [26]u8,
	}

	N := int(N)
	t: Duplicates_Tracker

	for i in 0..<N {
		add_char(&t, data[i])
	}

	for i in N..<len(data) {
		if t.duplicates == 0 { return i }

		add_char   (&t, data[i])
		remove_char(&t, data[i-N])
	}

	if t.duplicates == 0 { return len(data) }
	return 0

	add_char :: #force_inline proc(using t: ^Duplicates_Tracker, c: u8) {
		c := c - 'a'
		lookup[c] += 1
		if lookup[c] > 1 { duplicates += 1 } // added a char we already had
	}

	remove_char :: #force_inline proc(using t: ^Duplicates_Tracker, c: u8) {
		c := c - 'a'
		lookup[c] -= 1
		if lookup[c] > 0 { duplicates -= 1 } // there's still more of these chars
	}
}
