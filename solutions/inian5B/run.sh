#! /bin/bash

LC_ALL=C awk 'FNR==NR{hash[$1]; next}{for (i in hash) if (match($0, i)) {print; break}}' ../../file1b.txt FS='|' ../../file2.txt > out.txt
