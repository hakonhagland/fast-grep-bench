#! /bin/bash

echo -n "Building flex file.."
awk 'NR==1{ printf "%%%%\n.|\\n ;\n.*\\|(%s",$0 }
            { printf "|%s",$0 }
       END  { print ")\\|.*\\n  ECHO;\n%%\n" }' ../../file1.txt > a.fl
echo "Done."
