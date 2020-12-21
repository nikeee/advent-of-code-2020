# Run:
#     tclsh main.tcl

set input [open "input.txt" r]
set lines [split [read $input] "\n"]
close $input;

proc validate_password_part1 {min_occurrences max_occurrences required_char password} {

	set occurrences 0

	foreach current_char [split $password ""] {
		if {$current_char == $required_char} {
			incr occurrences
		}
	}

	return [expr $min_occurrences <= $occurrences && $occurrences <= $max_occurrences]
}

proc validate_password_part2 {first_number second_number required_char password} {

	set password_chars [split $password ""]

	set first_char [lindex $password_chars [expr $first_number - 1]]
	set second_char [lindex $password_chars [expr $second_number - 1]]

	set has_first_char [expr {"$first_char" == "$required_char"}]
	set has_second_char [expr {"$second_char" == "$required_char"}]

	return [expr $has_first_char ^ $has_second_char]
}

set valid_passwords_part1 0
set valid_passwords_part2 0

foreach line $lines {
	if {[string length $line] > 0} {
		set line_parts [split $line :]
		set policy [string trim [lindex $line_parts 0]]
		set password [string trim [lindex $line_parts 1]]

		set policy_data [split $policy " "]
		set rule_data [string trim [lindex $policy_data 0]]
		set required_char [string trim [lindex $policy_data 1]]

		set rule_data [split $rule_data -]
		set first_number [lindex $rule_data 0]
		set second_number [lindex $rule_data 1]

		set is_valid [validate_password_part1 $first_number $second_number $required_char $password]
		incr valid_passwords_part1 $is_valid

		set is_valid [validate_password_part2 $first_number $second_number $required_char $password]
		incr valid_passwords_part2 $is_valid
	}
}

puts "Number of valid passwords; Part 1: $valid_passwords_part1"
puts "Number of valid passwords; Part 2: $valid_passwords_part2"
