#!/bin/bash
# Author: Martín Gil Blanco

# Comparación de cadenas

cadena1="hola mundo"
cadena2="hola"

echo "=========================================="

if [ "$cadena1" = "$cadena2" ]
then
	echo "Son iguales"
else
	echo "No son iguales"
fi

echo "=========================================="

if [ "$cadena1" != "$cadena2" ]
then
	echo "No son iguales"
else
	echo "Son iguales"
fi
