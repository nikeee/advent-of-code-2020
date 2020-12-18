// Compile:
//     gcc main.c -O3
// Use:
//     ./a.out < input.txt

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>

int *read_input(const size_t input_size)
{
	unsigned int *numbers = calloc(sizeof(unsigned int), input_size);

	int res = EOF;
	size_t index = 0;

	do
	{
		int current_number = 0;
		res = scanf("%d", &current_number);

		if (res == 1)
			numbers[index] = current_number;

		++index;
	} while (res != EOF && index < 200);

	return numbers;
}

void part_1(const unsigned int *input, const size_t input_size)
{
	unsigned int max_value = 0;
	for (size_t a = 0; a < input_size; ++a)
		if (input[a] > max_value)
			max_value = input[a];

	bool *lookup_table = calloc(max_value + 1, sizeof(bool));

	for (size_t a = 0; a < input_size; ++a)
	{
		const int candidate_a = input[a];
		const int candidate_b = 2020 - candidate_a;
		if (lookup_table[candidate_b])
		{
			int solution = candidate_b * candidate_a;
			printf("Part 1: %d * %d = %d\n", candidate_a, candidate_b, solution);
			break;
		}
		else
		{
			lookup_table[candidate_a] = true;
		}
	}

	free(lookup_table);
}

void part_2(const unsigned int *input, const size_t input_size)
{
	for (size_t a = 0; a < input_size; ++a)
	{
		const int candidate_a = input[a];
		for (size_t b = 0; b < input_size; ++b)
		{
			const int candidate_b = input[b];
			for (size_t c = 0; c < input_size; ++c)
			{
				const int candidate_c = input[c];

				if (candidate_a + candidate_b + candidate_c == 2020)
				{
					int solution = candidate_a * candidate_b * candidate_c;
					printf("Part 2: %d * %d * %d = %d\n", candidate_a, candidate_b, candidate_c, solution);
					return;
				}
			}
		}
	}
}

int main(int argc, char *argv[])
{
	const size_t input_size = 200;
	unsigned int *input = read_input(input_size);

	part_1(input, input_size);
	part_2(input, input_size);

	free(input);
	return 0;
}
