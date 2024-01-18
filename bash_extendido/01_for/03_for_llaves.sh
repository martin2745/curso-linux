#!/bin/bash
# Author: Martín Gil Blanco

# Bucle for con llaves

for iteracion in {1..10}
do
	echo "Estamos en la iteración: $iteracion"
done

echo "==========================================="

echo "Indico un paso de 2 entre iteraciones"
for iteracion in {1..10..2}
do
	echo "Estamos en la iteración: $iteracion"
done
