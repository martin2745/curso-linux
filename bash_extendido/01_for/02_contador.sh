#!/bin/bash
# Author: Martín Gil Blanco

# Implementa un contador

contador=1

for color in amarillo rojo verde banco negro
do
	echo "En la iteración $contador el color es: $color"
	contador=$(( $contador + 1 ))
done
