main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input)); // Part 1: 7732
	print("Part 2: %\n", part_2(input)); // Part 2: 4500070301581
}

part_1 :: (input: string) -> int { return calc_arrangement_count(input, 1); }
part_2 :: (input: string) -> int { return calc_arrangement_count(input, 5); }

calc_arrangement_count :: (input: string, unfold_count: int) -> int {
	group_sizes: [..]u8;
	defer array_free(group_sizes);

	record: [..]u8;
	defer array_free(record);

	memo: Memo;
	defer HT.deinit(*memo);

	total := 0;
	for :lines line, l_i: input {
		space_index := S.find_index_from_left(line, #char " ");

		record.count = 0;
		array_add(*record, ..cast([]u8) view(line, 0, space_index));
		array_add(*record, #char "?");
		unfold(*record, unfold_count);
		record.count -= 1; // chop off the last '?'

		group_sizes.count = 0;
		parse_group_sizes(view(line, space_index + 1), *group_sizes);
		unfold(*group_sizes, unfold_count);

		HT.table_reset(*memo);

		required_space := sum(group_sizes) + group_sizes.count-1;
		pb := get_possibilities(record, group_sizes, .{}, required_space, *memo);
		total += pb;
	}

	return total;
}

parse_group_sizes :: (str__: string, group_sizes: *[..]u8) {
	str := str__;
	while str.count > 0 {
		num, _, str= := string_to_int(str);
		array_add(group_sizes, xx num);
		str.data += 1; str.count -= 1;
	}
}

unfold :: (arr: *[..]$T, multiplier: int) {
	array_reserve(arr, arr.count * multiplier);
	initial_content: []T = arr.*;
	for 1..multiplier-1 array_add(arr, ..initial_content);
}

Request :: struct {
	// Assume that no record has more than 255 values
	// The longest record I saw was 20 characters long, unfolding that 5 times for part 2 gets you 104, which is still fine.
	index:       u8;
	group_index: u8;
	#place index; as_one: u16;
}
Memo :: #type HT.Table(Request, int, hash_request, compare_request);
hash_request :: (r: Request) -> u32 { return Hash.get_hash(r.as_one); }
compare_request :: (a: Request, b: Request) -> bool { return a.as_one == b.as_one; }

get_possibilities :: (data: []u8, group_sizes: []u8, r__: Request, required_space: int, memo: *Memo) -> int {
	using r := r__;
	while index < data.count {
		space_left := data.count - index;
		if space_left < required_space then return 0;

		if data[index] == {
		case #char "."; index += 1; continue;

		case #char "#";
			// Assume group_sizes is never 0. If it is we may go out of bounds because we don't check the first time.
			group_length := group_sizes[group_index];

			group_is_obstructed := S.find_index_from_left(cast(string) view(data, index+1, group_length-1), #char ".") != -1;
			if group_is_obstructed then return 0;

			group_index += 1;

			index          += group_length;
			required_space -= group_length;

			was_last_group := group_index == group_sizes.count; // could also (required_space == 0)
			if was_last_group {
				no_more_groups_ahead := S.find_index_from_left(cast(string) view(data, index), #char "#") == -1;
				return cast(int) no_more_groups_ahead;
			}

			// Not the last group, so ensure there's a separator
			no_separator := data[index] == #char "#";
			if no_separator then return 0;

			index          += 1;
			required_space -= 1;

			continue;

		case #char "?";
			// It is actually insane how effective this is
			cache_value, in_cache := HT.table_find(memo, r);
			if in_cache then return cache_value;

			possibilities := 0;
			data[index] = #char "#";
			possibilities += get_possibilities(data, group_sizes, r, required_space, memo);
			data[index] = #char ".";
			possibilities += get_possibilities(data, group_sizes, r, required_space, memo);
			data[index] = #char "?";

			HT.table_add(memo, r, possibilities);

			return possibilities;
		}
	}

	return 0;
}


testinput :: #string TESTINPUT
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
TESTINPUT;

#run example("1", 21,     part_1(testinput));
#run example("2", 525152, part_2(testinput));


HT :: #import "Hash_Table";
Hash :: #import "Hash";
#load "../aoc_util.jai";
