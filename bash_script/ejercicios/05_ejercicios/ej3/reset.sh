#!/bin/bash

tmpfile=$(mktemp)
grep -v "Usuario" users.csv > ${tmpfile}

while read A; do
	estado=$(echo ${A} | tr -d '"' | cut -d',' -f5)
	if [ ${estado} = 'on' ]; then
		user=$(echo ${A} | tr -d '"' | cut -d',' -f1)
		userdel -r ${user}
	fi
done < ${tmpfile}

rm -f ${tmpfile}
