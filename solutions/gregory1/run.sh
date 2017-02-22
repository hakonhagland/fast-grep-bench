#! /bin/bash

#parallel --pipepart --block 10M fgrep -F -f file1.txt < file2.txt
parallel -k --pipepart -a ../../file2.txt --block 1M fgrep -F -f ../../file1.txt > out.txt
