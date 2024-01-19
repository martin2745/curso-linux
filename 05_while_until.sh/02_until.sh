#!/bin/bash
# Author: Martín Gil Blanco

# Bucle until

numero=10

until [ $numero -ge 20 ]; do
	echo $numero
	((numero++))
done
