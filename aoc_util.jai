Basic :: #import "Basic";
using Basic;
S :: #import "String";
File :: #import "File";
string_to_int :: #bake_arguments Basic.string_to_int(base = 10, T = int);

// --- Reading the input ---

read_input :: () -> input: string #expand {
	args := get_command_line_arguments();
	if args.count != 2 {
		print("Please specify the input file as the only argument:\nday_N.exe input_N.txt\n");
		`return;
	}

	input, ok := File.read_entire_file(args[1]);
	if !ok `return;

	return input;
}



// --- Line iteration ---

// Usage:
// for :lines line, line_index: str { ... }
lines :: (str_: *string, body: Code, flags: For_Flags) #expand {
	#assert !flags "No flags suported for iterating by line";

	str := str_.*; // ensure non-destructive iteration by making local copy
	`it_index := -1;
	while str.count > 0 {
		it_index += 1;
		`it := consume_line(*str);
		#insert body;
	}
}

consume_line :: (str: *string, $trimmed := true) -> line: string {
	len := 1 + S.find_index_from_left(str.*, #char "\n");
	if !len then len = str.count;
	line := view(str, 0, len, false);
	str.data += len; str.count -= len;
	#if trimmed trim_nl(*line);
	return line;
}

first_line :: (str: string, $trimmed := true) -> line: string #must {
	len := 1 + S.find_index_from_left(str, #char "\n");
	if !len then len = str.count;
	line := view(str, 0, len, false);
	#if trimmed trim_nl(*line);
	return line;
}

trim_nl :: (str: *string) {
	if str.count > 0 && str.*[str.count-1] == #char"\n" {
		str.count -= 1;
		if str.count > 0 && str.*[str.count-1] == #char"\r" then str.count -= 1;
	}
}

trim_nl :: (str__: string) -> string #must {
	str := str__;
	inline trim_nl(*str);
	return str;
}



// --- Grids ---

// Lots of input in aoc is formatted as grids, where there's a set of lines that are all
// the same length and they represent a 2-dimensional space.
// This struct is simply a view of such an input with some helper procs to get
// elements at specific offsets. Keep in mind it is a view of a string!
Text_Grid_View :: struct {
	source:   string;
	width:    int; #place width;  cols: int;
	height:   int; #place height; rows: int;
	line_len: int;
}

// A simpler grid structure that is not a view of a string, but simply an array with width*height elements.
// For modification of a grid, you probably want to convert your Text_Grid_View into one of these, otherwise you
// might accidentally modify your input string. You can use alloc_grid to convert a TGV into a Grid(u8).
Grid :: struct(T: Type) {
	array: []T;
	width:  int; #place width;  cols: int;
	height: int; #place height; rows: int;
}

// For inputs where the whole input is one grid
grid_view :: (text__: string) -> Text_Grid_View {
	text := text__;
	return consume_grid_view(*text);
}

// For inputs that contain multiple grids.
consume_grid_view :: (text: *string) -> Text_Grid_View {
	if text.count <= 0 return .{};
	line1 := consume_line(text, false);
	tg := Text_Grid_View.{
		source.data = line1.data, // count not yet known
		line_len    = line1.count,
		width       = trim_nl(line1).count,
		height      = 1,
	};
	while 1 {
		line := consume_line(text, false);
		if line.count != tg.line_len {
			// just in case the last line is not newline-terminated, still include it.
			if line.count == tg.width && line[line.count-1] != #char "\n" then tg.height += 1;
			break;
		}

		// Every line of same length adds one height.
		tg.height += 1;
	}

	tg.source.count = tg.height * tg.line_len;

	// The line that did not match in length is also consumed.
	// I assume it is usually an empty line or end of string.
	return tg;
}

get :: (using tg: Text_Grid_View, row: int, col: int, $use_default := true, $default: u8 = 0) -> u8 {
	in_bounds := col >= 0 && col < cols && row >= 0 && row < rows;
	#if use_default { if !in_bounds then return default; }
	else assert(in_bounds, "row: %, col: %, rows: %, cols: %\n", row, col, rows, cols);
	return #no_abc source[row * line_len + col]; // prior bounds check means we can #no_abc here.
}
get :: (using g: Grid, row: int, col: int, $use_default := true, $default: u8 = 0) -> u8 {
	in_bounds := col >= 0 && col < cols && row >= 0 && row < rows;
	#if use_default { if !in_bounds then return default; }
	else assert(in_bounds, "row: %, col: %, rows: %, cols: %\n", row, col, rows, cols);
	return #no_abc array[row * cols + col]; // prior bounds check means we can #no_abc here.
}
address :: (using g: Grid($T), row: int, col: int) -> *T {
	return *array[row * cols + col];
}

get_row :: (using tg: Text_Grid_View, row: int) -> string {
	assert(row >= 0 && row < rows, "row: %, rows: %\n", row, rows);
	return view(source, row * line_len, width);
}
get_row :: (using g: Grid($T), row: int) -> []T {
	assert(row >= 0 && row < rows, "row: %, rows: %\n", row, rows);
	return view(array, row * width, width);
}

get_col :: (using tg: Text_Grid_View, col: int, buffer: string) {
	assert(buffer.count == height, "buffer.count: %, height: %\n", buffer.count, height);
	assert(col >= 0 || col < cols, "col: %, cols: %\n", col, cols);
	for r: 0..rows-1 { buffer[r] = #no_abc source[r * line_len + col]; }
}
get_col :: (using g: Grid, col: int, buffer: string) {
	assert(buffer.count == height, "buffer.count: %, height: %\n", buffer.count, height);
	assert(col >= 0 || col < cols, "col: %, cols: %\n", col, cols);
	for r: 0..rows-1 { buffer[r] = #no_abc array[r * cols + col]; }
}

free :: inline (grid: Grid) { array_free(grid.array); }

alloc_grid :: inline (rows: int, cols: int, $T: Type = u8) -> Grid(T) {
	return Grid(T).{
		array = NewArray(rows * cols, T),
		rows  = rows,
		cols  = cols,
	};
}

alloc_grid :: (tg: Text_Grid_View) -> Grid(u8) {
	using g := Grid(u8).{
		array = NewArray(tg.rows * tg.cols, u8),
		rows  = tg.rows,
		cols  = tg.cols,
	};
	// copy everything over into a separate grid (cannot copy at once because we are not copying the newlines over)
	for r: 0..rows-1  typed_memcpy(array.data + r * cols, tg.source.data + r * tg.line_len, cols);
	return g;
}



// --- Quick and easy printing ---

print_expr :: ($c: Code) #expand {
	expr_string :: #run -> string {
		C :: #import "Compiler";
		PP :: #import "Program_Print";

		sb: String_Builder;
		PP.print_expression(*sb, C.compiler_get_nodes(c));

		return builder_to_string(*sb);
	}
	print("% is %\n", expr_string, #insert c);
}

print :: inline (using tg: Text_Grid_View) {
	write_string(source);
	write_string(ifx source[source.count-1] != #char "\n" then "\n\n" else "\n");
}

print :: inline (grid: Grid($T)) {
	VIEW :: #ifx T == u8 then string; else []T;
	for r: 0..grid.rows-1 print("%\n", cast(VIEW)view(grid.array, r * grid.width, grid.width, false));
	write_string("\n");
}



// --- Comptime test ---

example :: (example: string, expected: int, got: int) {
	C :: #import "Compiler";
	if got != expected {
		print("Failed example %: Expected % but got %!\n", example, expected, got);
		C.set_build_options_dc(.{do_output = false});
	}
}



// --- Quick Mafs ---

gcd :: (x: int, y: int) -> int #must {
	x, y := x, y;
	while y != 0 {
		x %= y;
		x, y = y, x;
	}
	return ifx x < 0 then -x else x;
}

lcm :: (x: int, y: int) -> int #must {
	return x / gcd(x, y) * y;
}

abs :: inline (num: int) -> int {
	return ifx num < 0 then -num else num;
}

is_even :: inline (num: $T) -> bool { return (num & 1) == 0; }
is_odd ::  inline (num: $T) -> bool { return (num & 1) != 0; }

sum :: inline (arr: []$T) -> int {
	total := 0;
	for arr total += xx it;
	return total;
}



// --- Datastructures ---

Fixed_Size_Stack :: struct(N: int, T: Type) {
	// for dynamic stack just use [..], it has all the same features built-in
	array: [N] T;
	count: int;
}
push :: (stack: *Fixed_Size_Stack, val: stack.T) {
	stack.*[stack.count] = val; // use builtin bounds check.
	stack.count += 1;
}
pop :: inline (stack: *Fixed_Size_Stack) -> stack.T {
	defer stack.count -= 1;
	return stack[stack.count-1];
}
operator *[] :: inline (stack: *Fixed_Size_Stack, index: int) -> *stack.T {
	return *stack.array[index];
}



// --- Arrays ---

chop_off_end :: (source: *[]$T, len: int) -> []T {
	defer source.count -= len;
	return view_from(source, source.count - len);
}

typed_memcpy :: inline (dest: *$T, src: *T, count: s64) {
	memcpy(dest, src, count * size_of(T));
}

zero_out_array :: (arr: []$T) {
	memset(arr.data, 0, arr.count * size_of(T));
}


// --- String indexing ---

safe_index :: (str: string, index: int, default: u8 = 0) -> u8 {
	if index < 0 || index >= str.count return default;
	return #no_abc str[index];
}

move_right_while :: inline (str: string, start: int, $proc: (u8) -> bool, $stop_at_last := false) -> int {
	i := start;
	#if stop_at_last {
		while i+1 < str.count && inline proc(#no_abc str[i+1]) { i += 1; }
	} else {
		while i < str.count   && inline proc(#no_abc str[i])   { i += 1; }
	}
	return i;
}

move_left_while :: inline (str: string, start: int, $proc: (u8) -> bool, $stop_at_last := false) -> int {
	i := start;
	#if stop_at_last {
		while i > 0  && inline proc(#no_abc str[i-1]) { i -= 1; }
	} else {
		while i >= 0 && inline proc(#no_abc str[i])   { i -= 1; }
	}
	return i;
}

find_num_start :: (str: string, from: int) -> int {
	return move_left_while(str, from, is_digit, stop_at_last = true);
}

// (non-inclusive)
find_num_end :: (str: string, from: int) -> int {
	return move_right_while(str, from, is_digit);
}



// --- Slicing & Dicing ---

view :: (data: *$T, count: int) -> []T #expand {
	v: []T = ---;
	v.data  = data;
	v.count = count;
	return v;
}

/* Generates all overloads */
/*
#insert -> string {
	fmts :: string.[
		"view :: (v: %1, from := 0, count: int, $bounds_check := true, $loc := #caller_location) -> %2 #expand { view_assertions(); return %3view(v.data + from, count); }\n",
		"iview :: (v: %1, from := 0, to: int, $bounds_check := true, $loc := #caller_location) -> %2 #expand { iview_assertions(); return %3view(v.data + from, to - from); }\n",
		"view_from :: (v: %1, from : int, $bounds_check := true, $loc := #caller_location) -> %2 #expand { view_from_assertions(); return %3view(v.data + from, v.count - from); }\n",
	];
	combinations :: [3]string.[ // type_in, type_out, cast
		.["[]$E", "[]E", ""],
		.["*[]$E", "[]E", ""],
		.["[$N]$E", "[]E", ""],
		.["*[$N]$E", "[]E", ""],
		.["string", "string", "xx "],
		.["*string", "string", "xx "],
	];
	sb: String_Builder;
	for fmt: fmts for combinations print_to_builder(*sb, fmt, it[0], it[1], it[2]);
	return builder_to_string(*sb);
}
*/

// Pasted in result of what the code above generates. probably barely impacts comptime but whatever, this makes it easier to look up definitions too.
view :: (v: []$E, from := 0, count: int, $bounds_check := true, $loc := #caller_location) -> []E #expand { view_assertions(); return view(v.data + from, count); }
view :: (v: *[]$E, from := 0, count: int, $bounds_check := true, $loc := #caller_location) -> []E #expand { view_assertions(); return view(v.data + from, count); }
view :: (v: [$N]$E, from := 0, count: int, $bounds_check := true, $loc := #caller_location) -> []E #expand { view_assertions(); return view(v.data + from, count); }
view :: (v: *[$N]$E, from := 0, count: int, $bounds_check := true, $loc := #caller_location) -> []E #expand { view_assertions(); return view(v.data + from, count); }
view :: (v: string, from := 0, count: int, $bounds_check := true, $loc := #caller_location) -> string #expand { view_assertions(); return xx view(v.data + from, count); }
view :: (v: *string, from := 0, count: int, $bounds_check := true, $loc := #caller_location) -> string #expand { view_assertions(); return xx view(v.data + from, count); }
iview :: (v: []$E, from := 0, to: int, $bounds_check := true, $loc := #caller_location) -> []E #expand { iview_assertions(); return view(v.data + from, to - from); }
iview :: (v: *[]$E, from := 0, to: int, $bounds_check := true, $loc := #caller_location) -> []E #expand { iview_assertions(); return view(v.data + from, to - from); }
iview :: (v: [$N]$E, from := 0, to: int, $bounds_check := true, $loc := #caller_location) -> []E #expand { iview_assertions(); return view(v.data + from, to - from); }
iview :: (v: *[$N]$E, from := 0, to: int, $bounds_check := true, $loc := #caller_location) -> []E #expand { iview_assertions(); return view(v.data + from, to - from); }
iview :: (v: string, from := 0, to: int, $bounds_check := true, $loc := #caller_location) -> string #expand { iview_assertions(); return xx view(v.data + from, to - from); }
iview :: (v: *string, from := 0, to: int, $bounds_check := true, $loc := #caller_location) -> string #expand { iview_assertions(); return xx view(v.data + from, to - from); }
view_from :: (v: []$E, from : int, $bounds_check := true, $loc := #caller_location) -> []E #expand { view_from_assertions(); return view(v.data + from, v.count - from); }
view_from :: (v: *[]$E, from : int, $bounds_check := true, $loc := #caller_location) -> []E #expand { view_from_assertions(); return view(v.data + from, v.count - from); }
view_from :: (v: [$N]$E, from : int, $bounds_check := true, $loc := #caller_location) -> []E #expand { view_from_assertions(); return view(v.data + from, v.count - from); }
view_from :: (v: *[$N]$E, from : int, $bounds_check := true, $loc := #caller_location) -> []E #expand { view_from_assertions(); return view(v.data + from, v.count - from); }
view_from :: (v: string, from : int, $bounds_check := true, $loc := #caller_location) -> string #expand { view_from_assertions(); return xx view(v.data + from, v.count - from); }
view_from :: (v: *string, from : int, $bounds_check := true, $loc := #caller_location) -> string #expand { view_from_assertions(); return xx view(v.data + from, v.count - from); }

// Both view and iview should work without specifying 'count' or 'to' and then default to the end of the array. This is the same signature as view_from.
view  :: view_from;
iview :: view_from;

#scope_file

iview_assertions     :: () #expand { _iview_assertions    (`v, `from, `to,    `bounds_check, `loc); }
view_assertions      :: () #expand { _view_assertions     (`v, `from, `count, `bounds_check, `loc); }
view_from_assertions :: () #expand { _view_from_assertions(`v, `from,         `bounds_check, `loc); }

ASSERT_MSG :: "Couldn't make view [%, %) on array of length %\n";

_iview_assertions :: (v: $Arr, from: int, to: int, $bounds_check: bool, $loc: Source_Code_Location) #expand {
	#if is_constant(0    <= from)    #assert 0    <= from;
	#if is_constant(from <= to)      #assert from <= to;
	#if is_constant(to   <= v.count) #assert to   <= v.count;
	#if bounds_check assert( (0 <= from) && (from <= to) && (to <= v.count), ASSERT_MSG, from, to, v.count, loc=loc);
}

_view_assertions :: (v: $Arr, from: int, count: int, $bounds_check: bool, $loc: Source_Code_Location) #expand {
	#if is_constant(from  >= 0)              #assert from  >= 0;
	#if is_constant(count >= 0)              #assert count >= 0;
	#if is_constant(from + count <= v.count) #assert from + count <= v.count;
	#if bounds_check assert( (from >= 0) && (count >= 0) && (from + count <= v.count), ASSERT_MSG, from, from+count, v.count, loc=loc);
}

_view_from_assertions :: (v: $Arr, from: int, $bounds_check: bool, $loc: Source_Code_Location) #expand {
	#if is_constant(0    <= from)    #assert 0    <= from;
    #if is_constant(from <= v.count) #assert from <= v.count;
	#if bounds_check assert( (0 <= from) && (from <= v.count), ASSERT_MSG, from, "->", v.count, loc=loc);
}

#scope_export
