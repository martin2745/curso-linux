#!/bin/bash

#Atrapar sinais:

clear

## Ignorar <Ctrl>+<c>: SIGGINT (2)
trap '' 2

echo '-------------------------------'
echo 'Ignorando <Ctrl>+<c>. Inténteo!'
echo '-------------------------------'
for i in $(seq 1 15)
do 
  echo $i
  sleep 1
done 


## Resetear valor por defecto <Ctrl>+<c>: SIGGINT (2)
trap - 2

echo '----------------------------------------'
echo 'Devolvendo valor a <Ctrl>+<c>. Inténteo!'
echo '----------------------------------------'
for i in $(seq 1 15)
do 
  echo $i
  sleep 1
done 
