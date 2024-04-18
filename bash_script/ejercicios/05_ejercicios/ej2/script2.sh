#!/bin/bash

tmpfile=$(mktemp)
grep -v "Usuario" users.csv > ${tmpfile}

cat ${tmpfile} | while read linea; do
	user=$(echo ${linea} | tr -d '"' | cut -d',' -f1)
	pass=$(echo ${linea} | tr -d '"' | cut -d',' -f2)
	consola=$(echo ${linea} | tr -d '"' | cut -d',' -f3)
	dir_home=$(echo ${linea} | tr -d '"' | cut -d',' -f4)
	useradd -m -d ${dir_home} -s ${consola} -p $(mkpasswd ${pass}) ${user}
done

rm -f ${tmpfile}
