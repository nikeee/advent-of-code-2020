# Compile:
#     crystal build main.cr
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
puts "Winning player's score; Part1: #{part1}"

# Part 2
# TODO

