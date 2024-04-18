#!/bin/bash

tmpfile=$(mktemp)
grep -v "Usuario" users.csv > ${tmpfile}

while read A; do
	user=$(echo ${A} | tr -d '"' | cut -d',' -f1)
	userdel -r ${user}
done < ${tmpfile}

rm -f ${tmpfile}
