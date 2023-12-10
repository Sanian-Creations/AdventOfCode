package adventofcode

import "core:fmt"
import "core:strconv"
import "../aoc_util"

main :: proc() {
	data, ok := aoc_util.read_input()
	if !ok { return }

	run_device(data)
}

Device :: struct {
	instructions : string,
	p1_sum       : int,
	add_value    : int,
	X            : int,
	cycle        : int,
	wait_one     : bool,
}

run_device :: proc(data: string) {

	using device := Device {
		X = 1,
		instructions = data,
	}

	// Repeat until no more cycles
	for do_cycle(&device) {

		// Analyse sum (part 1)
		if (cycle+20) % 40 == 0 {
			p1_sum += cycle * X
		}

		// Draw pixel (part 2)
		pixel_pos := (cycle-1) % 40
		draw_pix := pixel_pos >= X-1 && pixel_pos <= X+1

		fmt.print(rune(draw_pix ? '#' : '.'))

		if pixel_pos == 39 { fmt.println() }
	}

	fmt.printf("\nPart 1: %v\n", p1_sum)
}

do_cycle :: proc(using d: ^Device) -> (still_running: bool) {

	// It actually doesn't matter if I do this at the start or end of this proc
	cycle += 1 
	
	if wait_one {
		wait_one = false
		return true
	}

	// Perform addition
	X += add_value
	add_value = 0

	// Read the next operation
	line, ok := aoc_util.iter_lines(&instructions)
	if !ok { return false }

	// Every line has an instruction, but the only instruction that
	// does anything is addx, so we only check for that one.
	if line[0] == 'a' {
		
		// "addx 123", nr starts at index 5
		add_value, _ = strconv.parse_int(line[5:])
		
		// Although addx takes 2 cycles, every instruction already takes 1 cycle.
		// So to make it take 2, we only have to add 1 cycle of additional wait time.
		wait_one = true
	}

	return true
}
