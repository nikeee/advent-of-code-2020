import Foundation

let earliestTimestamp: Int64 = Int64(readLine(strippingNewline: true)!)!
let departuresStr = readLine(strippingNewline: true)

let departuresArray = departuresStr!.components(separatedBy: ",");
let departures: [Int64] = departuresArray.filter{ $0 != "x" }.map{Int64($0)!}

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
