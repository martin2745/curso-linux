#!/bin/bash
# Author: Martín Gil Blanco

# Un script que seleccione un número y pide al usuario que lo adivine,
# si no lo acierta le dice al usuario si el número es mayor o menor que
# el número introducido por el usuario.

numero_adivinar=$(shuf -i 0-9 -n1)
respuesta=10
intento=1

while [ $respuesta -ne $numero_adivinar ]; do
	read -n 1 -p "Escribe un número (0-9): " respuesta
	echo ""
	if [ $respuesta -gt $numero_adivinar ]; then
		echo "El número a adivinar es menor que $respuesta"
	elif [ $respuesta -lt $numero_adivinar ]; then
		echo "EL número a adivinar es mayor que $respuesta"
	fi
	((intento++))
done
echo "Felicidades el número era $numero_adivinar. Has ganado en el intento: $intento"
