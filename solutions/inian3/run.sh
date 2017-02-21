#! /bin/bash

awk 'FNR==NR{hash[$1]; next}$2 in hash' ../../file1.txt FS='|' ../../file2.txt >out.txt
