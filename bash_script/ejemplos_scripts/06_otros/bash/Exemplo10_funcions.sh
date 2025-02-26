#!/bin/bash             #Liña necesaria para saber que shell executará o script


suma() {                #Definimos a función suma
echo Dame numero        #Pedimos un número
read n1                 #Recollemos o número como valor na variable n1
echo Dame outro numero  #Pedimos outro número
read n2                 #Recollemos o número como valor na variable n2
echo A suma de $n1 e $n2 é: $(($n1+$n2)) #Facemos a suma
}                       #Finaliza a definición da función suma
suma                    #Chamamos á función suma
