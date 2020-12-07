#!/usr/bin/env python3

# Install dependencies:
#     pipenv install
# Use:
#     ./main.py < input.txt

import re
import sys
import numpy as np

# The problem seems to describe a problem in graph theory over a directed graph composed of relations.
# "bag A contains bag B" describes two nodes with an edge from B to A.
#
# Question: "How many bag colors can eventually contain at least one shiny gold bag?"
# This question asks for the total number of paths that end up (or begin with, depending on the implementation) in the shiny gold bag.
#
# Note:
# - We assume that that there are no cycles in the dependency graph. If there were cycles, we'd need infinite bags.
#     - -> There must be a state where we don't need any more bags
# - The number of bags of each color that a bag contains may be interpreted as the weights on the edges of the graph.
#
# Possible approaches:
# - Create a graph structure and perform backtracking on all possible paths
# - Create an adjacent matrix and iterate until we don't need any more bags (this is what we do here)
#
# We try to take the second approach:
# 1. We represent th edirected graph as an adjacent matrix.
# 2. Create a vector that contians an entry for every color (this is counting_vector)
# 3. We create an initial state (1xN vector that is 0 for all entries except the starting bag color)
# 4. Multiply the state with the adjacent matrix.
# 5. The result is an output configuration (state)
# 6. counting_vector += state
# 7. Repeat 2-6 until the state yields 0 for all bag colors
# 8. Count the non-zero entries in counting_vector


def read_input():
    # Grammar for every line:
    # <word> <word> bags contain <amount> <word> <word> bags?(, <amount> <word> <word>s?)
    # RULE_PATTERN = r'^(\w+ \w+) bags contain ((, )?(\d+) (\w+ \w+) bags?)+\.$'

    # We split parsing the rule in half to make our life easier
    SUPER_BAG_PATTERN = re.compile(r'^\w+ \w+')
    CONTENTS_PATTERN = re.compile(r'(\d+) (\w+ \w+)')

    rules = {}
    bag_indexes = {}
    next_bag_index = 0

    for line in sys.stdin:
        line = line.strip()
        if line == '':
            continue

        container = SUPER_BAG_PATTERN.findall(line)[0]
        contents = CONTENTS_PATTERN.findall(line)
        rules[container] = contents
        bag_indexes[container] = next_bag_index

        next_bag_index += 1

    return rules, bag_indexes


def create_adjacent_matrix(rules, bag_indexes) -> np.ndarray:

    matrix_dimension = len(rules)
    res = np.zeros((matrix_dimension, matrix_dimension), dtype=int)

    for container, contents in rules.items():
        container_index = bag_indexes[container]

        for amount, content in contents:
            content_index = bag_indexes[content]

            res[container_index, content_index] = amount

    return res


def create_input_state(starting_color, bag_indexes) -> np.ndarray:
    res = np.zeros(len(rules), dtype=int)
    start_index = bag_indexes[starting_color]
    res[start_index] = 1
    return res


rules, bag_indexes = read_input()
index_to_bag = dict(map(reversed, bag_indexes.items()))

starting_color = 'shiny gold'
adjacent_matrix = create_adjacent_matrix(rules, bag_indexes)
# print('Adjacent:')
# print(adjacent_matrix)


# Part 1
state = create_input_state(starting_color, bag_indexes)
counting_vector = np.zeros(len(bag_indexes), dtype=int)

while True:
    state = np.matmul(adjacent_matrix, state)

    counting_vector += state
    if np.count_nonzero(state) == 0:
        break

# print('Colored:')
# print(counting_vector)

part1 = np.count_nonzero(counting_vector)
print(f'Number of different colored bags that are possible in {starting_color}; Part 1: {part1}')

# Part 2
# It's basically the same, we just multiply the adjacent matrix from the other side (or the state, depending on your perspective).

state = create_input_state(starting_color, bag_indexes)
bags_needed = np.zeros(len(bag_indexes), dtype=int)

while True:
    state = np.matmul(state, adjacent_matrix)

    bags_needed += state
    if np.count_nonzero(state) == 0:
        break

part2 = sum(bags_needed)

print(f'Number of bags needed when starting with one {starting_color} bag; Part 2: {part2}')
