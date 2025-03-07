#!/bin/bash

# Escribir el comando que muestre por pantalla cuántos archivos y subdirectorios  
# del directorio actual contienen en su nombre la letra “b”.

find . -iname "*b*" -maxdepth 1 2>/dev/null | wc -l
