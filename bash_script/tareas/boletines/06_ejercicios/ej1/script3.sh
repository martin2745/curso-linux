#!/bin/bash

cat /etc/passwd | cut -d':' -f1,6,7 | sed -e 's|:| --- |g' -e 's|/bin/false|/bin/false, shell que non permite acceso ao sistema|g' > columnas.txt
