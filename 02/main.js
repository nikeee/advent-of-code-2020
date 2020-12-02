#!/usr/bin/env node

// Use:
//     ./main.js

const input = require("fs").readFileSync("input.txt", { encoding: "utf-8" });

function parseLine(line) {
	const [policy, candidate] = line.split(":").map(s => s.trim());
	const [occurrences, char] = policy.split(" ");
	const [minOccurrences, maxOccurrences] = occurrences.split("-").map(s => parseInt(s));
	return {
		policy: {
			minOccurrences,
			maxOccurrences,
			char,
		},
		candidate,
	};
}

function validatePasswordPart1({ policy, candidate }) {
	let occurrences = [...candidate].filter(c => c === policy.char).length;

	return policy.minOccurrences <= occurrences && occurrences <= policy.maxOccurrences;
}

const part1 = input.trim()
	.split("\n")
	.map(parseLine)
	.filter(validatePasswordPart1)
	.length;

console.log(`Number of valid passwords; Part 1: ${part1}`);

function validatePasswordPart2({ policy, candidate }) {
	const { minOccurrences: firstIndex, maxOccurrences: secondIndex } = policy;

	return (candidate[firstIndex - 1] === policy.char) ^ (candidate[secondIndex - 1] === policy.char);
}

const part2 = input.trim()
	.split("\n")
	.map(parseLine)
	.filter(validatePasswordPart2)
	.length;

console.log(`Number of valid passwords; Part 2: ${part2}`);
