#! /bin/bash

LC_ALL=C awk 'FNR==NR{hash[$1]; next}{for (i in hash) if (match(i,$0)) {print; break}}' ../../file1.txt FS='|' ../../file2.txt > out.txt
