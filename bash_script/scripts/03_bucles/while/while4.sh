#!/bin/bash

cont=1

while [ ${cont} -le 5 ]; do
    echo "El contador es ${cont}"
    cont=$((${cont}+1))
done

echo -e "\n"
for i in $(seq 1 5); do
    echo "La variable i es: ${i}"
done

echo -e "\n"
for script in $(ls *sh); do
    echo "En esta carperta tengo el script: ${script}"
done

# continue: Termina con la ejecución actual del bucle y pasa a la siguiente
# break: Muestra unicamente el primer fichero vacío

echo -e "\n"

cont=1
while [ ${cont} -le 5 ]; do
    if [ ${cont} -eq 3 ]; then
        break
    fi
    echo "El contador es ${cont}"
    cont=$((${cont}+1))
done

echo -e "\n"
cont=1
while [ ${cont} -le 5 ]; do
    if [ ${cont} -eq 3 ]; then
        cont=$((${cont}+1))
        continue
    fi
    echo "El contador es ${cont}"
    cont=$((${cont}+1))
done
