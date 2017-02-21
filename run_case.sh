#! /bin/bash

test_case="$1"
echo "Running test case '$test_case'.."
echo "--------------------------------"
gen_input_files.pl --case="$test_case"
run_all.pl
