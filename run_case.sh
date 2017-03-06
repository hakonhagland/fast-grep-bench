#! /bin/bash

test_case="$1"
echo "Running test case '$test_case'.."
echo "--------------------------------"
gen_input_files.pl --case="$test_case"
echo "Preparing jjao case.."
prepare_jjoao.pl
echo "Running all cases.."
run_all.pl
