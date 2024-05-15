#!/bin/bash

# Empleando [[ no se tiene en cuenta el separador de campo IFS (espacio) por lo tanto si fueran
# varios campos (una cadena formada por dos palabras) se interpretaría como uno solo.

read -p "Dime tu nombre: " cadena

if [[ ${cadena} = "Martín Gil" ]]; then
	echo "Hola Martín"
else
	echo "No eres Martín"
fi

echo "------------------------------------"

# =~ Permite el uso de expresiones regulares para hacer una comparación

if [[ ${nombre} =~ ^M* ]]; then
	echo "El nombre comienza por M"
else
	echo "El nombre no empieza por M"
fi
