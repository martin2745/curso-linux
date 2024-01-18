#!/bin/bash
# Author: Martín Gil Blanco

# Uso de scripts dinámicos que pidan al usuario datos

name=""
age=0

read -p "Ingresa tu nombre: " name
read -p "Ingresa tu edad: " age

echo "Hola Mi nombre es $name y tengo $age años."
