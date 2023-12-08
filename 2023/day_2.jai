main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input)); // Part 1: 2685
	print("Part 2: %\n", part_2(input)); // Part 2: 83707
}

part_1 :: (input: string) -> int {

	total := 0; // sum of all game numbers which are possible. gamenr = line num

	for :lines line, line_index: input {
		advance(*line, S.find_index_from_left(line, #char ":") + 2);

		// Consume every string "N color" on this line. Skip to the next line if an invalid amount of cubes is found.
		// If the line is successfully consumed without invalid amounts, the game nr is added to total.

		while 1 {
			num := S.parse_int(*line);
			color := line[1];
			if color == {
			case #char "r"; if num > 12 continue line; advance(*line, 1 + 3); // " red"
			case #char "g"; if num > 13 continue line; advance(*line, 1 + 5); // " green"
			case #char "b"; if num > 14 continue line; advance(*line, 1 + 4); // " blue"
			case;
				print("Parse Error: expected 'r', 'g' or 'b', got '%'\n", cast(string) view(*color, 1));
				assert(false);
			}

			if line.count == 0 { // end of line
				total += line_index + 1;
				continue line;
			}

			advance(*line, 2);
		}
	}

	return total;
}

part_2 :: (input: string) -> int {

	total := 0; // sum of all game numbers which are possible. gamenr = line num

	for :lines line: input {
		advance(*line, S.find_index_from_left(line, #char ":") + 2);

		// Consume every string "N color" on this line. Remember the biggest value of each color.
		// At the end of each line, multiply the minimum required cubes and add to total.

		min_red, min_blue, min_green := 0;
		while 1 {
			num := S.parse_int(*line);
			color := line[1];
			if color == {
			case #char "r"; if num > min_red   min_red   = num; advance(*line, 1 + 3); // " red"
			case #char "g"; if num > min_green min_green = num; advance(*line, 1 + 5); // " green"
			case #char "b"; if num > min_blue  min_blue  = num; advance(*line, 1 + 4); // " blue"
			case;
				print("Parse Error: expected 'r', 'g' or 'b', got '%'\n", cast(string) view(*color, 1));
				assert(false);
			}

			if line.count == 0 { // end of line
				total += min_red * min_green * min_blue;
				continue line;
			}

			advance(*line, 2);
		}
	}

	return total;
}

#run example("1", part_1, 1 + 2 + 5, #string TESTINPUT
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
TESTINPUT);

#run example("2", part_2, 2286, #string TESTINPUT
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
TESTINPUT);


#load "../aoc_util/aoc_util.jai";