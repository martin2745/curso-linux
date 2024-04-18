#!/bin/bash

#   Operadores de comparación de cadenas:
#       =: Igual a (para cadenas)
#       !=: No igual a (para cadenas)
#       -z: Cadena vacía
#       -n: Cadena no vacía

#   Operadores lógicos:
#       &&: AND lógico
#       ||: OR lógico
#       !: NOT lógico

read -p "Introduce dos palabras para ver si son iguales: " v1 v2
if [ ${v1} = ${v2} ]; then
    echo "${v1} y ${v2} son iguales"
else
    echo "${v1} y ${v2} son diferentes"
fi

n1=$((${RANDOM}%30))

if [ ${n1} -ge 10 -a ${n1} -le 20 ]; then
    echo "El valor ${n1} está entre 10 y 20"
else
    echo "El valor ${n1} no está entre 10 y 20"
fi