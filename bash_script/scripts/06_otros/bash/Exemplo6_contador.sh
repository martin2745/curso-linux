#!/bin/bash             #Liña necesaria para saber que shell executará o script


for i in $(seq 1 10)   #Comeza bucle contador onde a variable i toma o valor de 1 a 10
do                      #facer
echo Valor de i: $i     #Ensina o valor da variable i para cada valor do bucle, así ensina os números de 1 ata 10
done                    #feito

echo -------------------
sleep 3
echo -------------------

for ((i=1;i<=10;i++))  #Comeza bucle contador onde a variable i toma o valor de 1 a 10
do                      #facer
echo Valor de i: $i     #Ensina o valor da variable i para cada valor do bucle, así ensina os números de 1 ata 10
done
