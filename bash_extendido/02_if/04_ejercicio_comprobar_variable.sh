#!/bin/bash
# Author: Martín Gil Blanco

# if interno

variable=""

if [ $variable ]
then
	echo "La variable existe y contiene un valor"
else
	if [ ${variable-unset} ]
	then
		echo "La variable no existe"
	else
		echo "La variable está vacía"
	fi
fi
