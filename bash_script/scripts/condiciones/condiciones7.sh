#!/bin/bash
#   Operadores de comparación numérica:
#       -eq: Igual a
#       -ne: No igual a
#       -gt: Mayor que
#       -lt: Menor que
#       -ge: Mayor o igual que
#       -le: Menor o igual que

read -p "Introduce los dos valores numericos para comparar cual es mayor: " v1 v2
if [ ${v1} -gt ${v2} ]; then
    echo "El valor ${v1} es mayor que ${v2}"
elif [ ${v1} -eq ${v2} ]; then
    echo "El valor ${v1} es igual que ${v2}"
else
    echo "El valor ${v1} es menor que ${v2}"
fi