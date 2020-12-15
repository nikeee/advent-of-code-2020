#!/usr/bin/env php
<?php

// Use:
//     ./main.php < input.txt
// Runtime version:
//     php --version
//     PHP 8.0.0 (cli) (built: Dec 11 2020 08:00:05) ( NTS )

ini_set('memory_limit', '2G');

$input = @trim(fgets(STDIN));

$lines = explode(',', $input);
$init = array_map('intval', $lines);

function memory_sequence($init_sequence) {

    $sequence_data = [];
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

        yield [$index + 1, $number_spoken];

        $current_value = $number_spoken;
        ++$index;
    }
}

foreach (memory_sequence($init) as [$index, $number_spoken]) {
    switch ($index) {
        case 2020:
            echo "${index}th number spoken; Part 1: $number_spoken\n";
            break;
        case 30000000:
            echo "${index}th number spoken; Part 2: $number_spoken\n";
            die(0);
            break;
    }
}
