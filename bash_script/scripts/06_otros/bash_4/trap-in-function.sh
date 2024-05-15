#!/bin/bash

#Atrapar sinais:

clear

function f_trap(){
  ## Ignorar <Ctrl>+<c>: SIGGINT (2) 
  trap '' 2
}

f_trap
echo '-------------------------------'
echo 'Ignorando <Ctrl>+<c>. Inténteo!'
echo '-------------------------------'
for i in $(seq 1 15) 
do 
  echo $i
  sleep 1
done 
