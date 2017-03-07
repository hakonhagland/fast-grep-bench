#! /bin/bash

LC_ALL=C join --nocheck-order -11 -22 -t'|' -o 2.1 2.2 2.3 ../../file1_collate_c.txt ../../file2_collate_c.txt >out.txt
