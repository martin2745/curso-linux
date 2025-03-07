#!/bin/bash

# Realizar un script al que le daremos desde la línea de comandos tres parámetros y nos  
# mostrará el nombre del comando así como los argumentos que le pasamos:  
# El comando es: ./xxxx  
# Los argumentos son: arg1 arg2 arg3  

echo "El comando es: ${0}"
echo "Los argumentos son: ${1} ${2} ${3}"
