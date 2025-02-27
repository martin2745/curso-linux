#!/bin/bash

#Atrapar señales:

## <Ctrl>+<c>: SIGINT (2)
trap 'clear;echo -e "\n<Ctrl>+<c>";id;logger -p emerg "Ctrl>+<c> ejecutado";sleep 2' 2

for i in $(seq 1 15)
do 
  echo $i
  sleep 1
done
