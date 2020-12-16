// Compile:
//     kotlinc main.kt -include-runtime -d main.jar
// Run:
//     java -jar main.jar < input.txt

data class Range(val min: Int, val max: Int) {
    fun contains(n: Int): Boolean {
        return n in min..max
    }
}

data class TicketField(val name: String, val firstRange: Range, val secondRange: Range) {
    fun contains(n: Int): Boolean {
        return firstRange.contains(n) || secondRange.contains(n)
    }
}

fun main(args: Array<String>) {

    val ticketFields = mutableListOf<TicketField>()
    var line = readLine()!!
    while (line != "") {
        val (fieldName, fieldRange) = line.split(":").map { it.trim() }
        val (firstRange, secondRange) = fieldRange.split("or").map { it.trim() }
        val (firstMin, firstMax) = firstRange.split("-").map(Integer::parseInt)
        val (secondMin, secondMax) = secondRange.split("-").map(Integer::parseInt)

        ticketFields.add(TicketField(fieldName, Range(firstMin, firstMax), Range(secondMin, secondMax)))

        line = readLine()!!
    }

    line = readLine()!!
    assert(line.startsWith("your ticket"))

    line = readLine()!!
    val myTicket = line.trim().split(",").map(Integer::parseInt)

    line = readLine()!!
    assert(line == "")

    line = readLine()!!
    assert(line.startsWith("nearby tickets"))

    val nearbyTickets = mutableListOf<List<Int>>()
    line = readLine()!!
    while (line != "") {
        val ticket = line.trim().split(",").map(Integer::parseInt)
        nearbyTickets.add(ticket)
        line = readLine()!!
    }

    println(ticketFields)
    println(myTicket)
    println(nearbyTickets)

    val solution1 = part1(ticketFields, nearbyTickets)
    println("Sum of error rates in nearby tickets; Part 1: $solution1")
}

fun part1(fields: List<TicketField>, nearbyTickets: List<List<Int>>): Int {
    return nearbyTickets.map{getErrorRate(fields, it)}.sum()
}

fun getErrorRate(fields: List<TicketField>, ticket: List<Int>): Int {
    val errors = ticket.filter { !isValidNumber(fields, it) }.toList()
    assert(errors.size in 0..1)
    return errors.sum()
}

fun isValidNumber(fields: List<TicketField>, number: Int): Boolean {
    return fields.any {it.contains(number)}
}
