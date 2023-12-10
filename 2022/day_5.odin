package adventofcode

import "core:fmt"
import "core:slice"
import "core:runtime"
import "../aoc_util"

main :: proc() {
	data, ok := aoc_util.read_input();
	if !ok { return }

	p1, p2: [N]u8
	part1and2(data, &p1, &p2)
	fmt.printf("part 1: %s\n", p1[:])
	fmt.printf("part 2: %s\n", p2[:])
}

N :: 9
Crate_Stack :: [dynamic]u8

part1and2 :: proc(data: string, p1, p2: ^[N]u8) {

	supplies_1, supplies_2 : [N]Crate_Stack

	for i in 0..<N {
		supplies_1[i] = make(Crate_Stack, 0, 64)
		supplies_2[i] = make(Crate_Stack, 0, 64)
	}

	defer for i in 0..<N {
		delete(supplies_1[i])
		delete(supplies_2[i])
	}
	
	data := data

	{ // Read the initial state of the supplies
		for line in aoc_util.iter_lines(&data) {
			if line == "" { break }

			for i := 0; i < len(line); i += 4 {
				if line[i] == '[' {
					append(&supplies_1[i/4], line[i+1])
				}
			}
		}

		// Reverse stacks because we pushed all crates on
		// top-to-bottom when they should be bottom-to-top.
		// Also copy supplies_1 to supplies_2
		for stack, i in supplies_1 {
			slice.reverse(stack[:])
			for crate in stack {
				append(&supplies_2[i], crate)
			}
		}
	}
	
	move : struct #raw_union {
		array : [3]int,
		vars  : struct { count, from, to: int },
	}
	
	for aoc_util.consume_next_N_ints(&data, move.array[:]) {
		using move.vars
		// -1 is to convert from 1-indexed to 0-indexed
		do_moves_1(&supplies_1[from-1], &supplies_1[to-1], count)
		do_moves_2(&supplies_2[from-1], &supplies_2[to-1], count)
	}

	for i in 0..<N {
		p1[i] = pop(&supplies_1[i])
		p2[i] = pop(&supplies_2[i])
	}
}

do_moves_1 :: proc(from, to: ^Crate_Stack, count: int) {
	for i in 0..<count {
		append(to, pop(from))
	}
}

do_moves_2 :: proc(from, to: ^Crate_Stack, count: int) {
	multiple_crates := from[len(from)-count:]
	for crate in multiple_crates {
		append(to, crate)
	}
	(^runtime.Raw_Dynamic_Array)(from).len -= count
}
