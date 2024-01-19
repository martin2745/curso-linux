#!/bin/bash
# Author: Martín Gil Blanco

# Hacer un script que muestre por pantalla:
# La letra número 1 es la a.
# La letra número 2 es la b.
# …
# La letra número ... es la ...

expresion="La letra número "
expresion_dos=" es la "
punto="."
contador=1
letra=""

for i in {a..z}
do
	echo $expresion$i$expresion_dos$contador$punto
	contador=$(( $contador + 1 ))
done
