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

	executeProgram(instructions)
}

func executeProgram(instructions []Instruction) {
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
			fmt.Println("Value for accumulator before executing an instruction twice; Part 1:", globalAccumulator);
			break
		}

		if (nextIp >= len(instructions)) {
			fmt.Println("Program terminated")
			break
		}

		ip = nextIp
		visitedLocations[nextIp] = true
	}
}
