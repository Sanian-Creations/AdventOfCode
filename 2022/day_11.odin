package adventofcode

import "core:fmt"
import "core:strconv"
import "core:runtime"
import "core:math"
import "../aoc_util"

main :: proc() {
	data, ok := aoc_util.read_input()
	if !ok { return }

	part1and2(data)
}

Monkey :: struct {
	items           : [dynamic]int,
	targets         : [2]int, // Test: false -> targets[0], true -> targets[1]
	divisible_by    : int,
	inspections     : int,
	operand         : int,
	operation       : enum { MUL, ADD },
	operand_is_item : bool,
}

Info :: struct {
	monkeys                  : [dynamic]Monkey,
	worry_managing_magic_num : int,
}

part1and2 :: proc(data: string) {

	info1, info2: Info
	
	iterator := data
	for {

		aoc_util.iter_lines(&iterator) // Line with monkey nr, can be ignored since they are listed in order
		line_items, _ := aoc_util.iter_lines(&iterator) // list of items
		line_op,    _ := aoc_util.iter_lines(&iterator) // operation monkey does
		line_test,  _ := aoc_util.iter_lines(&iterator) // division test monkey does
		line_true,  _ := aoc_util.iter_lines(&iterator) // throw target if test == true
		line_false, _ := aoc_util.iter_lines(&iterator) // throw target if test == false
		_, more       := aoc_util.iter_lines(&iterator) // empty line separating the monkeys, or eof.
		
		monkey: Monkey

		// Items
		for item in aoc_util.consume_next_int(&line_items) {
			append(&monkey.items, item)
		}

		// Operation
		switch line_op[23] {
		  case '+': monkey.operation = .ADD;
		  case '*': monkey.operation = .MUL
		  case:     panic("")
		}

		// Operand
		is_number: bool
		monkey.operand, is_number = strconv.parse_int(line_op[25:])
		monkey.operand_is_item = !is_number

		// Division test and targets
		monkey.divisible_by, _ = strconv.parse_int(line_test[21:])
		monkey.targets[1],   _ = strconv.parse_int(line_true[29:])
		monkey.targets[0],   _ = strconv.parse_int(line_false[30:])

		append(&info1.monkeys, monkey)

		if !more { break }
	}

	// All values are now in info1. Copy them to info2, but be sure there is no
	// overlap in memory, so new dynamic arrays need to be allocated
	for monkey, i in info1.monkeys {
		append(&info2.monkeys, monkey)
		info2.monkeys[i].items = nil
		for item in monkey.items {
			append(&info2.monkeys[i].items, item)
		}
	}
	
	// Get least-common-multiple of all monkey division values
	num := info1.monkeys[0].divisible_by
	for i in 1..<len(info1.monkeys) {
		num = math.lcm(num, info1.monkeys[i].divisible_by)
	}
	info2.worry_managing_magic_num = num

	for i in 0..<20 {
		do_throws(&info1, false) // false = use div by 3
	}
	for i in 0..<10_000 {
		do_throws(&info2, true) // true = use cool modulus method
	}

	fmt.print("Part 1:\n")
	print_results(&info1)
	
	fmt.print("Part 2:\n")
	print_results(&info2)
	
	print_results :: proc(using info: ^Info) {
		best_2: [2]int
		for monkey, i in monkeys {
			aoc_util.insert_highest(best_2[:], monkey.inspections)
			fmt.printf("monkey %v did %v inspections\n", i, monkey.inspections)
		}
		fmt.printf("Top 2 monkeys: %v\n", best_2)
		fmt.printf("Total monkey business: %v\n", best_2[0] * best_2[1])
	}
}

do_throws :: proc(using info: ^Info, $manage_worries: bool) {

	for monkey in &monkeys {

		// We're about to inspect/throw all items, so just add the item count.
		monkey.inspections += len(monkey.items)

		for item in monkey.items {
			item := item

			// Do operation
			operand := monkey.operand_is_item ? item : monkey.operand
			switch monkey.operation {
			  case .MUL:
				item = item * operand

			  case .ADD:
				item = item + operand
			}

			// Div by 3, or use modulus for part 2
			when manage_worries {
				item = item % worry_managing_magic_num
			} else {
				item /= 3
			}

			// Do test
			test_result := item % monkey.divisible_by == 0
			target_idx := monkey.targets[int(test_result)]

			// Throw to other monkey, depending on test result
			append(&monkeys[target_idx].items, item)
		}

		// Assuming the monkey didnt throw items to himself, he now has no items left.
		(^runtime.Raw_Dynamic_Array)(&monkey.items).len = 0;
	}
}
