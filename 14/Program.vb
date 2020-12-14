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
    const ones = &HFFFFFFFFFUL

    sub Main(args As String())
        dim input = File.ReadAllLines(args(0))

        dim p1 = Part1(input)
        Console.WriteLine("Sum of all values after the program run (version 1); Part 1: " & p1)

        dim p2 = Part2(input)
        Console.WriteLine("Sum of all values after the program run (version 2); Part 2: " & p2)
    end sub

    function Part1(input as String()) as ULong
        dim memory = new Dictionary(of ULong, ULong)()

        dim current1Mask = 0UL
        dim current0Mask = ones

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

        return memory.Sum(function (e) e.Value)
    end function

    function Part2(input as String()) as ULong
        dim memory = new Dictionary(of ULong, ULong)()

        dim maskStr = ""
        dim current1Mask = 0UL
        dim floating = 0

        for each line in input
            if line.StartsWith("mask =") then
                maskStr = maskPattern.Match(line).Groups(1).Value
                current1Mask = 0UL
                floating = 0

                dim charIndex = 0
                for each c in maskStr
                    select c
                        case "1"
                            current1Mask = current1Mask or (1UL << (36 - 1 - charIndex))
                        case "X"
                            floating += 1
                    end select

                    charIndex += 1
                next
            else
                dim addess = ULong.Parse(addressPattern.Match(line).Groups(1).Value)
                dim value = ULong.Parse(valuePattern.Match(line).Groups(1).Value)

                dim decodedAddressInit = addess or current1Mask

                for f = 0 to Math.Pow(2, floating) - 1

                    dim decodedAddress = decodedAddressInit

                    dim bitIndex = 0
                    dim charIndex = -1
                    for each c in maskStr
                        charIndex += 1
                        if c <> "X" then continue for

                        dim v = f and (1UL << bitIndex)
                        dim bit = 1UL << (36 - charIndex - 1)
                        decodedAddress = if(
                            v <> 0,
                            decodedAddress or bit,
                            decodedAddress and not bit
                        )
                        bitIndex += 1
                    next

                    memory(decodedAddress) = value
                next
            end if
        next

        return memory.Sum(function (e) e.Value)
    end function

end module
