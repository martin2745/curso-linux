#!/bin/bash

declare -r NUMBER=$((1+RANDOM%999))
declare -i NUMBER
cont=0

function f_leer_numero() {
  read -p 'Adivina el número de 3 cifras: ' -n3 number
  declare -i number
  cont=$((cont+1))
}

function f_procesar() {
  if [ $number -gt $NUMBER ] 2>/dev/null; then
    #echo -e "\naaa $?"
    echo -e '\nEl número es menor' 
    f_leer_numero
  else 
    if [ $number -lt $NUMBER ] 2>/dev/null; then
      #echo -e "\nbbb $?"
      echo -e '\nEl número es mayor' 
      f_leer_numero
    else 
      #echo -e "\nccc $?"
      if [ $? -ne 2 ]; then
        echo -e "\n¡FELICIDADES! Adivinaste el número en $cont intentos"
        exit
      else
        echo -e '\nDebe introducir un número'
        f_leer_numero
      fi
    fi
  fi
  f_procesar
}

f_main() {
  clear
  echo -e "\n $NUMBER $number"
  f_leer_numero
  f_procesar
}

f_main
