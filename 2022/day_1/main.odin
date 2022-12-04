package adventofcode

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "../../shared"

main :: proc() {

	data, ok := shared.read_input();
	if !ok { return }
	
	top_3: [3]int
	total := calculate_calories(data, top_3[:])
	fmt.printf("part 1: %v\n", top_3[0])
	fmt.printf("part 2:\n- top 3 = %v\n- total = %v\n", top_3, total)

}

calculate_calories :: proc(data: []u8, top_N_calories: []int) -> (total: int) {

	current_calories := 0

	iterator := data
	for line in shared.iter_lines(&iterator) {
		nr, ok := strconv.parse_int(string(line))
		if ok {
			current_calories += nr
			continue
		}

		// > got empty line
		// > got total calories for this elf 
		// > add to top N calories
		
		N := len(top_N_calories)
		for nth_best, n in top_N_calories {
			if current_calories <= nth_best { continue }

			// move everything over
			for i in n..<(N-1) {
				top_N_calories[i+1] = top_N_calories[i]
			}
			
			// insert this one
			top_N_calories[n] = current_calories
			break
		}
		
		current_calories = 0
	}

	for i in top_N_calories { total += i }

	return total
}
