#!/bin/bash             # Línea necesaria para saber qué shell ejecutará el script


expr 2 \* 2             # Realiza la operación 2*2
echo "2 * 2" | bc       # Realiza la operación 2*2
echo $((2*2))           # Realiza la operación 2*2
