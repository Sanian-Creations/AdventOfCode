package adventofcode

import "core:fmt"
import "../aoc_util"

main :: proc() {
	data, ok := aoc_util.read_input()
	if !ok { return }

	part1(data)
}

part1 :: proc(data: string) {

	iterator := data
	for line in aoc_util.iter_lines(&iterator) {
		fmt.printf("%s\n", line)
	}
}
