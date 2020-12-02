#!/usr/bin/env node

// Use:
//     ./main.js

const input = require("fs").readFileSync("input.txt", { encoding: "utf-8" });

function parseLine(line) {
	const [policy, candidate] = line.split(":").map(s => s.trim());
	const [occurences, char] = policy.split(" ");
	const [minOccurences, maxOccurences] = occurences.split("-").map(s => parseInt(s));
	return {
		policy: {
			minOccurences,
			maxOccurences,
			char,
		},
		candidate,
	};
}

function validatePasswordPart1({ policy, candidate }) {
	let occurences = [...candidate].filter(c => c === policy.char).length;

	return policy.minOccurences <= occurences && occurences <= policy.maxOccurences;
}

const part1 = input.trim()
	.split("\n")
	.map(parseLine)
	.filter(validatePasswordPart1)
	.length;

console.log(`Number of valid passwords; Part 1: ${part1}`);

function validatePasswordPart2({ policy, candidate }) {
	const { minOccurences: firstIndex, maxOccurences: secondIndex } = policy;

	return (candidate[firstIndex - 1] === policy.char) ^ (candidate[secondIndex - 1] === policy.char);
}

const part2 = input.trim()
	.split("\n")
	.map(parseLine)
	.filter(validatePasswordPart2)
	.length;

console.log(`Number of valid passwords; Part 2: ${part2}`);
