#!/bin/bash
# Author: Martín Gil Blanco

# Ayer, a la hora de comer, me comí toda la comida que debería haber comido a lo largo del día:
# Mostrar una palabra por línea sin , . o espacio.

cadena="Ayer, a la hora de comer, me comí toda la comida que debería haber comido a lo largo del día"
salto="si"


for (( pos=0; pos<${#cadena}; pos++ )); do
	caracter=${cadena:$pos:1}

	if [ "$caracter" = " " -o "$caracter" = "," -o "$caracter" = "." ]; then
		if [ $salto ]; then
			salto=""
		else
			echo ""
			salto="si"
		fi
	else
		echo -n $caracter
		salto=""
	fi
done
echo ""
