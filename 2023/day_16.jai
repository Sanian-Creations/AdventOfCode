main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input)); // Part 1: 6902
	print("Part 2: %\n", part_2(input)); // Part 2: 7697
}

part_1 :: (input: string) -> int {
	tiles := grid_view(input);
	nrg_grid := alloc_grid(tiles.rows, tiles.cols, Energized_State);
	defer free(nrg_grid);

	beams: [..]Light_Beam;
	defer array_free(beams);

	array_add(*beams, .{ col = -1, dir = .RIGHT });
	total := shine_beams(*beams, tiles, nrg_grid);

	return total;
}

part_2 :: (input: string) -> int {
	tiles := grid_view(input);
	nrg_grid := alloc_grid(tiles.rows, tiles.cols, Energized_State);
	defer free(nrg_grid);

	beams: [..]Light_Beam;
	defer array_free(beams);

	max_nrg := 0;
	for r: 0..tiles.rows-1 {
		array_add(*beams, .{ col = -1, row = r, dir = .RIGHT });
		max_nrg = max(max_nrg, shine_beams(*beams, tiles, nrg_grid));
		zero_out_array(nrg_grid.array);

		array_add(*beams, .{ col = tiles.cols, row = r, dir = .LEFT });
		max_nrg = max(max_nrg, shine_beams(*beams, tiles, nrg_grid));
		zero_out_array(nrg_grid.array);
	}
	for c: 0..tiles.cols-1 {
		array_add(*beams, .{ col = c, row = -1, dir = .DOWN });
		max_nrg = max(max_nrg, shine_beams(*beams, tiles, nrg_grid));
		zero_out_array(nrg_grid.array);

		array_add(*beams, .{ col = c, row = tiles.rows, dir = .UP });
		max_nrg = max(max_nrg, shine_beams(*beams, tiles, nrg_grid));
		zero_out_array(nrg_grid.array);
	}

	return max_nrg;
}

shine_beams :: (beams: *[..]Light_Beam, tiles: Text_Grid_View, nrg_grid: Grid(Energized_State)) -> int {

	while beams.count > 0 {
		beam := pop(beams);
		while 1 {

			// Move
			beam.row +=  (cast(int)beam.dir - 1) % 2; // -1  0 +1  0
			beam.col += -(cast(int)beam.dir - 2) % 2; //  0 +1  0 -1

			// Check bounds
			if !is_in_bounds(beam.row, beam.col, nrg_grid.rows, nrg_grid.cols) then break;

			nrg := energize(beam.dir);
			nrg_here := address(nrg_grid, beam.row, beam.col);

			// Check if we've already traversed this path.
			if nrg_here.* & nrg then break;

			// Energize this cell
			nrg_here.* |= nrg;

			// Change direction orsplit based on current cell
			tile := get(tiles, beam.row, beam.col);
			if tile == {
				case #char "/";  beam.dir = beam.dir ^ 0b01; continue; // (flip between 0/1, and 2/3)
				case #char "\\"; beam.dir = beam.dir ^ 0b11; continue; // (flip between 0/3, and 1/2)
				case #char "-";  if is_odd(beam.dir)  then continue;
				case #char "|";  if is_even(beam.dir) then continue;
				case; nrg_here.* |= nrg >> 2 | nrg << 2; continue;
			}

			// Only reach here if we have to split the beam in 2.
			copy := array_add(beams);
			copy.row = beam.row;
			copy.col = beam.col;

			copy.dir = (beam.dir + 3) % 4;
			beam.dir = (beam.dir + 1) % 4;
		}
	}

	total := 0;
	for nrg_grid.array if it then total += 1;
	return total;
}

Light_Beam :: struct {
	row, col: int;
	dir: Direction;
}

Direction :: enum u8 {
	UP ::    0;
	RIGHT :: 1;
	DOWN ::  2;
	LEFT ::  3;
}

Energized_State :: enum_flags u8 {
	UP ::    1 << 0;
	RIGHT :: 1 << 1;
	DOWN ::  1 << 2;
	LEFT ::  1 << 3;
}

print_nrg_grid :: (nrg_grid: *Grid(Energized_State), lb: Light_Beam) {
	for r: 0..nrg_grid.rows-1 {
		for c: 0..nrg_grid.cols-1 {
			if r == lb.row && c == lb.col then {
				write_string(ifx lb.dir == 0 then "^" else ifx lb.dir == 1 then ">" else ifx lb.dir == 2 then "v" else "<");
			} else if address(nrg_grid, r, c).* then write_string("#"); else write_string(".");
		}
		write_string("\n");
	}
}

energize :: inline (dir: Direction) -> Energized_State {
	return cast(Energized_State)1 << cast(Energized_State)dir;
}

is_in_bounds :: inline (row: int, col: int, rows: int, cols: int) -> bool {
	return row >= 0 && row < rows && col >= 0 && col < cols;
}


testinput :: #string TESTINPUT
.|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|....
TESTINPUT;

#run example("1", 46, part_1(testinput));
#run example("2", 51, part_2(testinput));


#load "../aoc_util.jai";
