# Compile:
#     crystal build --release main.cr
# Use:
#     ./main < input.txt
# Compiler version:
#     crystal --version
#     Crystal 0.35.1 [5999ae29b] (2020-06-19)


lines = STDIN.gets_to_end.strip('\n')

decks_str = lines.split("\n\n")

player_1_initial_deck = decks_str[0].split("\n").skip(1).map {|card| card.to_i }
player_2_initial_deck = decks_str[1].split("\n").skip(1).map {|card| card.to_i }

def compute_score(deck : Enumerable(Int32))
	deck.map_with_index do |card, index|
		factor = deck.size - index
		factor * card
	end
	.sum
end

# Part 1

def play_game_part1(player_1_initial, player_2_initial)

	player_1_deck = Deque.new(player_1_initial)
	player_2_deck = Deque.new(player_2_initial)

	while player_1_deck.size > 0 && player_2_deck.size > 0
		player_1_card = player_1_deck.shift
		player_2_card = player_2_deck.shift

		if player_1_card > player_2_card
			player_1_deck.push(player_1_card)
			player_1_deck.push(player_2_card)
		elsif player_1_card < player_2_card
			player_2_deck.push(player_2_card)
			player_2_deck.push(player_1_card)
		else
			puts "This cannot happen! You should take a look if this happens."
		end
	end

	player_1_deck.size > 0 ? player_1_deck : player_2_deck
end


winner_part1 = play_game_part1(player_1_initial_deck, player_2_initial_deck)
part1 = compute_score(winner_part1)
puts "Winning player's score (Combat); Part 1: #{part1}"

# Part 2

def play_game_part2(player_1_initial, player_2_initial) : Tuple(Char, Array(Int32))

	player_1_deck = Deque.new(player_1_initial)
	player_2_deck = Deque.new(player_2_initial)

	previous_states = Set(Tuple(String, String)).new

	while player_1_deck.size > 0 && player_2_deck.size > 0

		current_state = create_state(player_1_deck, player_2_deck)

		if previous_states.includes? current_state
			# puts "Player 1 wins (recursion prevention)"
			return Tuple.new('1', player_1_deck.to_a)
		end

		previous_states.add(current_state)

		card_1 = player_1_deck.shift
		card_2 = player_2_deck.shift

		cards_to_push = nil
		winning_player = nil

		if card_1 <= player_1_deck.size && card_2 <= player_2_deck.size

			next_deck_1 = player_1_deck.first(card_1)
			next_deck_2 = player_2_deck.first(card_2)

			child_game_result = play_game_part2(next_deck_1, next_deck_2)

			winning_player = child_game_result[0]
			cards_to_push = Tuple.new(
				winning_player == '1' ? card_1 : card_2,
				winning_player == '1' ? card_2 : card_1,
			)

		else
			if card_1 > card_2
				winning_player = '1'
				cards_to_push = Tuple.new(card_1, card_2)
			elsif card_1 < card_2
				winning_player = '2'
				cards_to_push = Tuple.new(card_2, card_1)
			else
				raise "This cannot happen! You should take a look if this happens."
			end
		end

		winning_deck = winning_player == '1' ? player_1_deck : player_2_deck
		winning_deck.push(cards_to_push[0])
		winning_deck.push(cards_to_push[1])
	end

	return Tuple.new(
		player_1_deck.size > 0 ? '1' : '2',
		player_1_deck.size > 0 ? player_1_deck.to_a : player_2_deck.to_a
	)

end

def create_state(deck_1, deck_2)
	a = deck_1.map {|i| i.to_s}.join(" ")
	b = deck_2.map {|i| i.to_s}.join(" ")
	{a, b}
end

winning_player_part2 = play_game_part2(player_1_initial_deck, player_2_initial_deck)
winning_deck = winning_player_part2[1]
part2 = compute_score(winning_deck)
puts "Winning player's score (Recursive Combat); Part 2: #{part2}"
