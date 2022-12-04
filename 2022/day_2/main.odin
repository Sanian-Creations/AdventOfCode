package adventofcode

import "core:fmt"
import "core:os"
import "../../shared"

main :: proc() {

	data, ok := shared.read_input()
	if !ok { return }

	p1, p2 := part1and2(data)
	fmt.printf("part 1: %v\n", p1)
	fmt.printf("part 2: %v\n", p2)
}

part1and2 :: proc(data: []u8) -> (points1, points2: int) {
	iter := data
	for line in shared.iter_lines(&iter) {
		other := get_move(line[0])
		me    := get_move(line[2])
		points1 += get_points_pt1(me, other)
		points2 += get_points_pt2(me, other)
	}
	
	return points1, points2
}

get_move :: proc(move: u8) -> int {
	switch move {
	  case 'A', 'X': return 0 // rock
	  case 'B', 'Y': return 1 // paper
	  case 'C', 'Z': return 2 // scissors
	  case:
		fmt.printf("Unknown move symbol '%c'\n", move)
		panic("")
	}
}

get_points_pt1 :: proc(me, other: int) -> int {
	if (other == me) { return me + 1 + 3 }            // Draw
	if (other == lose_from(me)) { return me + 1 + 6 } // I win
	return me + 1                                     // I lose
}

get_points_pt2 :: proc(me, other: int) -> int {
	switch me {
	  case 0: return me * 3 + lose_from(other) + 1
	  case 1: return me * 3 + other + 1
	  case 2: return me * 3 + win_from(other) + 1
	}
	panic("")
}

// lose_from(x) == move that loses from x
lose_from :: #force_inline proc(me: int) -> int { return (me+2)%3 }
// win_from(x) == move that wins from x
win_from  :: #force_inline proc(me: int) -> int { return (me+1)%3 }
