package adventofcode

import "core:fmt"
import "core:strings"
import "core:strconv"
import "../../shared"

main :: proc() {
	data, ok := shared.read_input();
	if !ok { return }
	
	p1, p2 := part1and2(data)
	fmt.printf("part 1: %v\n", p1)
	fmt.printf("part 2: %v\n", p2)
}

Section :: struct {
	min, max: int
}

part1and2 :: proc(data: string) -> (points1, points2: int) {
	data := data
	
	for line in shared.iter_lines(&data) {
		max_str: string
		min_str, line := shared.split_on_byte(line, '-')
		max_str, line  = shared.split_on_byte(line, ',')
		section_1 := make_section(min_str, max_str)
		min_str, max_str = shared.split_on_byte(line, '-')
		section_2 := make_section(min_str, max_str)

		if fully_within(section_1, section_2) || fully_within(section_2, section_1) {
			points1 += 1
		}

		if overlaps(section_1, section_2) {
			points2 += 1
		}
	}

	return points1, points2
}

fully_within :: #force_inline proc(s1, s2: Section) -> bool {
	return s1.min >= s2.min && s1.max <= s2.max
}

overlaps :: #force_inline proc(s1, s2: Section) -> bool {
	return s1.min <= s2.max && s1.max >= s2.min
}

make_section :: proc(min_str, max_str: string) -> (s: Section) {
	s.min, _ = strconv.parse_int(min_str)
	s.max, _ = strconv.parse_int(max_str)
	return s
}
