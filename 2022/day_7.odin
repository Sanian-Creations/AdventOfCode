package adventofcode

import "core:fmt"
import "core:strings"
import "core:runtime"
import "../aoc_util"

main :: proc() {
	data, ok := aoc_util.read_input()
	if !ok { return }

	just_do_the_whole_thing_this_day_is_a_mess(data)
}

Dir_Entry :: struct {
	name          : string,
	type          : enum { File, Directory },
	size          : int,
	content_start : int,
	content_len   : int,
	// I would preferably use a slice for these last two, but since the memory I'm putting all the files
	// into is a dynamic array, it might get resized and moved, rendering the pointers in the slices
	// invalid. Therefore, I just keep an index and length manually, and pass around the dynamic array with the
	// memory everywhere.
}

just_do_the_whole_thing_this_day_is_a_mess :: proc(data: string) {

	MEM_LEN  :: 500 // my input uses 472
	PATH_LEN :: 20  // my input uses 10
	
	memory := make([dynamic]Dir_Entry,  0, MEM_LEN)  // Where I store all files/directories
	path   := make([dynamic]^Dir_Entry, 0, PATH_LEN) // How I keep track of in which directory I am at any given time
	// defer delete(path)   // simple command line program, not required
	// defer delete(memory) // 

	iterator := data
	
	aoc_util.iter_lines(&iterator) // Skip line 1, we know the file starts with "$ cd /"
	append(&memory, Dir_Entry {
		name = "/",
		type = .Directory,
		size = 0,
		content_start = len(memory),
		content_len   = 0,
	})
	base_dir := &memory[len(memory)-1]

	
	append(&path, base_dir)
	
	next_line: for line in aoc_util.iter_lines(&iterator) {
		cwd := path[len(path)-1]
		
		if line[0:1] == "$" {
			if line[2:4] == "cd" {
				// > CHANGE DIR
				dir_name := line[5:]
				if dir_name == ".." {
					// > DIRECTORY UP
					pop(&path)
					if len(path) == 0 { break next_line }
					continue next_line
				}

				// > ENTER A DIR
				dir_content := get_content(&memory, cwd)
				for child in &dir_content {
					if child.type == .Directory && strings.compare(child.name, dir_name) == 0 {
						append(&path, &child)
						continue next_line
					}
				}

				panic("Couldn't find directory to enter")
			}
			
			// > Line must be an "$ ls" command
			
			cwd.content_start = len(memory)
			// Place the adress of the "slice" to begin on the current end of the memory.
			// The next few lines will list files and directories, and they will all be placed over there
			continue next_line
		}

		// > Line must be an entry listed by the ls command
				
		if line[:3] == "dir" {
			// > A DIR WAS LISTED
			append(&memory, Dir_Entry {
				name = line[4:],
				type = .Directory
			})
		} else {
			// > A FILE WAS LISTED
			filesize, int_len := aoc_util.get_int(line)
			append(&memory,  Dir_Entry {
				name = line[int_len+1:],
				type = .File,
				size = filesize,
			})
		}
		
		cwd.content_len += 1   // extend content of the current working directory to include the entry
	}

	get_size(base_dir, &memory) // DO NOT REMOVE, this initial call will set all directory sizes

	sum := get_size_of_at_most(base_dir, 100000, &memory)

	fmt.printf("Part 1: sum of 100000's = %v\n", sum)

	disk_size      :: 70000000
	required_space :: 30000000
	available_space    := disk_size - base_dir.size
	required_to_remove := required_space - available_space
	fmt.printf("Required to remove = %v\n", required_to_remove)

	best_dir_to_remove := get_dir_closest_in_size_above_N(base_dir, required_to_remove, &memory)

	fmt.printf("Part 2: Best directory to remove = \"%s\", size %v\n", best_dir_to_remove.name, best_dir_to_remove.size)
}

get_dir_closest_in_size_above_N :: proc(dir: ^Dir_Entry, N: int, mem: ^[dynamic]Dir_Entry) -> (best_candidate: ^Dir_Entry) {
	assert(dir.type == .Directory)
	if dir.size < N { return nil }

	best_candidate = dir
	dir_content := get_content(mem, best_candidate)
	for child in &dir_content {
		if child.type != .Directory { continue }
		other_candidate := get_dir_closest_in_size_above_N(&child, N, mem)
		
		if other_candidate != nil && other_candidate.size < best_candidate.size {
			best_candidate = other_candidate
		}
	}
	
	return best_candidate
}

get_size_of_at_most :: proc(dir: ^Dir_Entry, limit: int, mem: ^[dynamic]Dir_Entry) -> (size: int) {
	assert(dir.type == .Directory)
	if dir.size <= limit {
		size += dir.size
	}
	dir_content := get_content(mem, dir)
	for child in &dir_content {
		if child.type != .Directory { continue }
		size += get_size_of_at_most(&child, limit, mem)
	}
	return size
}

get_size :: proc(entry: ^Dir_Entry, mem: ^[dynamic]Dir_Entry) -> (size: int) {
	switch entry.type {
	  case .Directory:
		if entry.size != 0 { return entry.size }
		dir_content := get_content(mem, entry)
		for child in &dir_content {
			size += get_size(&child, mem)
		}
		entry.size = size
		return size
		
	  case .File:
		return entry.size
		
	  case: panic("")
	}
}

get_content :: #force_inline proc(mem: ^[dynamic]Dir_Entry, dir: ^Dir_Entry) -> []Dir_Entry {
	return mem[dir.content_start:dir.content_start+dir.content_len]
}
