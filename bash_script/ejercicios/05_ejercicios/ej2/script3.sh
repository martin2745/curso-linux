#!/bin/bash

oldIFS=${IFS}
IFS=$'\n'

tmpfile=$(mktemp)
grep -v "Usuario" users.csv > ${tmpfile}

for linea in $(cat ${tmpfile}); do
	user=$(echo ${linea} | tr -d '"' | cut -d',' -f1)
	password=$(echo ${linea} | tr -d '"' | cut -d',' -f2)
	consola=$(echo ${linea} | tr -d '"' | cut -d',' -f3)
	dir_home=$(echo ${linea} | tr -d '"' | cut -d',' -f4)
	useradd -m -d ${dir_home} -s ${consola} -p $(mkpasswd ${password}) ${user}
done

rm -f ${tmpfile}

IFS=${oldIFS}
