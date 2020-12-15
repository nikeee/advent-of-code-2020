#!/usr/bin/env php
<?php

// Use:
//     ./main.php < input.txt
// Runtime version:
//     php --version
//     PHP 8.0.0 (cli) (built: Dec 11 2020 08:00:05) ( NTS )

ini_set('memory_limit', '300M');

$input = @trim(fgets(STDIN));

$lines = explode(',', $input);
$init = array_map('intval', $lines);

function memory_sequence($init_sequence) {

    $sequence_data = [];
    foreach ($init_sequence as $index => $value) {
        $sequence_data[$value] = $index + 1;
    }

    $last_spoken = end($init_sequence);

    for($index = count($sequence_data); true; ++$index) {

        $number_spoken = $index - ($sequence_data[$last_spoken] ?? $index);
        $sequence_data[$last_spoken] = $index;

        yield [$index + 1, $number_spoken];

        $last_spoken = $number_spoken;
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
