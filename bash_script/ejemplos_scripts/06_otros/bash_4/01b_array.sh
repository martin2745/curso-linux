#!/bin/bash

## FUNCIONES
f_puerto() {
  unset IPs_activas
  unset IPs_inactivas
  puertos_TCP=("${!1}")
  indice=0
  for i in "${array_IPs[@]}"
  do
    ping -c4 $i 2>/dev/null
    if [ $? -eq 0 ]; then
      IPs_activas[$indice]=$i
    else
      IPs_inactivas[$indice]=$i
    fi
    indice=$((indice+1))
  done
  for i in "${IPs_activas[@]}"
  do
    nc -vz $i "${puertos_TCP[@]}"
  done
  declare -p IPs_activas
  declare -p IPs_inactivas
}

## VARIABLES
array_puertos_TCP=(21 22 23 80 443 445)
array_IPs=('127.0.0.1' 192.168.56.101 10.0.2.10)

## main()
f_puerto "array_puertos_TCP[@]"
