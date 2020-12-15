#!/usr/bin/env php
<?php

// Use:
//     ./main.php < input.txt
// Runtime version:
//     php --version
//     PHP 8.0.0 (cli) (built: Dec 11 2020 08:00:05) ( NTS )

$input = @trim(fgets(STDIN));

$lines = explode(',', $input);
$init_sequence = array_map('intval', $lines);

foreach ($init_sequence as $index => $value) {
    $sequence_data[$value] = [$index, $index];
}

$current_value = end($init_sequence);
$index = count($sequence_data);

while (true) {
    $last_spoken_data = $sequence_data[$current_value];

    $number_spoken = $last_spoken_data[0] - $last_spoken_data[1];

    $last_time_number_was_spoken = $sequence_data[$number_spoken] ?? [$index, $index];

    $sequence_data[$number_spoken] = [$index, $last_time_number_was_spoken[0]];

    if ($index + 1 === 2020) {
        echo "2020th number spoken; Part 1: $number_spoken\n";
        break;
    }

    $current_value = $number_spoken;
    ++$index;
}
