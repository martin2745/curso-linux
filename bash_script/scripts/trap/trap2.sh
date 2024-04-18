#!/bin/bash

## Atrapar señales:
## <Ctrl>+<c>: SIGGINT (2)
## Modifica el valor de la señal 2 por los comandos que se indican.

trap 'clear;echo -e "\n<Ctrl>+<c>";id;sleep 2' 2

for i in $(seq 1 15); do
	echo $i
	sleep 1
done
