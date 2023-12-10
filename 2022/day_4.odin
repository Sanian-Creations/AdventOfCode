package adventofcode

import "core:fmt"
import "core:strings"
import "core:strconv"
import "../aoc_util"

main :: proc() {
	data, ok := aoc_util.read_input();
	if !ok { return }

	p1, p2 := part1and2(data)
	fmt.printf("part 1: %v\n", p1)
	fmt.printf("part 2: %v\n", p2)
}

part1and2 :: proc(data: string) -> (points1, points2: int) {

	Section :: struct { min, max : int }
	
	sections : struct #raw_union {
		array : [4]int,
		vars  : struct { s1, s2: Section },
	}
	
	data := data
	for aoc_util.consume_next_N_ints(&data, sections.array[:]) {
		using sections.vars
		if fully_within(s1, s2) || fully_within(s2, s1) {
			points1 += 1
		}

		if overlaps(s1, s2) {
			points2 += 1
		}
	}

	return points1, points2

	fully_within :: #force_inline proc(s1, s2: Section) -> bool {
		return s1.min >= s2.min && s1.max <= s2.max
	}

	overlaps :: #force_inline proc(s1, s2: Section) -> bool {
		return s1.min <= s2.max && s1.max >= s2.min
	}
}
