#!/bin/bash
# Author: Martín Gil Blanco

function suma(){
    local resultado=$(( $1 + $2 ))
    echo $resultado
}

# Llamamos a la función y almacenamos el resultado en una variable
resultado_suma=$(suma 3 5)

# Mostramos el resultado almacenado
echo "El resultado de la suma es: $resultado_suma"

