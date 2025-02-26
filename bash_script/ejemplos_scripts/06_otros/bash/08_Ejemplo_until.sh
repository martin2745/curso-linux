#!/bin/bash             # Línea necesaria para saber qué shell ejecutará el script

i=1                     # Definimos la variable i con valor 1.
until [ $i -ge 101 ]    # Comienza el bucle contador donde la variable i toma el valor de 1 a 100: Hasta que i sea mayor o igual a 101
do                      # hacer
    echo "Valor de i: $i" # Muestra el valor de la variable i para cada valor del bucle, siendo el primer valor 1
    i=$(($i+1))         # Aumenta una unidad al valor anterior, si era 1, entonces ahora el valor es 2
done                     # hecho
