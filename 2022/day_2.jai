main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input)); // Part 1: 10595
	print("Part 2: %\n", part_2(input)); // Part 2: 9541
}

part_1 :: (input: string) -> int { return loop_over_lines(input, part_1_calculation); }
part_2 :: (input: string) -> int { return loop_over_lines(input, part_2_calculation); }

loop_over_lines :: (input: string, $points_calc: (int, int) -> int) -> int {
	total := 0;
	for :lines line: input {
		num1: int = line[0] - #char "A"; // assuming A B C, num1 is 0 1 2
		num2: int = line[2] - #char "X"; // assuming X Y Z, num2 is 0 1 2
		total += points_calc(num1, num2);
	}
	return total;
}

part_1_calculation :: (their_move: int, my_move: int) -> int { return 1 + my_move + outcome(my_move, their_move) * 3; }
part_2_calculation :: (their_move: int, outcome: int) -> int { return 1 + my_move(their_move, outcome) + outcome * 3; }

my_move :: (their_move: int, outcome: int) -> int { return (2 + their_move + outcome) % 3; }
outcome :: (my_move: int, their_move: int) -> int { return (4 - their_move + my_move) % 3; }

/*

Why does this code work? Detailed explanation.

Suppose we map all moves into range [0..2]
ROCK     :: 0;
PAPER    :: 1;
SCISSORS :: 2;
(if we add 1, we get the points for each move. Rock = 1, Paper = 2, Scissors = 3)

Let's do the same for the outcome of a game.
LOSS     :: 0;
DRAW     :: 1;
WIN      :: 2;
(if we multiply by 3 we get the number of points for each outcome. Loss = 0, Draw = 3, Win = 6)

Now let's put all possible games and their outcomes in a table.

T: Their move, M: My move, O: Outcome
O T M
-----    Pattern?
0 0 2    on O=0, M = T + 2
0 1 0            M = T - 1
0 2 1            M = T - 1
1 0 0    on O=1, M = T + 0
1 1 1            M = T + 0
1 2 2            M = T + 0
2 0 1    on O=2, M = T + 1
2 1 2            M = T + 1
2 2 0            M = T - 2

Doesn't look like much of a pattern, does it?

Now think about what happens to numbers mod 3. By applying mod 3, any value maps back to the range [0..2]
number:  ... -3 -2 -1  0  1  2  3  4  5  6  7 ...
mod 3:   ...  0  1  2  0  1  2  0  1  2  3  0 ...
                 ^  ^
Let's apply mod 3 to all the values that we add onto the end. T-1 becomes T+2, and T-2 becomes T+1

O T M
-----    Pattern!
0 0 2    on O=0,  M  =  T + 2
0 1 0             M  =  T + 2
0 2 1             M  =  T + 2
1 0 0    on O=1,  M  =  T + 0
1 1 1             M  =  T + 0
1 2 2             M  =  T + 0
2 0 1    on O=2,  M  =  T + 1
2 1 2             M  =  T + 1
2 2 0             M  =  T + 1

Now THAT'S a pattern! So we can make this formula M = T + N, where N is determined by O.
But can we make a formula to go from O to N? Let's see:

O N
---    Pattern?
0 2    N  =  O + 2
1 0    N  =  O - 1
2 1    N  =  O - 1

Hmm... where have I seen this before... mod 3 it is!

O N
---    Pattern!
0 2    N  =  O + 2
1 0    N  =  O + 2
2 1    N  =  O + 2

Let's put it in the formula!

M  =  T + N
N  =  O + 2
M  =  T + (O + 2)
M  =  T + O + 2

We now have a formula to calculate My move from only Their move and the Outcome!
Just remember that this only works mod 3. The actual equation is this:
M  =  (T + O + 2) mod 3

We can also rearrange a bit to get a formula for Outcome based on My move and Their move.
    M      =  T + O + 2
  M - 2    =    T + O
M - 2 - T  =      O
    O      =  M - 2 - H

Nice! However... There's some caveats when implementing this in most programming languages.
When using the % operator, we don't get the modulus, we get the remainder.
They are similar, but different. The difference is that -2 mod 3 = 1, but the remainder of -2 / 3 is still -2.
The % operator can bring positive values back to the range [0..2], but not negative values.
So, to keep everything mod 3, we have to make sure that our values do not go into the negatives.
Unfortunately, our new formula doesn't do that.

O  =  M - 2 - T

There's -2, and -T.
We can swap out -2 for +1, since they are the same mod 3.

O  =  M + 1 - T

That still leaves -T.
We can assume that T itself is always in range [0..2], so -T is no lower than -2.
Knowing that, we can simply add 3 to -T so that it is always positive.

O  =  M + 1 + 3 - T
O  =  M + 4 - T

And there you have it! A formula for Outcome, and a formula for My move
O  =  (M + 4 - T) mod 3
M  =  (T + O + 2) mod 3

*/


testinput :: #string TESTINPUT
A Y
B X
C Z
TESTINPUT;

#run example("1", 15, part_1(testinput));
#run example("2", 12, part_2(testinput));


#load "../aoc_util.jai";
