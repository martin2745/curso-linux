#!/bin/bash

# Tambien puedes indicar el salto en el seq.
# Para que i tome valores entre 1 y 10 con un salto de 2 hacemos:
# for i in $(seq 1 2 10); do echo $i; done

for i in $(seq 1 10); do
	echo "La variable vale ${i}"
done