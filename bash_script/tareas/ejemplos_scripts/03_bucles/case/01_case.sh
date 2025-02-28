#!/bin/bash

echo "Opción 1. Ver el directorio actual"
echo "Opción 2. Leer tmp"
echo "Opción 3. Salir"

read -p "Dime una opción: " op

case ${op} in
	1) pwd;;
	2) ls -l /tmp;;
	3) exit;;
	*) echo "Opción incorrecta";;
esac
