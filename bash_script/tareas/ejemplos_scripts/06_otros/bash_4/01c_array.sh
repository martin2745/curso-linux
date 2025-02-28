#!/bin/bash

## FUNCIONES
f_puerto() {
  clear
  unset IPs_puertos_TCP_activos IPs_puertos_TCP_inactivos
  puertos_TCP=("${!1}")
  indice_IPs_activas=0
  indice_IPs_inactivas=0
  indice_puertos_TCP_activos=0
  indice_puertos_TCP_inactivos=0
  for i in "${array_IPs[@]}"
  do
    ping -c4 $i 1>/dev/null 2>&1
    if [ $? -eq 0 ]; then
      IPs_activas[${indice_IPs_activas}]=$i
      for j in "${puertos_TCP[@]}"
      do
        nc -vz $i $j 1>/dev/null 2>&1
        if [ $? -ne 0 ]; then
          puertos_TCP_inactivos[${indice_puertos_TCP_inactivos}]=$j  
          IPs_puertos_TCP_inactivos[${indice_puertos_TCP_inactivos}]="$i $j"  
          indice_puertos_TCP_inactivos=$((${indice_puertos_TCP_inactivos}+1))
        else
          puertos_TCP_activos[${indice_puertos_TCP_activos}]=$j
          IPs_puertos_TCP_activos[${indice_puertos_TCP_activos}]="$i $j"
          indice_puertos_TCP_activos=$((${indice_puertos_TCP_activos}+1))
        fi
      done
      indice_IPs_activas=$((${indice_IPs_activas}+1))
    else
      IPs_inactivas[${indice_inactivas}]=$i
      indice_IPs_inactivas=$((${indice_inactivas}+1))
    fi
  done
  echo "###################"
  echo "IPs activas y puertos activos:"
  declare -p IPs_puertos_TCP_activos
  ##echo "${IPs_puertos_TCP_activos[@]}"
  echo 
  echo "IPs activas y puertos inactivos:"
  declare -p IPs_puertos_TCP_inactivos
  ##echo "${IPs_puertos_TCP_inactivos[@]}"
  echo
  echo "IPs inactivas:"
  declare -p IPs_inactivas
  ##echo "${IPs_inactivas[@]}"
  echo "###################"
}

## VARIABLES
array_puertos_TCP=(21 22 23 80 443 445)
array_IPs=('127.0.0.1' 192.168.56.101 10.0.2.10)

## main()
f_puerto "array_puertos_TCP[@]"
