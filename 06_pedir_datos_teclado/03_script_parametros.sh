#!/bin/bash
# Author: Martín Gil Blanco

# Vamos a mostrar los parametros que se le adjuntan al script y lo vamos
# a indicar con soporte multidioma

if [ ${LANG:0:2} = "en" ]; then
	echo "The name of the script is $0"
	echo "The name of the first parameter is $1"
else
	echo "El nombre del script es $0"
	echo "El nombre del primer parámetro es $1"
fi
