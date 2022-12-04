package adventofcode

import "core:fmt"
import "core:os"
import "../../shared"

main :: proc() {

	data, ok := shared.read_input();
	if !ok { return }
	
	fmt.printf("part 1: %v\n", loop_over_everything(data, get_points_pt1))
	fmt.printf("part 2: %v\n", loop_over_everything(data, get_points_pt2))
}

loop_over_everything :: proc(data: []u8, points_proc: proc(me, other: int) -> int) -> (points: int) {
	for i := 0; i < len(data); i += 4 {
		other := get_move(data[i])
		me    := get_move(data[i+2])
		points += points_proc(me, other)
	}
	
	return points
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

// lose_from(x) == move that loses from x
lose_from :: #force_inline proc(me: int) -> (opponent: int) {
	return (me+2)%3
}

// win_from(x) == move that wins from x
win_from :: #force_inline proc(me: int) -> (opponent: int) {
	return (me+1)%3
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
