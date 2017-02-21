#! /usr/bin/env python2

import sys,re

file1_fn = '../../file1.txt'
file2_fn = '../../file2.txt'
with open(file1_fn, "r") as f1:
    # read pattern from file1 without the trailing newline
    patterns = f1.read().splitlines()

m = re.compile("|".join(patterns))    # create the regex

with open(file2_fn, "r") as f2:
    for line in f2: 
        if m.search(line) : 
            # print line from file2 if this one matches the regex
            print line, 
