// Compile:
//     swiftc main.swift
// Run:
//     ./main < input.txt
// Compiler version:
//     swiftc --version
//     Swift version 5.3.1 (swift-5.3.1-RELEASE)

import Foundation

let earliestTimestamp: Int64 = Int64(readLine(strippingNewline: true)!)!
let departuresStr = readLine(strippingNewline: true)

let departuresArray = departuresStr!.components(separatedBy: ",");
let departures: [Int64] = departuresArray.filter{ $0 != "x" }.map{Int64($0)!}

// Part 1

let upperBound = earliestTimestamp + departures.min()! + 1

for tCandidate in earliestTimestamp..<upperBound {

	let possibleDepartures = departures.filter{tCandidate % $0 == 0}
	if possibleDepartures.count > 0 {

		let busId = possibleDepartures.min()!
		let timeToWait = tCandidate - earliestTimestamp
		print ("Part 1: \(busId * timeToWait)")
		break
	}
}

// Part 2
/*
Consider this input:
17, x, 13, 19

A solution this input would have to fulfil this set of equations:
(t + 0) % 17 == 0
(t + 2) % 13 == 0
(t + 3) % 19 == 0

They are a ring of integers mod some n, so we can rewrite it like this:
t % 17 == 0
t % 13 == 13 - 2 == 11
t % 19 == 19 - 3 == 16

Observation: All departure times are prime numbers.
This means, that every departure time forms a finite field Fp.

Also, this looks like it has to do with the chinese remainder theorem:
https://en.wikipedia.org/wiki/Chinese_remainder_theorem#General_case
n_i are pairwise coprime (they are all prime, actually).
It looks like x is what we are looking for!

*/

// Compute the vector of remainders that correspond to the rewriting above
let remainders = departuresArray.enumerated()
    .filter{(index, busId) in busId != "x"}
    .map {(index, busId) in Int64(Int(busId)! - index)}

// print ("\(departures)")
// print ("\(remainders)")
let part2 = chineseRemainder(departures, remainders)
print("Part 2: \(part2)")

// We assume that all numbers are coprime (since they are prime, so no need to check that).
// This code is ported from: https://fangya.medium.com/chinese-remainder-theorem-with-python-a483de81fbb8
func chineseRemainder(_ ns: [Int64], _ remainders: [Int64]) -> Int64 {
	var sum: Int64 = 0
	let prod = ns.reduce(1, {x, y in x * y})

	for (ni, ri) in zip(ns, remainders) {
		let p = prod / ni
		sum += ri * multiplicativeInv(p, ni) * p
	}

	return sum % prod
}

func multiplicativeInv(_ a: Int64, _ b: Int64) -> Int64 {
	if b == 1 {
		return 1
	}

	var a = a
	var b = b

	let b0 = b
	var x0: Int64 = 0
	var x1: Int64 = 1

	while a > 1 {
		let q = a / b
		(a, b) = (b, a % b)
		(x0, x1) = (x1 - q * x0, x0)
	}
	if x1 < 0 {
		x1 += b0
	}
	return x1
}
