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

    val solution1 = part1(ticketFields, nearbyTickets)
    println("Sum of error rates in nearby tickets; Part 1: $solution1")

    val solution2 = part2(ticketFields, nearbyTickets, myTicket)
    println("Multiplication of departure fields in my ticket; Part 2: $solution2")
}

fun part1(fields: List<TicketField>, nearbyTickets: List<List<Int>>): Int {
    return nearbyTickets.map { validateTicket(fields, it) }.map { it.second }.sum()
}

fun validateTicket(fields: List<TicketField>, ticket: List<Int>): Pair<Boolean, Int> {
    val errors = ticket.filter { !isValidNumber(fields, it) }.toList()
    assert(errors.size in 0..1)

    // There is a zero in the ticket data. It will not contribute to the sum, but should be counted as an error
    return Pair(errors.isEmpty(), errors.sum())
}

fun isValidNumber(fields: List<TicketField>, number: Int): Boolean {
    return fields.any { it.contains(number) }
}

fun part2(fields: List<TicketField>, nearbyTickets: List<List<Int>>, myTicket: List<Int>): Long {

    val validTickets = nearbyTickets
        .filter { validateTicket(fields, it).first }
        .toSet()

    val possibleFieldsForColumns = fields.indices.associateBy({ it }, { columnIndex ->
        val numbersOfColumn = validTickets.map { it[columnIndex] }.toSet()

        fields
            .filter { field -> numbersOfColumn.all { field.contains(it) } }
            .toSet()

    }).toMutableMap()

    while (possibleFieldsForColumns.any { it.value.size > 1 }) {
        val fieldsToRemove = possibleFieldsForColumns.values
            .filter { it.size == 1 }
            .reduce { a, b -> a union b }
            .toSet()

        val affectedKeys = possibleFieldsForColumns
            .filter { it.value.size > 1 }
            .map { it.key }
            .toSet()


        for (key in affectedKeys) {
            val column = possibleFieldsForColumns[key]
            assert(column != null);

            val newColumnData = column!!.toMutableSet()
            newColumnData.removeAll(fieldsToRemove)
            possibleFieldsForColumns[key] = newColumnData
        }
    }

    return possibleFieldsForColumns
        .mapValues { it.value.first() }
        .filter { it.value.name.startsWith("departure") }
        .map { myTicket[it.key].toLong() }
        .reduce { a, b -> a * b }
}
