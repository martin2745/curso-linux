#/bin/bash
# Author: Martín Gil Blanco

# Bucle while

numero=1

while [ $numero -le 10 ]
do
	echo $numero
	((numero++))
done
