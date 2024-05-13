#!/bin/bash

declare -r NUMBER=$((1+RANDOM%999))
declare -i NUMBER

function f_read_number() {
  read -p 'Adiviña o número de 3 cifras: ' -n3 number
  declare -i number
}


function f_procure() {
if [ $number -gt $NUMBER ] ; then
  echo -e '\nO número é menor' 
  f_read_number
else 
  if [ $number -lt $NUMBER ] ; then
    echo -e '\nO número é maior' 
    f_read_number
  else 
    echo -e '\nPARABÉNS:!!! Adiviñaches o número'
    exit
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
