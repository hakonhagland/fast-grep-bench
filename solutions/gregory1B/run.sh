#! /bin/bash

block_size="$1"
parallel -k --pipepart -a ../../file2.txt --block "$block_size" grep -E -f ../../file1b.txt > out.txt
