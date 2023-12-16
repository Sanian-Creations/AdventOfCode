main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input)); // Part 1: 509152
	print("Part 2: %\n", part_2(input)); // Part 2: 244403
}

part_1 :: (input__: string) -> int {
	// 'consume_step' doesn't check for newlines,
	// so we just assume the input is one line with a newline on the end.
	// Cut off that single newline and we should be good to go.
	input := trim_nl(input__);

	total := 0;
	while 1 {
		step := consume_step(*input);
		if step.count <= 0 break;
		total += HASH(step);
	}
	return total;
}

part_2 :: (input__: string) -> int {
	input := trim_nl(input__);

	boxes: [256][..]Lens;
	defer for boxes array_free(it);

	while 1 {
		step := consume_step(*input);
		if step.count <= 0 break;

		label, focal_len := parse_step(step);
		box_index := HASH(label);
		box := *boxes[box_index];

		lens_index := -1;
		for box.* if it.label == label { lens_index = it_index; break; }

		if focal_len {
			if lens_index == -1
				then array_add(box, .{label, focal_len});
				else box.*[lens_index] = .{label, focal_len};
		} else {
			if lens_index != -1 then array_ordered_remove_by_index(box, lens_index);
		}

		if #compile_time {
			print("After \"%\"\n", step);
			for * box: boxes {
				if !box.count continue;
				print("Box %: %\n", it_index, cast([]Lens)box.*);
			}
		}
	}

	total := 0;
	for * box, box_index: boxes {
		if !box.count continue;
		for lens, lens_index: box.* {
			total += (1 + box_index) * (1 + lens_index) * lens.focal_len;
		}
	}

	return total;
}

Lens :: struct {
	label: string;
	focal_len: u8;
}

HASH :: (label: string) -> u8 #no_aoc {
	current_val: u8;
	for cast([]u8)label {
		current_val = (current_val + it) * 17; // no arithmetic overflow check (aoc... adventofcode...?)
	}
	return current_val;
}

parse_step :: (step: string) -> label: string, focal_len: u8 {
	last_char := #no_abc step[step.count-1];
	if step[step.count-1] == #char "-"
		then return view(step, 0, step.count-1, false), 0;
		else return view(step, 0, step.count-2, false), last_char - #char "0";
}

consume_step :: (input: *string) -> step: string {
	len := S.find_index_from_left(input.*, #char ",");
	cutoff := len + 1;
	if !cutoff { len, cutoff = input.count; }
	step := view(input, 0, len, false);
	input.data  += cutoff;
	input.count -= cutoff;
	return step;
}


testinput :: #string TESTINPUT
rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
TESTINPUT;

#run example("1", 1320, part_1(testinput));
#run example("2", 145, part_2(testinput));


#load "../aoc_util.jai";
