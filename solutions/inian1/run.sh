#! /bin/bash

awk 'FNR==NR{hash[$1]; next}{for (i in hash) if (match($0, i)) {print; break}}' ../../file1.txt FS='|' ../../file2.txt > out.txt
