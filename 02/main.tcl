set input [open "input.txt" r]
set lines [split [read $input] "\n"]
close $input;

set valid_passwords 0

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

		set occurrences 0
		foreach current_char [split $password ""] {
			puts "LOL $current_char"
			if {$current_char == $required_char} {
				incr occurrences
			}
		}

		if {$first_number <= $occurrences && $occurrences <= $second_number} {
			puts "OK $occurrences"
			incr valid_passwords
		}
	}
}

puts "Number of valid passwords; Part 1: $valid_passwords"
