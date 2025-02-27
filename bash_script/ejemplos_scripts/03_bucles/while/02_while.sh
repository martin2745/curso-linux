#!/bin/bash

while read A B C; do
	echo "El valor de A es: ${A}"
	sleep 1
        echo "El valor de B es: ${B}"
        sleep 1
        echo "El valor de C es: ${C}"
        sleep 1
done < numeros.txt
