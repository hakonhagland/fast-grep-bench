#! /bin/bash

LC_ALL=C grep -E -f ../../regexp1.txt ../../file2.txt >out.txt
