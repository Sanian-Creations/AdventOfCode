package whatever

import "core:fmt"
import "shared"

main :: proc() {
	using shared
	str :string:
`here we 
have a very
long string
that
has
some lines
in it.

also empty lines

and other stuff`
	
	windows_str :string: "here\r\nis a string\r\nthat has both\r\ncarriage return and\r\nnewlines"

	
	str_data := transmute([]u8) str;
	
	for ln in shared.iter_lines(&str_data) {
		fmt.printf("--%v--\n", string(ln));
	}
}
