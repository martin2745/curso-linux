#!/bin/bash
# Author: Martín Gil Blanco

# Bucle for con tubería que usando el comando tr sustituye el . por ,

for iteracion in $(seq 0 .2 2 | tr , .)
do
	echo "Estamos en la iteración: $iteracion"
done

