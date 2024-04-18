#!/bin/bash

suma(){
	read -p "Dime el primer operador: " n1
	read -p "Dime el segundo operador: " n2
	echo "La suma de ${n1} y ${n2} es $((${n1}+${n2}))"
}

suma
