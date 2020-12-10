// Learn more about F# at http://docs.microsoft.com/dotnet/fsharp

open System

// Define a function to construct a message to print
let from whom =
    sprintf "from %s" whom

type Adapter = {
    joltage: int
    next: Adapter list
}

let rec readlines () = seq {
    let line = Console.ReadLine()
    if line <> null then
        yield line
        yield! readlines ()
}

let adapterFits source target =
    source < target && source >= target - 3

let fittingAdapters unlinkedAdapters source =
    unlinkedAdapters
        |> List.filter (adapterFits source)

type DeltaCount = {
    oneDeltas: int
    threeDeltas: int
}


[<EntryPoint>]
let main argv =
    let lines = readlines()

    let unlinkedAdapters =
        lines
        |> Seq.map Int32.Parse
        |> Seq.toList

    // unlinkedAdapters |> List.iter (printfn "%d")


    let lastAdapter = (List.reduce max unlinkedAdapters) + 3
    printfn "Laster Adapter: %d" lastAdapter

    let allAdapters = unlinkedAdapters @ [lastAdapter]
    let getFittingAdapters = fittingAdapters allAdapters

    let rec traverseAdapters current currentDeltas =
        if current = lastAdapter
        then currentDeltas
        else (
                let fittingAdapters = getFittingAdapters current
                match fittingAdapters with
                | [] -> currentDeltas
                | _ -> (
                        let minAdapter = List.reduce min fittingAdapters
                        let nextDeltas = traverseAdapters minAdapter currentDeltas

                        let delta = minAdapter - current
                        match delta with
                        | 1 -> {nextDeltas with oneDeltas = nextDeltas.oneDeltas + 1}
                        | 3 -> {nextDeltas with threeDeltas = nextDeltas.threeDeltas + 1}
                        | _ -> nextDeltas
                )
        )

    let a = traverseAdapters 0 {oneDeltas=0; threeDeltas=0}
    printfn "Part 1: %d (1-joints: %d, 3-joints: %d)" (a.oneDeltas * a.threeDeltas) a.oneDeltas a.threeDeltas

    0
