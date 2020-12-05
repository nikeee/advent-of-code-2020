// Compile:
//     g++ -std=c++17 -O3 -Wall -Wextra main.cpp
// Run:
//     ./a.out < input.txt
// Compiler version:
//     g++ --version
//     g++ (Ubuntu 10.2.0-13ubuntu1) 10.2.0

#include <iostream>
#include <vector>
#include <bitset>

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

uint parse_seat_string(const string &value)
{
	uint binary_seat = 0;
	for (size_t i = 0; i < seat_length; ++i)
	{
		auto c = value.at(i);
		int bit = c == 'F' || c == 'L' ? 0 : 1;

		binary_seat |= bit << (seat_length - i - 1);
	}
	return binary_seat;
}

int main()
{
	auto input = read_input();

	// The binary space partition actually is pretty straigt-forward if we interpret F/B as 0/1 and L/R as 0/1.
	// This means BFFFBBFRRR becomes 1000110111, with 0b1000110 being the row and 0b111 being the column
	// So the seat ID is just 0b1000110 * 8 + 0b111 = 567

	uint max_seat_id = 0;
	for (auto &seat : input)
	{
		if (seat.length() != seat_length)
		{
			cout << "Skipping seat " << seat << endl;
			continue;
		}

		auto binary_seat = parse_seat_string(seat);

		uint row_id = binary_seat >> 3;
		uint column_id = binary_seat & 0b111;

		auto seat_id = row_id * 8 + column_id;

		if (seat_id > max_seat_id)
			max_seat_id = seat_id;

		cout << seat << ": " << seat_id << endl;
	}

	cout << "Highest seat id; part 1: " << max_seat_id << endl;

	return 0;
}
