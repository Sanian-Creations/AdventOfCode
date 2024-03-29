package adventofcode

import "core:fmt"
import "core:intrinsics"
import "../aoc_util"

main :: proc() {
	data, ok := aoc_util.read_input();
	if !ok { return }

	p1, p2 := part1and2(data)
	fmt.printf("part1: %v\n", p1) // should be 8252
	fmt.printf("part2: %v\n", p2) // should be 2828
}

Item_Set :: bit_set[u8('A')..= u8('z'); u64]

part1and2 :: proc(data: string) -> (sum1, sum2: int) {

	group: [3]Item_Set // every member of the group has an item set

	iterator := aoc_util.String_Iterator{ data = data }
	for line, lnr in aoc_util.iter_lines(&iterator) {
		pocket_size := len(line) / 2
		pocket_1 := line[:pocket_size]
		pocket_2 := line[pocket_size:]

		itemset_1, itemset_2: Item_Set // one set for every pocket

		for i := 0; i < pocket_size; i += 1 {
			incl(&itemset_1, pocket_1[i])
			incl(&itemset_2, pocket_2[i])
		}

		get_points :: proc(set: Item_Set) -> int {
			set := transmute(u64) set
			if intrinsics.count_ones(set) != 1 {
				fmt.printf("Only a single bit should be set to 1, instead was:\n%#b\n", set)
				panic("")
			}
			matching_item := 'A' + cast(int) intrinsics.count_trailing_zeros(set)
			return matching_item + (27-'A' if matching_item <= 'Z' else 1-'a')
		}

		// pt1: matching item in both pockets
		sum1 += get_points(itemset_1 & itemset_2)

		mod3 := lnr % 3
		group[mod3] = itemset_1 | itemset_2

		if mod3 == 2 {
			// pt2: matching item in group of 3 elves
			sum2 += get_points(group[0] & group[1] & group[2])
		}
	}

	return sum1, sum2
}
