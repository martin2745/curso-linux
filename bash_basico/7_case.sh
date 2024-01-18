#!/bin/bash
# Author: Martín Gil Blanco

# Sentencia Case

opcion=""
read -p "Ingrese una Opción [A-B]: " opcion

case $opcion in
	"A") echo "Ha ingresado la opción A";;
	"B") echo "Ha ingresado la opción B";;
	[C-Z]) echo "Ha ingresado un valor fuera del rango";;
	*) echo "Por favor, solo caracteres dentro del rango [A-B]"
esac
