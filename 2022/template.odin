package adventofcode

import "core:fmt"
import "../../shared"

main :: proc() {
	data, ok := shared.read_input();
	if !ok { return }

	part1(data)
}

part1 :: proc(data: []u8) {

	iterator := data
	for line in shared.iter_lines(&iterator) {
		fmt.printf("%s\n", line)
	}
}
