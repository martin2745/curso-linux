#!/bin/bash

read -p "Dame un número: " n1

[ ${n1} -lt 100 ] && echo "El número ${n1} es menor que 100" || ( [ ${n1} -gt 100 ] && echo "El número ${n1} es mayor que 100" ||  echo "El número ${n1} é igual a 100" )