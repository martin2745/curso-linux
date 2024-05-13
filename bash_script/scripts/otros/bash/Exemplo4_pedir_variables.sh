#!/bin/bash             #Liña necesaria para saber que shell executará o script


echo Dáme o teu nome    #Pedimos o nome do usuario
read nome               #O que se introduce por teclado gárdase como variable nome
echo Ola $nome          #Ensinamos por pantalla Ola e o contido da variable nome

read -p 'Dáme o teu nome ' nome   #Pedimos o nome do usuario é o que se introduce por teclado gárdase como variable nome
echo Ola $nome                   #Ensinamos por pantalla Ola e o contido da variable nome
