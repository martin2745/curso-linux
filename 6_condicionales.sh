#!/bin/bash
# Author: Martín Gil Blanco

# Uso de condicionales

# Operadores relacionales
# -eq igual a
# -ne no es igual a
# -gt es mayor que
# -ge no es mayor que
# -lt es menor que
# -le es menor o igual a

name=""
age=0
year=0

read -p "Ingresa tu nombre: " name
read -p "Ingresa tu edad: " age

echo "Hola Mi nombre es $name y tengo $age años."

if (( $age >= 18 )); then
	echo "$name soy mayor de edad"
else
	echo "$name no soy mayor de edad"
fi

echo "===================================================="

read -p "¿En que año estamos? " year
if [ $age -ge 18 ] && [ $year -eq 2024 ]; then
	echo "$name. Puedes votar en 2024"
else
	echo "$name. No puedes votar en 2024"
fi
