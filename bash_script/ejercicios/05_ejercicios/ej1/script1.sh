#!/bin/bash

cat /etc/passwd | sed -e 's| ||g' -e 's|::|:UU:|g' -e 's|:| |g' | awk '{print $1 " --- " $6 " --- " $7}' > columnas.txt
