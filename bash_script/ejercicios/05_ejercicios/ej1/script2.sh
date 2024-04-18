#!/bin/bash

cat /etc/passwd | sed 's|/bin/false|/bin/false, shell que non permite acceso ao sistema|g' | awk -F':' '{print $1 " --- " $6 " --- " $7}' > columnas.txt
