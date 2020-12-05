// Compile:
//     g++ -std=c++17 -O3 -Wall -Wextra main.cpp
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

	auto max_seat_id = *max_element(seat_ids.begin(), seat_ids.end());
	cout << "Highest seat id; part 1: " << max_seat_id << endl;

	// Part 2, notes:
	// some of the seats at the very front and back of the plane don't exist on this aircraft, so they'll be missing from your list as well.
	// Your seat wasn't at the very front or back, though
	// -> the (binary) seats starting with 0b0000000 or 0b1111111 can be skipped

	return 0;
}
