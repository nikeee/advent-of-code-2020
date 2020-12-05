// Compile:
//     g++ -std=c++20 -O3 -Wall -Wextra -Wpedantic -Werror main.cpp
// Run:
//     ./a.out < input.txt
// Compiler version:
//     g++ --version
//     g++ (Ubuntu 10.2.0-13ubuntu1) 10.2.0

#include <iostream>
#include <vector>
#include <set>
#include <algorithm>

using namespace std;

typedef unsigned int uint;

constexpr size_t seat_length = 7 + 3; // BFFFBBF + RRR

vector<string> read_input()
{
	vector<string> res;
	string token;
	while (getline(cin, token, '\n'))
		res.push_back(token);
	return res;
}

uint parse_seat_id(const string &value)
{
	uint set_id = 0;
	for (size_t i = 0; i < seat_length; ++i)
	{
		auto c = value.at(i);
		int bit = c == 'F' || c == 'L' ? 0 : 1;

		set_id |= bit << (seat_length - i - 1);
	}
	return set_id;
}

/**
 * The binary space partition actually is pretty straigt-forward if we interpret F/B as 0/1 and L/R as 0/1.
 * This means BFFFBBFRRR becomes 1000110111, with 0b1000110 being the row and 0b111 being the column
 * So the seat ID is just 0b1000110 * 8 + 0b111 = 567
 * This can be simplified more:
 * Multiplying by 8 is the same as "<< 3". This means that we can just parse the 10 bit and leave it as is.
 * BFFFBBFRRR becomes 0b1000110111, which is 567.
 */
set<uint> get_seat_ids(const vector<string> seat_names)
{
	set<uint> seat_ids;

	for (auto &seat : seat_names)
	{
		if (seat.length() != seat_length)
		{
			cout << "Skipping seat " << seat << endl;
			continue;
		}
		seat_ids.insert(parse_seat_id(seat));
	}

	return seat_ids;
}

int main()
{
	auto input = read_input();

	auto seat_ids = get_seat_ids(input);

	// Part 1
	auto max_seat_id = *max_element(seat_ids.begin(), seat_ids.end());
	cout << "Highest seat id; part 1: " << max_seat_id << endl;

	// Part 2

	// Notes:
	// some of the seats at the very front and back of the plane don't exist on this aircraft, so they'll be missing from your list as well.
	// Your seat wasn't at the very front or back, though
	// -> the (binary) seats starting with 0b0000000 or 0b1111111 can be skipped

	for (auto &seat_id : seat_ids)
	{
		// seat_ids doesn't contain my_seat, but it contains my_seat - 1 and my_seat + 1
		// -> We can check for each seat_id in seat_ids if seat_ids doesn't contain seat_id + 1 but contains seat_id + 2
		// -> If this happens, then my_seat is seat_id + 1

		auto my_seat_candidate = seat_id + 1;

		auto row_id = my_seat_candidate >> 3;
		// This doesn't actually happen in the input, but we check it anyways, since it's mentioned in the text
		if (row_id == 0b0000000 || row_id == 0b1111111)
			continue;

		// set.contains needs C++20
		if (!seat_ids.contains(my_seat_candidate) && seat_ids.contains(my_seat_candidate + 1))
		{
			cout << "My seat id; part 2: " << my_seat_candidate << endl;
			break;
		}
	}

	return 0;
}
