#! /bin/bash

regexp=$(< "../../regexp_ikegami.txt")
grep -P "$regexp" ../../file2.txt >out.txt
