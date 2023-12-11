main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input)); // Part 1: 6757
	print("Part 2: %\n", part_2(input)); // Part 2: 523
}

part_1 :: (input: string) -> int {
	grid := text_grid(input);
	row, col := find_S(input, grid.line_len);
	start_pipe := infer_pipe_shape(grid, row, col);

	distance := 0;
	current_char: u8;
	rot := pick_start_rotation(start_pipe); // 0 1 2 3 = Up Right Down Left

	while 1 {
		distance += 1;
		row += s8.[-1,0,1,0][rot];
		col += s8.[0,1,0,-1][rot];

		current_char = get(grid, row, col);
		if current_char == #char "S" break;
		rot = turn(current_char, rot);
	}

	return distance / 2;
}

part_2 :: (input: string) -> int {
	grid := text_grid(input);
	row, col := find_S(input, grid.line_len);
	start_pipe := infer_pipe_shape(grid, row, col);

	current_char: u8;
	rot := pick_start_rotation(start_pipe);

	pipe_grid := NewArray(grid.width * grid.height, Pipe);
	defer array_free(pipe_grid);
	pipe_grid[row * grid.width + col] = start_pipe;

	while 1 {
		row += s8.[-1,0,1,0][rot];
		col += s8.[0,1,0,-1][rot];

		current_char = get(grid, row, col);
		if current_char == #char "S" break;
		rot = turn(current_char, rot);

		pipe_grid[row * grid.width + col] = char_to_pipe(current_char);
	}

	total  := 0;
	inside: Pipe; // if any of the bits are set, you are inside the shape.
	for pipe: pipe_grid {
		if pipe then inside ^= pipe & (.UP|.DOWN);
		else if inside then total += 1;
	}

	return total;
}

find_S :: (input: string, line_len: int) -> row: int, col: int {
	index := S.find_index_from_left(input, #char "S");
	return index / line_len, index % line_len;
}

pick_start_rotation :: (start: Pipe) -> s8 {
	return
		ifx start & .UP then 0 else
		ifx start & .RIGHT then 1 else
		ifx start & .DOWN then 2 else
		ifx start & .LEFT then cast(s8) 3;
}

char_to_pipe :: (c: u8) -> Pipe {
	if c == {
		case #char "|"; return .UP   | .DOWN;
		case #char "-"; return .LEFT | .RIGHT;
		case #char "L"; return .UP   | .RIGHT;
		case #char "J"; return .UP   | .LEFT;
		case #char "7"; return .DOWN | .LEFT;
		case #char "F"; return .DOWN | .RIGHT;
		case; return 0;
	}
}

infer_pipe_shape :: (grid: Text_Grid, row: int, col: int) -> Pipe {
	pipe: Pipe;
	if char_to_pipe(get(grid, row - 1, col)) & .DOWN  then pipe |= .UP;
	if char_to_pipe(get(grid, row, col - 1)) & .RIGHT then pipe |= .LEFT;
	if char_to_pipe(get(grid, row, col + 1)) & .LEFT  then pipe |= .RIGHT;
	if char_to_pipe(get(grid, row + 1, col)) & .UP    then pipe |= .DOWN;
	return pipe;
}

turn :: (c: u8, dir_in: s8) -> dir_out: s8 {
	if c == {
		case #char "|"; #through;
		case #char "-"; return dir_in;
		case #char "L"; #through;
		case #char "7"; return dir_in ^ 3;
		case #char "J"; #through;
		case #char "F"; return dir_in ^ 1;
		case; assert(false, "unknown char '%' (%)\n", cast(string)view(*c, 1), c); return 0;
	}
}

Pipe :: enum_flags u8 { // enum, can point in multiple directions at once
	UP    :: 0b_00_01;
	DOWN  :: 0b_00_10;
	LEFT  :: 0b_01_00;
	RIGHT :: 0b_10_00;
}


#run example("1a", 4, part_1(#string TESTINPUT
.....
.S-7.
.|.|.
.L-J.
.....
TESTINPUT));

#run example("1b", 8, part_1(#string TESTINPUT
..F7.
.FJ|.
SJ.L7
|F--J
LJ...
TESTINPUT));

#run example("2a", 4, part_2(#string TESTINPUT
...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........
TESTINPUT));

#run example("2b", 4, part_2(#string TESTINPUT
..........
.S------7.
.|F----7|.
.||....||.
.||....||.
.|L-7F-J|.
.|..||..|.
.L--JL--J.
..........
TESTINPUT));

#run example("2c", 8, part_2(#string TESTINPUT
.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...
TESTINPUT));

#run example("2d", 10, part_2(#string TESTINPUT
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
TESTINPUT));


#load "../aoc_util.jai";
TESTS :: true;