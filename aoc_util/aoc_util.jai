#import "Basic";
S :: #import "String";
File :: #import "File";

// --- Reading the input ---

read_input :: () -> input := "", ok := false {
	args := get_command_line_arguments();
	if args.count != 2 {
		print("Please specify the input file as the only argument:\nday_N.exe input_N.txt\n");
		return;
	}
	input, ok := File.read_entire_file(args[1]);
	return input, ok;
}



// --- Line iteration ---

// Usage:
// for :lines line, line_num: str { ... }

lines :: (str_: *string, body: Code, flags: For_Flags) #expand {
	#assert !flags "No flags suported for iterating by line";

	str := cast([]u8) str_.*; // ensure non-destructive iteration by making local copy
	`it_index := 0;
	while str.count > 0 {
		line_len, adv_by := str.count;
		for c, ci: str {
			if c != #char "\n"  continue;
			line_len = ci - cast(int)(ci > 0 && str[ci-1] == #char "\r");
			adv_by   = ci + 1;
			break;
		}

		`it := cast(string) view(str.data, line_len);
		str.data += adv_by; str.count -= adv_by;
		it_index += 1;

		#insert body;
	}
}



// --- Quick and easy printing ---

print_expr :: ($c: Code) #expand {
	fmt_string :: #run -> string {
		#import "Compiler";
		#import "Program_Print";

		sb: String_Builder;
		print_expression(*sb, compiler_get_nodes(c));
		append(*sb, " is %\n");

		return builder_to_string(*sb);
	}

	print(fmt_string, #insert c);
}



// --- Comptime test ---

example :: (example: string, $proc: (string) -> $T, expected: T, input: string) {
	got := proc(input);
	if got != expected {
		print("Failed example %: Expected % but got %!\n", example, expected, got);
		set_build_options_dc(.{do_output = false});
	}
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

ASSERT_MSG :: "Can't make view [%, %), arr.count = %\n";

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
