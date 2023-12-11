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
// for :lines line, line_num: str { ... }

lines :: (str_: *string, body: Code, flags: For_Flags) #expand {
	#assert !flags "No flags suported for iterating by line";

	str := str_.*; // ensure non-destructive iteration by making local copy
	`it_index := -1;
	while str.count > 0 {
		it_index += 1;
		`it := consume_one_line(*str);
		#insert body;
	}
}

consume_one_line :: (str: *string, $support_crlf := true) -> line: string #no_abc {
	len := S.find_index_from_left(str.*, #char "\n") + 1; // length including line feed
	defer { str.data += len; str.count -= len; }
	return view(str, 0, len - ifx support_crlf && len > 1 && str.*[len - 2] == #char "\r" then 2 else 1, false);
}

first_line :: (str: string, $support_crlf := true) -> line: string #no_abc {
	len := S.find_index_from_left(str, #char "\n") + 1; // length including line feed
	return view(str, 0, len - ifx support_crlf && len > 1 && str[len - 2] == #char "\r" then 2 else 1, false);
}

Text_Grid :: struct {
	text_ptr: *u8;
	height:   int;
	width:    int;
	line_len: int;
}

text_grid :: (text: string) -> Text_Grid {
	using tg: Text_Grid;
	text_ptr = text.data;
	line_len = S.find_index_from_left(text, #char "\n") + 1;
	assert(line_len != 0); // -1 got returned
	width    = line_len - ifx line_len > 1 && text[line_len - 2] == #char "\r" then 2 else 1;
	height   = text.count / line_len;
	return tg;
}

// returns 0 if out of bounds.
get :: (using tg: Text_Grid, row: int, col: int) -> u8 {
	if col < 0 || col >= width  return 0;
	if row < 0 || row >= height return 0;
	return text_ptr[row * line_len + col];
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



// --- Comptime test ---

example :: (example: string, $proc: (string) -> $T, expected: T, input: string) {
	C :: #import "Compiler";
	got := proc(input);
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
