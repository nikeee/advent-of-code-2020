# Compile:
#     crystal build main.cr
# Use:
#     ./main < input.txt
# Compiler version:
#     crystal --version
#     Crystal 0.35.1 [5999ae29b] (2020-06-19)


lines = STDIN.gets_to_end.strip('\n')

decks_str = lines.split("\n\n")

player_1_deck = decks_str[0].split("\n").skip(1).map {|card| card.to_i }
player_2_deck = decks_str[1].split("\n").skip(1).map {|card| card.to_i }

player_1_deck = Deque.new(player_1_deck)
player_2_deck = Deque.new(player_2_deck)

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

def compute_score(deck : Enumerable(Int32))
	deck.map_with_index do |card, index|
		factor = deck.size - index
		factor * card
	end
	.sum
end

winner = player_1_deck.size > 0 ? player_1_deck : player_2_deck

part1 = compute_score(winner)
puts "Winning player's score; Part1: #{part1}"
