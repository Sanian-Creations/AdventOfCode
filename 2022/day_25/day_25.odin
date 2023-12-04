package aoc

import "core:fmt"
import "../../aoc_util"

main :: proc() {
	/* test() */
	/* return */

	data, ok := aoc_util.read_input()
	if !ok { return }

	part1(data)
}

part1 :: proc(data: string) {

	total := i64(0)
	
	iterator := data
	for line in aoc_util.iter_lines(&iterator) {
		total += parse_snafu(line)
	}

	buf: [32]u8
	fmt.printf("part 1: %v, %v\n", total, to_snafu(total, buf[:]))
}

to_snafu :: proc(num: i64, buffer: []u8) -> string {
	pos :: [5]u8{'0', '1', '2', '=', '-'}
	neg :: [5]u8{'0', '-', '=', '2', '1'}
	
	lut := num < 0 ? neg : pos
	num := abs(num)
	
	for i := len(buffer)-1 ;; i -= 1 {
		rem := num % 5
		buffer[i] = lut[rem]
		if num < 3 { return transmute(string) buffer[i:] }
		num = num / 5 + i64(rem > 2)
	}
}

parse_snafu :: proc(str: string) -> i64 {
	value : i64 = 1
	total : i64 = 0
	for i := len(str)-1; i >= 0; i -= 1 {
		switch str[i] {
		  case '0': ;
		  case '1': total += value
		  case '2': total += value * 2
		  case '-': total -= value
		  case '=': total -= value * 2	
		  case:     panic("")
		}
		
		value *= 5
	}
	
	return total
}

test :: proc() {

	examples :=	[]i64{
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9,
		10,
		15,
		20,
		2022,
		12345,
		314159265,
		1747, 906, 198, 11, 201, 31, 1257, 32, 353, 107, 7, 3, 37,
	}

	buf: [32]u8 // log5(max_i64) = 27.13
	
	for i in examples {
		snafu  := to_snafu(i, buf[:])
		normal := parse_snafu(snafu)
		fmt.printf("%c % 10v | % 14v | % 10v\n", u8(normal == i ? 'O' : 'X'), i, snafu, normal)
	}
}
