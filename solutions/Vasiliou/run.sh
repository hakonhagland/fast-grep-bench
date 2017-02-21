#! /bin/bash

join --nocheck-order -11 -22 -t'|' -o 2.1 2.2 2.3 ../../file1.txt ../../file2.txt >out.txt
