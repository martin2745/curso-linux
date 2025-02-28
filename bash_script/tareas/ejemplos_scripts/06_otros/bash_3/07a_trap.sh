#!/bin/bash

# Atrapar señales:

clear

## Ignorar <Ctrl>+<c>: SIGGINT (2)
trap '' 2

echo '-------------------------------'
echo 'Ignorando <Ctrl>+<c>. ¡Inténtalo!'
echo '-------------------------------'
for i in $(seq 1 15)
do 
  echo $i
  sleep 1
done 


## Restablecer valor por defecto <Ctrl>+<c>: SIGGINT (2)
trap - 2

echo '----------------------------------------'
echo 'Devolviendo valor a <Ctrl>+<c>. ¡Inténtalo!'
echo '----------------------------------------'
for i in $(seq 1 15)
do 
  echo $i
  sleep 1
done
