' Use
'     dotnet run -c Release -- input.txt

imports System
imports System.IO
imports System.Linq
imports System.Collections.Generic
imports System.Text.RegularExpressions

module Program

    dim maskPattern = new RegEx("^mask = ([10X]{36})")
    dim addressPattern = new RegEx("^mem\[(\d+)]")
    dim valuePattern = new RegEx("= (\d+)$")

    sub Main(args As String())
        dim input = File.ReadAllLines(args(0))
        Part1(input)
    end sub

    sub Part1(input as String())

        const ones = &HFFFFFFFFFUL
        dim current1Mask = 0UL
        dim current0Mask = ones

        dim memory = new Dictionary(of ULong, ULong)()

        for each line in input
            if line.StartsWith("mask =") then
                dim maskStr = maskPattern.Match(line).Groups(1).Value

                current1Mask = 0UL
                current0Mask = ones

                dim charIndex = 0
                for each c in maskStr
                    select c
                        case "1"
                            current1Mask = current1Mask or (1UL << (36 - 1 - charIndex))
                        case "0"
                            current0Mask = current0Mask and not (1UL << (36 - 1 - charIndex))
                    end select

                    charIndex += 1
                next
            else
                dim addess = ULong.Parse(addressPattern.Match(line).Groups(1).Value)
                dim value = ULong.Parse(valuePattern.Match(line).Groups(1).Value)

                dim writtenValue = (value and current0Mask) or current1Mask
                memory(addess) = writtenValue
            end if
        next

        dim result = memory.Sum(function (e) e.Value)
        Console.WriteLine("Sum of all values after the program run; Part 1: " & result)
    end sub

end module
