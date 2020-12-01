// Compile:
//     gcc main.c -O3
// Use:
//     ./a.out < input.txt

#include <stdio.h>
#include <stdlib.h>

int *read_input(const size_t input_size)
{
	int *numbers = calloc(sizeof(int), input_size);

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

void part_1(const int *input, const size_t input_size)
{
	for (size_t a = 0; a < input_size; ++a)
	{
		const int candidate_a = input[a];
		for (size_t b = 0; b < input_size; ++b)
		{
			const int candidate_b = input[b];

			if (candidate_a + candidate_b == 2020)
			{
				int solution = candidate_a * candidate_b;
				printf("Part 1: %d * %d = %d\n", candidate_a, candidate_b, solution);
				return;
			}
		}
	}
}

void part_2(const int *input, const size_t input_size)
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
	int *input = read_input(input_size);

	part_1(input, input_size);
	part_2(input, input_size);

	free(input);
	return 0;
}
