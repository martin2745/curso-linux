#!/bin/bash

#Atrapar sinais:

#FUNCIÓNS:
function f_trap() {
  clear
  echo -e "\n<Ctrl>+<c>"
  id
  logger -p warn "<Ctrl>+<c> executado no script $0" -t WARNING!!!
  logger -p warn "<Ctrl>+<c> executado no script $0" -t AVISO!!! -s
  sleep 2 
}


## <Ctrl>+<c>: SIGGINT (2)
trap f_trap 2

for i in $(seq 1 15)
do 
  echo $i
  sleep 1
done 
