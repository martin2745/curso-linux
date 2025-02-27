#!/bin/bash

NUM=$(cat users.csv | wc -l)

for i in $(seq 2 $NUM); do
	linea=$(head -${i} users.csv | tail -1)
	user=$(echo ${linea} | tr -d '"' | cut -d',' -f1)
	password=$(echo ${linea} | tr -d '"' | cut -d',' -f2)
	consola=$(echo ${linea} | tr -d '"' | cut -d',' -f3)
	dir_home=$(echo ${linea} | tr -d '"' | cut -d',' -f4)
	echo $user y $password y $consola y $dir_home
	useradd -m -d ${dir_home} -s ${consola} -p $(mkpasswd ${password}) ${user}
done


