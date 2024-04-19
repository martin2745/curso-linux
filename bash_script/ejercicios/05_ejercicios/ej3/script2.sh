#!/bin/bash

tmpfile=$(mktemp)
grep -v "Usuario" users.csv > ${tmpfile}

cat ${tmpfile} | while read linea; do
	[ 'on' = $(echo ${linea} | tr -d '"' | cut -d',' -f5) ]
	if [ $? -eq 0 ]; then
		user=$(echo ${linea} | tr -d '"' | cut -d',' -f1)
		password=$(echo ${linea} | tr -d '"' | cut -d',' -f2)
		consola=$(echo ${linea} | tr -d '"' | cut -d',' -f3)
		dir_home=$(echo ${linea} | tr -d '"' | cut -d',' -f4)
		useradd -m -d ${dir_home} -s ${consola} -p $(mkpasswd ${password}) ${user}
	fi
done

rm -f ${tmpfile}
