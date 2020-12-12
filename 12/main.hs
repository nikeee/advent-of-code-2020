-- Compile:
--     ghc -O3 main.hs
-- Use:
--     ./main < input.txt

data Part1State = Part1State {
    shipX :: Integer,
    shipY :: Integer,
    orientation :: Integer
}

data Part2State = Part2State {
    x :: Integer,
    y :: Integer,
    waypointX :: Integer,
    waypointY :: Integer
}

data Instruction = Char Integer

parseInstruction instruction = do
    let operation = head instruction
    let intStr = drop 1 instruction
    let parameter = read intStr :: Integer
    (operation, parameter)

reducePart1 :: Part1State -> (Char, Integer) -> Part1State
reducePart1 state (operation, offset) = do
    let x = shipX state
    let y = shipY state
    let dir = orientation state

    case operation of
        'N' -> state { shipY = y - offset }
        'S' -> state { shipY = y + offset }
        'E' -> state { shipX = x + offset }
        'W' -> state { shipX = x - offset }
        'L' -> state { orientation = (dir + offset) `mod` 360 }
        'R' -> state { orientation = (dir - offset) `mod` 360 }
        'F' -> case dir of
            0 -> state { shipX = x + offset }
            90 -> state { shipY = y - offset }
            180 -> state { shipX = x - offset }
            270 -> state { shipY = y + offset }

reducePart2 :: Part2State -> (Char, Integer) -> Part2State
reducePart2 state (operation, offset) = do
    let wX = waypointX state
    let wY = waypointY state

    case operation of
        'N' -> state { waypointY = wY - offset }
        'S' -> state { waypointY = wY + offset }
        'E' -> state { waypointX = wX + offset }
        'W' -> state { waypointX = wX - offset }
        'L' -> rotate state (360 - (offset `mod` 360))
        'R' -> rotate state (offset `mod` 360)
        'F' -> state {
            x = (x state) + wX * offset,
            y = (y state) + wY * offset
        }

rotate state degree = do
    let wX = waypointX state
    let wY = waypointY state

    case degree of
        0 -> state
        90 -> state { waypointX = -wY, waypointY = wX }
        180 -> state { waypointX = -wX, waypointY = -wY }
        270 -> state { waypointX = wY, waypointY = -wX }

manhattanDistance x y = (abs x) + (abs y)

main = do
    input <- getContents
    let instructions = map parseInstruction (lines input)

    let initialState1 = Part1State 0 0 0
    let part1State = foldl reducePart1 initialState1 instructions
    let part1 = manhattanDistance (shipX part1State) (shipY part1State)
    print part1

    let initialState2 = Part2State 0 0 10 (-1)
    let part2State = foldl reducePart2 initialState2 instructions
    let part2 = manhattanDistance (x part2State) (y part2State)
    print part2

