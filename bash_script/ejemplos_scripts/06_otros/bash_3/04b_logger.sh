#!/bin/bash

#Atrapar señales:

#FUNCIONES:
function f_trap() {
  clear
  echo -e "\n<Ctrl>+<c>"
  id
  logger -p warn "<Ctrl>+<c> ejecutado en el script $0" -t WARNING!!!
  logger -p warn "<Ctrl>+<c> ejecutado en el script $0" -t AVISO!!! -s
  sleep 2 
}

## <Ctrl>+<c>: SIGINT (2)
trap f_trap 2

for i in $(seq 1 15)
do 
  echo $i
  sleep 1
done
