#!/bin/bash

i=1

until [ ${i} -gt 10 ]; do
	echo "La variable i vale ${i}"
	i=$((${i}+1))
done
