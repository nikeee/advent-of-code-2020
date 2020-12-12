-- Compile:
--     ghc -O3 main.hs
-- Use:
--     ./main < input.txt

data Part1State = Part1State {
    shipX :: Integer,
    shipY :: Integer,
    orientation :: Integer
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

main = do
    input <- getContents
    let instructions = map parseInstruction (lines input)

    let initialState = Part1State 0 0 0

    let part1 = foldl reducePart1 initialState instructions
    print ((abs (shipX part1)) + (abs (shipY part1)))

