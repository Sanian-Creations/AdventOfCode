package adventofcode

import "core:fmt"
import "core:intrinsics"
import "../../aoc_util"

main :: proc() {
	data, ok := aoc_util.read_input()
	if !ok { return }

	part1and2(data)
}

// This one could be shortened a lot,
// there's a bunch of repetition that could be turned into procedures.
// But I don't really feel like doing that right now.

part1and2 :: proc(input: string) {

	Info :: struct {
		data           : string,
		total_line_len : int,
		line_len       : int,
		line_count     : int,
		lookup         : []u8,
		lookup_bytes_per_line : int
	}
	
	using info := Info {
		data = input
	}

	line: string
	line, total_line_len = aoc_util.get_line(data) 
	line_len = len(line)
	// 'total_line_len' includes newline and carriage return
	// 'line_len' is the amount of digits on one line, either 1 or 2 less than total_line_len depending on the type of newlines.

	get_tree :: #force_inline proc(using info: ^Info, x, y: int) -> u8 {
		return data[total_line_len*y + x]
	}
	
	assert(total_line_len != 0)
	line_count = len(data) / total_line_len

	// Make an array of bits that note down which trees are visible,
	// then after, count all the 1's
	lookup_bytes_per_line = line_len / 8 + (int)(line_len % 8 != 0)

	lookup = make([]u8, lookup_bytes_per_line * line_count) // memory leak but idc, program exit cleans it all up!

	mark_visible :: #force_inline proc(using info: ^Info, x, y: int) {
		column_index, bit_index := x / 8, x % 8
		lookup[lookup_bytes_per_line*y + column_index] |= (0b_1000_0000 >> cast(uint)bit_index)
	}


	// PART 1
	
	for y in 1..<line_count-1 { // check visibility horizontally
		tallest, second_tallest: u8
		x := line_len - 1
		for x >= 0 {
			tree := get_tree(&info, x, y)
			if tree > tallest {
				tallest = tree
				mark_visible(&info, x, y)
			}
			x -= 1
		}

		for {
			x += 1
			tree := get_tree(&info, x, y)
			if tree > second_tallest {
				second_tallest = tree
				mark_visible(&info, x, y)
				if second_tallest == tallest { break }
			}
		}
	}
	
	for x in 1..<line_len-1 { // check visibility vertically
		tallest, second_tallest: u8
		y := line_count - 1
		for y >= 0 {
			tree := get_tree(&info, x, y)
			if tree > tallest {
				tallest = tree
				mark_visible(&info, x, y)
			}
			y -= 1
		}

		for {
			y += 1
			tree := get_tree(&info, x, y)
			if tree > second_tallest {
				second_tallest = tree
				mark_visible(&info, x, y)
				if second_tallest == tallest { break }
			}
		}
	}

	sum := 4 // corners not included, but they are always visible. 
	for b in lookup {
		sum += cast(int)intrinsics.count_ones(b)
	}

	fmt.printf("part 1, visible trees: %v\n", sum)

	
	// PART 2
	
	best_score := 0

	// skip edges, those have score 0 always.
	for y in 1..<line_count-1 {
		for x in 1..<line_len-1 {
			best_score = max(best_score, scenic_score(&info, x, y))
		}
	}
	
	fmt.printf("part 2, best scenic score: %v\n", best_score)
	
	scenic_score :: proc(using info: ^Info, x,y: int) -> int {
		house := get_tree(info, x, y)

		score := 1
		
		for i := 1; true; i += 1 { // left
			if x-i < 0           { score *= i-1; break }
			if get_tree(info, x-i, y) >= house { score *= i; break }
		}

		for i := 1; true; i += 1 { // right
			if x+i >= line_len   { score *= i-1; break }
			if get_tree(info, x+i, y) >= house { score *= i; break }
		}
		
		for i := 1; true; i += 1 { // up
			if y-i < 0           { score *= i-1; break }
			if get_tree(info, x, y-i) >= house { score *= i; break }
		}

		for i := 1; true; i += 1 { // down
			if y+i >= line_count { score *= i-1; break }
			if get_tree(info, x, y+i) >= house { score *= i; break }
		}

		return score
	}
}
