#!/bin/bash

declare -r NUMBER=$((1+RANDOM%999))
declare -i NUMBER
cont=0

function f_read_number() {
  read -p 'Adiviña o número de 3 cifras: ' -n3 number
  declare -i number
  cont=$((cont+1))
}


function f_procure() {
if [ $number -gt $NUMBER ] 2>/dev/null; then
#echo -e "\naaa $?"
  echo -e '\nO número é menor' 
  f_read_number
else 
  if [ $number -lt $NUMBER ] 2>/dev/null; then
#echo -e "\nbbb $?"
    echo -e '\nO número é maior' 
    f_read_number
  else 
#echo -e "\nccc $?"
    if [ $? -ne 2 ]; then
      echo -e "\nPARABÉNS:!!! Adiviñaches o número en $cont intentos"
      exit
    else
      echo -e '\nDebe introducir un número'
      f_read_number
    fi
  fi
fi
f_procure
}


f_main() {
  clear
  echo -e "\n $NUMBER $number"
  f_read_number
  f_procure
}

f_main
