#!/bin/bash

if [ ! -e ~/pruebaBucles ]; then
    mkdir ~/pruebaBucles
else
    rm -r ~/pruebaBucles
    mkdir ~/pruebaBucles
fi

for i in $(seq 1 5); do 
    touch ~/pruebaBucles/fichero${i}.txt
done

for fichero in $(ls ~/pruebaBucles); do
    if [ -e ~/pruebaBucles/${fichero} -a $(du -a ~/pruebaBucles/${fichero} | cut -f1) -eq 0 ]; then
        echo "El fichero ${fichero} está vacío"  
    fi
done

rm -r ~/pruebaBucles