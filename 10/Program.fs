open System
open System.Collections.Generic

let rec readlines () = seq {
    let line = Console.ReadLine()
    if line <> null then
        yield line
        yield! readlines ()
}

let adapterFits source target =
    source < target && source >= target - 3

let fittingAdapters allAdapters source =
    allAdapters
        |> Set.filter (adapterFits source)

type DeltaStats = {
    OneDeltas: int
    ThreeDeltas: int
}

type Path = int list

[<EntryPoint>]
let main argv =
    let lines = readlines()

    let input =
        lines
        |> Seq.map Int32.Parse
        |> Set.ofSeq

    let lastAdapter = input.MaximumElement + 3
    printfn "Laster Adapter: %d" lastAdapter

    let allAdapters = Set.add 0 (Set.add lastAdapter input)
    let getFittingAdapters = fittingAdapters allAdapters

    let rec traverseAdapters current currentDeltas =
        if current = lastAdapter
        then currentDeltas
        else (
                let fittingAdapters = getFittingAdapters current
                if fittingAdapters.IsEmpty then currentDeltas
                else (
                        let minAdapter = fittingAdapters.MinimumElement
                        let nextDeltas = traverseAdapters minAdapter currentDeltas

                        let delta = minAdapter - current
                        match delta with
                        | 1 -> {nextDeltas with OneDeltas = nextDeltas.OneDeltas + 1}
                        | 3 -> {nextDeltas with ThreeDeltas = nextDeltas.ThreeDeltas + 1}
                        | _ -> nextDeltas
                )
        )

    let part1 = traverseAdapters 0 {OneDeltas=0; ThreeDeltas=0}
    printfn "Always combining the lowest adapter; Part 1: %d (1-joints: %d, 3-joints: %d)" (part1.OneDeltas * part1.ThreeDeltas) part1.OneDeltas part1.ThreeDeltas

    // Part 2

    (*
    The Problem can be interpreted in a directed graph.
    An adapter is a node. It has an outgoing connection to another adapter iff it outputs a joltage that the other adapter can receive.
    We add two artificial nodes: 0 (for the start) and max(joltage) + 3 as end.
    The task is to find the number ofhamiltonian paths that starts at node 0 and ends at node max(joltage) + 3.

    Notes:
    - Every path constructed is unique
    - The graph is acyclic
    - We have a defined start and end
    - We only care about the number of paths, not the paths itself
    *)

    let getPrevNodes target =
        allAdapters |> Seq.filter (fun c -> adapterFits c target)

    let rec countHamiltonPaths (currentNode: int, paths: Dictionary<int, int64>): int64 =
        match currentNode with
        | 0 -> 1L
        | _ -> getPrevNodes currentNode |> Seq.sumBy (fun n -> paths.[n])

    let visitedNodes = new Dictionary<int, int64>()
    for node in (allAdapters |> Seq.sort) do
        let nodeValue = countHamiltonPaths (node, visitedNodes)
        visitedNodes.[node] <- nodeValue

    let part2 = countHamiltonPaths (allAdapters.MaximumElement, visitedNodes)
    printfn "Possible number of was combining the input; Part 2: %d" part2

    0
