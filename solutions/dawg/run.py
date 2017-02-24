#! /usr/bin/env python2

import sys 

with open("../../file1.txt") as f:
    tgt = {e.rstrip() for e in f}

with open("../../file2.txt") as f:
    for line in f:
        cells = line.split("|")
        if cells[1] in tgt:
            print line.rstrip()

