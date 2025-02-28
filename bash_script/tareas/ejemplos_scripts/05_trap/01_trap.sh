#!/bin/bash

## Ignorar <Ctrl>+<c>: SIGGINT (2)
## Podríamos poner varias señales a ignorar: trap '' 2 9 ...
trap '' 2

echo '-------------------------------'
echo 'Ignorando <Ctrl>+<c>. Inténtalo!'
echo '-------------------------------'
for i in $(seq 1 10)
do 
  echo $i
  sleep 1
done 


## Resetear valor por defecto <Ctrl>+<c>: SIGGINT (2)
trap - 2

echo '----------------------------------------'
echo 'Devolvendo valor a <Ctrl>+<c>. Inténtalo!'
echo '----------------------------------------'
for i in $(seq 1 10)
do 
  echo $i
  sleep 1
done 
