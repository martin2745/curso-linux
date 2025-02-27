#!/bin/bash

i=1

while [ ${i} -le 10 ]; do
	echo "El contador vale: ${i}"
	sleep 1
	i=$((${i}+1))
done
