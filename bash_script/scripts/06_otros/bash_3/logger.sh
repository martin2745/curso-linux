#!/bin/bash

#Atrapar sinais:

## <Ctrl>+<c>: SIGGINT (2)
trap 'clear;echo -e "\n<Ctrl>+<c>";id;logger -p emerg "Ctrl>+<c> executado";sleep 2' 2

for i in $(seq 1 15)
do 
  echo $i
  sleep 1
done 
