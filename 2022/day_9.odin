package adventofcode

import "core:fmt"
import "../aoc_util"

main :: proc() {
	data, ok := aoc_util.read_input()
	if !ok { return }

	p1, p2 := part1and2(data)
	fmt.printf("part 1: %v\n", p1)
	fmt.printf("part 2: %v\n", p2)
}

Coord :: struct {
	x, y : i32
}

part1and2 :: proc(data: string) -> (p1, p2: int) {

	rope_len :: 1 + 9 // head + tail length
	knots : [rope_len]Coord

	// not deleting these guys, memory leaks ftw
	move_map_1 := make(map[Coord]bool)
	move_map_2 := make(map[Coord]bool)

	iterator := data
	for line in aoc_util.iter_lines(&iterator) {
		direction_char := line[0]
		steps, _       := aoc_util.get_int(line[2:])

		direction: Coord

		switch direction_char {
		  case 'U': direction = Coord{ x =  0, y =  1 }
		  case 'D': direction = Coord{ x =  0, y = -1 }
		  case 'L': direction = Coord{ x = -1, y =  0 }
		  case 'R': direction = Coord{ x =  1, y =  0 }
		  case: panic("")
		}

		for i in 0..<steps {
			H  :: 0
			T1 :: 1
			T2 :: rope_len-1

			knots[H] = add(knots[H], direction)

			knots[T1] = move_tail(knots[T1], knots[H])
			move_map_1[knots[T1]] = true

			for i in T1+1..<T2 {
				knots[i] = move_tail(knots[i], knots[i-1])
			}

			knots[T2] = move_tail(knots[T2], knots[T2-1])
			move_map_2[knots[T2]] = true
		}
	}

	return len(move_map_1), len(move_map_2)
}

move_tail :: proc(tail, head: Coord) -> Coord {
	direction := sub(head, tail)

	if abs(direction.x) <= 1 && abs(direction.y) <= 1 { return tail }

	direction.x = clamp(direction.x, -1, 1)
	direction.y = clamp(direction.y, -1, 1)

	return add(tail, direction)
}

add :: #force_inline proc(A, B: Coord) -> Coord {
	return Coord {
		x = A.x + B.x,
		y = A.y + B.y,
	}
}

sub :: #force_inline proc(A, B: Coord) -> Coord {
	return Coord {
		x = A.x - B.x,
		y = A.y - B.y,
	}
}
