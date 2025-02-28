#!/bin/bash

# script1.sh
cat /etc/passwd | sed -e 's| ||g' -e 's|::|:UU:|g' -e 's|:| |g' | awk '{print $1 " --- " $6 " --- " $7}' | tee columnas.txt

# script2.sh
cat /etc/passwd | sed 's|/bin/bash|/bin/bash, shell que non permite acceso ao sistema|g' | awk -F':' '{print $1 " --- " $6 " --- " $7}' | tee columnas.txt

# script3.sh
cat /etc/passwd | cut -d':' -f1,6,7 | sed -e 's|:| --- |g' -e 's|/bin/false|/bin/false, shell que non permite acceso ao sistema|g' | tee columnas.txt
