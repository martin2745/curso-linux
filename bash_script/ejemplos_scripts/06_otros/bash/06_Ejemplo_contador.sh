#!/bin/bash             # Línea necesaria para saber qué shell ejecutará el script

for i in $(seq 1 10)   # Comienza el bucle contador donde la variable i toma el valor de 1 a 10
do                      # hacer
echo "Valor de i: $i"   # Muestra el valor de la variable i para cada valor del bucle, así muestra los números del 1 al 10
done                    # hecho

echo -------------------
sleep 3
echo -------------------

for ((i=1;i<=10;i++))  # Comienza el bucle contador donde la variable i toma el valor de 1 a 10
do                      # hacer
echo "Valor de i: $i"   # Muestra el valor de la variable i para cada valor del bucle, así muestra los números del 1 al 10
done
