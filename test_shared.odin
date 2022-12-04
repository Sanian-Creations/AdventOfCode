package whatever

import "core:fmt"
import "shared"

main :: proc() {
	using shared
	str ::
`here we 
have a very
long string
that
has
some lines
in it.

also empty lines

and other stuff`
	
	windows_str :: "here\r\nis a string\r\nthat has both\r\ncarriage return and\r\nnewlines"

	it1 := str
	it2 := windows_str
	
	for ln in shared.iter_lines(&it1) {
		fmt.printf("--%v--\n", string(ln));
	}

	fmt.println();
	
	for ln in shared.iter_lines(&it2) {
		fmt.printf("--%v--\n", string(ln));
	}
}
