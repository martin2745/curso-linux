#!/bin/bash
# Que reciba por parámetros un mínimo de 5 datos y nos diga 
# cuántos se han introducido y el valor de los tres primeros

# Comprobamos si se han pasado al menos 5 parámetros
if [ "${#}" -lt 5 ]; then
    echo "Error: Se necesitan al menos 5 datos como parámetro."
    exit 1 # Número diferente de 0 ya que hay un error
fi

# Mostramos la cantidad de datos introducidos
echo "Se han introducido ${#} datos."

# Mostramos el valor de los tres primeros parámetros
echo "Los tres primeros datos son: ${1}, ${2}, ${3}"