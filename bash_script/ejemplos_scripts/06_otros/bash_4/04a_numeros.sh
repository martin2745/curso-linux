#!/bin/bash

declare -r NUMBER=$((1+RANDOM%999))
declare -i NUMBER

function f_leer_numero() {
  read -p 'Adivina el número de 3 cifras: ' -n3 number
  declare -i number
}

function f_procesar() {
  if [ $number -gt $NUMBER ] ; then
    echo -e '\nEl número es menor'
    f_leer_numero
  else 
    if [ $number -lt $NUMBER ] ; then
      echo -e '\nEl número es mayor'
      f_leer_numero
    else 
      echo -e '\n¡FELICIDADES! Adivinaste el número'
      exit
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
