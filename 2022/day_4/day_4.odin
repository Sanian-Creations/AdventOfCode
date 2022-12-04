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

part1and2 :: proc(data: []u8) -> (points1, points2: int) {
	iterator := string(data)
	for line in shared.iter_lines(&iterator) {
		dash  := strings.index_byte(line, '-')
		comma := strings.index_byte(line, ',')
		section_1 := make_section(line[:dash], line[dash+1:comma])
		dash   = strings.last_index_byte(line, '-')
		section_2 := make_section(line[comma+1:dash], line[dash+1:])

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

make_section :: proc(s1, s2: string) -> Section {
	return Section{
		min = parse_int(s1),
		max = parse_int(s2)
	}
}

parse_int :: proc(s: string) -> int {
	i, ok := strconv.parse_int(s)
	if !ok {
		fmt.printf("Failed to parse string \"%v\"\n", s)
		panic("")
	}
	return i
}
