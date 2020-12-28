// Compile:
//     v main.v
// Use:
//     ./main < input.txt
// Compilier Version:
//     v version
//     V 0.2 e4f94b6


// The described protocol seems like it's a Diffie-Hellman key excnahge:
// https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange
// ...with:
// "loop size" being the private exponent (a/b); secret
// "20201227" being the modulus of the ring (p); public
// "subject number" (7) being shared g; public
// "subject_number_transform" being g^a mod p
// To solve part 1, we just brute-force the exponent (loop size) of one of the participants

import os

fn main() {
	input := os.get_lines()
	pub_key1 := input[0].u64()
	pub_key2 := input[1].u64()

	subject_number := u64(7)
	modulus := u64(20201227)

	loop_size_1 := compute_loop_size(pub_key1, subject_number, modulus)
	loop_size_2 := compute_loop_size(pub_key2, subject_number, modulus)

	println("loop size 1: $loop_size_1; loop size 2: $loop_size_2")

	encryption_key := transform_subject_number(pub_key1, loop_size_2, modulus)
	println("Recovered encryption key; Part 1: $encryption_key")
}

fn compute_loop_size(public_key u64, subject_number u64, modulus u64) u64 {

	mut loop_size_candidate := u64(1)
	mut current := u64(1)

	for {
		current = (current * subject_number) % modulus
		if current == public_key {
			return loop_size_candidate
		}
		loop_size_candidate++
	}
	return -1
}

fn transform_subject_number(subject_number u64, loop_size u64, modulus u64) u64 {
	mut current := u64(1)
	for _ in 0..loop_size {
		current = (current * subject_number) % modulus
	}
	return current
}
