main :: () {
	input := read_input();
	print("Part 1: %\n", part_1(input)); // Part 1: 249638405
	print("Part 2: %\n", part_2(input)); // Part 2: 249776650
}

part_1 :: #bake_arguments same_calculation(J_is_joker = false);
part_2 :: #bake_arguments same_calculation(J_is_joker = true);

same_calculation :: (input: string, $J_is_joker: bool) -> int {

	hands: [..]Hand; defer array_free(hands);

	for :lines line, line_index: input {
		hand := array_add(*hands);
		hand.cards = xx line.data;
		hand.bid = string_to_int(view(line, 6));
		hand.strength = calc_strength(hand.cards, J_is_joker);
	}

	Sort.quick_sort(hands, #bake_arguments compare_hands(J_is_joker=J_is_joker));

	total := 0;
	for hands  total += it.bid * (it_index+1);
	return total;
}

calc_strength :: (cards: *[5]u8, $J_is_joker: bool) -> Strength {
	unique_cards: [5]u8;
	card_count:   [5]u8;
	unique_count: int;
	for 0..cards.count-1 {
		card := cards.*[it];
		found, index := array_find(view(unique_cards.data, unique_count), card);
		if found {
			card_count[index] += 1;
		} else {
			unique_cards[unique_count] = card;
			card_count[unique_count] = 1;
			unique_count += 1;
		}
	}

	strength: Strength = ---;
	if unique_count == {
		case 1; strength = .Five_oak;
		case 2; strength = ifx card_count[0] & 0b10 then .Full_House else .Four_oak; // FH has [3,2], FOAK has [4,1], bit 0b10 is only in 2 and 3.
		case 3; strength = ifx card_count[0] == 2 || card_count[1] == 2 then .Two_Pair else .Three_oak; // TP has [2,2,1], TOAK has [3,1,1]
		case 4; strength = .One_Pair;
		case 5; strength = .High_Card;
		case; assert(false, "unreachable");
	}

	#if !J_is_joker {
		return strength;
	} else {
		has_joker, joker_index := array_find(view(unique_cards.data, unique_count), #char "J");

		if !has_joker return strength;

		if #complete strength == {
			case .High_Card;  return .One_Pair;
			case .One_Pair;   return .Three_oak;
			case .Two_Pair;   return ifx card_count[joker_index] == 1 then .Full_House else .Four_oak;
			case .Three_oak;  return .Four_oak;
			case .Full_House; return .Five_oak;
			case .Four_oak;   return .Five_oak;
			case .Five_oak;   return .Five_oak;
		}
	}
}

card_value :: (card: u8, $J_is_joker: bool) -> u8 {
	if is_digit(card) return card - #char "0";
	if card == {
		case #char "T"; return 10;
		case #char "J"; return #ifx J_is_joker then 0; else 11;
		case #char "Q"; return 12;
		case #char "K"; return 13;
		case #char "A"; return 14; // or 1??? unclear from explanation. this seems to work though.
		case; assert(false, "unreachable"); return 0;
	}
}

compare_hands :: (a: Hand, b: Hand, $J_is_joker: bool) -> int {
	if a.strength > b.strength return 1;
	if a.strength < b.strength return -1;
	for 0..4 {
		aval := card_value(a.cards.*[it], J_is_joker);
		bval := card_value(b.cards.*[it], J_is_joker);
		if aval > bval return 1;
		if aval < bval return -1;
	}
	return 0;
}

Hand :: struct {
	cards:    *[5]u8;
	strength: Strength;
	bid:      int;
}

Strength :: enum {
	High_Card;  // 5 unique cards [1,1,1,1,1]  Joker -> One_Pair
	One_Pair;   // 4 unique cards [2,1,1,1]    Joker -> Three_oak
	Two_Pair;   // 3 unique cards [2,2,1]      1 Joker -> Full_House, 2 Jokers -> Four_oak
	Three_oak;  // 3 unique cards [3,1,1]      Joker -> Four_oak
	Full_House; // 2 unique cards [3,2]        Joker -> Five_oak
	Four_oak;   // 2 unique cards [4,1]        Joker -> Five_oak
	Five_oak;   // 1 unique cards [5]          Joker -> Five_oak
}


testinput :: #string TESTINPUT
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
TESTINPUT;

#run example("1", 6440, part_1(testinput));
#run example("2", 5905, part_2(testinput));


Sort :: #import "Sort";
#load "../aoc_util.jai";
