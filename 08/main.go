// Compile:
//     go build main.go
// Run:
//     ./main < input.txt
// Compiler version:
//     go version
//     go version go1.14.7 linux/amd64

package main

import (
	"fmt"
	"strings"
	"strconv"
	"os"
	"bufio"
)

type OpCode string
const (
	nop = "nop"
	jmp = "jmp"
	acc = "acc"
)

type Instruction struct {
	Operation OpCode
	Parameter int
}

func readInput() []Instruction {
	var instructions []Instruction

	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		line := scanner.Text()
		lineSplit := strings.Split(line, " ")

		op := OpCode(lineSplit[0])

		parameter, _ := strconv.Atoi(lineSplit[1])
		instructions = append(instructions, Instruction{ Operation: op, Parameter: parameter })
	}

	return instructions
}

func main() {
	instructions := readInput()

	// Part 1
	terminated, accumulator := executeProgram(instructions)
	if (!terminated) {
		fmt.Println("Value of accumulator before executing an instruction twice; Part 1:", accumulator);
	}

	// Part 2
	var lastModification int = -1
	for {
		instructionsCandidate, modifiedAt := modifyProgram(instructions, lastModification)
		if (modifiedAt == len(instructionsCandidate)) {
			fmt.Println("Search space exhausted, no more modifications possible.")
			break
		}

		lastModification = modifiedAt

		terminated, accumulator := executeProgram(instructionsCandidate)
		if (terminated) {
			fmt.Println("Value of accumulator after pro program temrinates; Part 2:", accumulator);
			break
		}
	}
}

func modifyProgram(instructions []Instruction, lastChangedInstruction int) ([]Instruction, int) {
	modifiedInstructions := make([]Instruction, len(instructions))
	copy(modifiedInstructions, instructions)

	for i := lastChangedInstruction + 1; i < len(modifiedInstructions); i++ {
		ins := modifiedInstructions[i]

		switch ins.Operation {
		case jmp:
			modifiedInstructions[i].Operation = nop
			return modifiedInstructions, i
		case nop:
			// If the parameter is 0, chainging it to a jump would cause an infinite loop
			if (ins.Parameter != 0) {
				modifiedInstructions[i].Operation = jmp
				return modifiedInstructions, i
			}
		case acc: // Don't do anything to acc instructions
		}
	}

	return modifiedInstructions, len(modifiedInstructions)
}

func executeProgram(instructions []Instruction) (bool, int) {
	var ip int = 0
	var globalAccumulator int = 0

	visitedLocations := map[int]bool{} // golang doesnt have any sets

	for {
		instruction := instructions[ip]

		var nextIp int = 0
		switch instruction.Operation {
		case nop:
			nextIp = ip + 1
		case acc:
			globalAccumulator += instruction.Parameter
			nextIp = ip + 1
		case jmp:
			nextIp = ip + instruction.Parameter
		}

		_, exists := visitedLocations[nextIp];
		if (exists) {
			return false, globalAccumulator
		}

		if (nextIp >= len(instructions)) {
			return true, globalAccumulator
		}

		ip = nextIp
		visitedLocations[nextIp] = true
	}

	return true, globalAccumulator
}
