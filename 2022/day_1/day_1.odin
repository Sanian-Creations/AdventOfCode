package adventofcode

import "core:fmt"
import "core:strconv"
import "../../aoc_util"

main :: proc() {
	data, ok := aoc_util.read_input();
	if !ok { return }

	top_3: [3]int
	total := calculate_calories(data, top_3[:])
	fmt.printf("part 1: %v\n", top_3[0])
	fmt.printf("part 2:\n- top 3 = %v\n- total = %v\n", top_3, total)
}

calculate_calories :: proc(data: string, top_N_calories: []int) -> (total: int) {

	current_calories := 0

	data := data
	for line in aoc_util.iter_lines(&data) {
		nr, ok := strconv.parse_int(line)
		if ok {
			current_calories += nr
			continue
		}

		// > got empty line
		// > got total calories for this elf 

		// add to top N calories
		// use insertion sort
		N := len(top_N_calories)
		for nth_best, n in top_N_calories {
			if current_calories <= nth_best { continue }

			// move everything over, then insert
			for i in n..<(N-1) {
				top_N_calories[i+1] = top_N_calories[i]
			}

			top_N_calories[n] = current_calories
			break
		}

		current_calories = 0
	}

	for i in top_N_calories { total += i }

	return total
}
