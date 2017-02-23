#! /bin/bash

block_size="$1"
#parallel -k --pipepart -a ../../file2.txt -j"$num_cores" --round-robin fgrep -F -f ../../file1.txt > out.txt
parallel -k --pipepart -a ../../file2.txt --block "$block_size" fgrep -F -f ../../file1.txt > out.txt
