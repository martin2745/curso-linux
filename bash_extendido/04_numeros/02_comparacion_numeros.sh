#!/bin/bash
# Author: Martín Gil Blanco

# Consigue dos números aleatorios del 1 al 10 y muestra si son iguales o no

# Operadores relacionales
# -eq igual a
# -ne no es igual a
# -gt es mayor que
# -ge no es mayor que
# -lt es menor que
# -le es menor o igual a

numero_uno=$(shuf -i 1-10 -n1)
numero_dos=$(shuf -i 1-10 -n1)

##########################################################################

echo "Empleando -eq"
if [ $numero_uno -eq $numero_dos ]
then
	echo "$numero_uno y $numero_dos son iguales"
else
	echo "$numero_uno y $numero_dos no son iguales"
	if [ $numero_uno -gt $numero_dos ]; 
	then
		echo "$numero_uno es mayor que $numero_dos"
	else
		echo "$numero_uno es menor que $numero_dos"
	fi
fi

