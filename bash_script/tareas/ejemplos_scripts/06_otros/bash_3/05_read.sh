#!/bin/bash

clear

# Leemos una secuencia de números (1 2 3 4 5) y mostramos cada valor de A
echo '1 2 3 4 5'| while read A
do 
  echo Resultado A: $A
  sleep 1
done

echo
echo '###############################'
echo

# Leemos una secuencia de números (1 2 3 4 5) y mostramos los valores de A y B
echo '1 2 3 4 5'| while read A B
do 
  echo Resultado A: $A 
  sleep 1
  echo Resultado B: $B 
  sleep 1
done

echo
echo '###############################'
echo

# Leemos una secuencia de números (1 2 3 4 5) y mostramos los valores de A, B y C
echo '1 2 3 4 5'| while read A B C
do 
  echo Resultado A: $A
  sleep 1
  echo Resultado B: $B
  sleep 1
  echo Resultado C: $C
  sleep 1
done

echo
echo '###############################'
echo

# Leemos una secuencia de números (1 2 3 4 5) y mostramos los valores de A, B, C y D
echo '1 2 3 4 5'| while read A B C D
do 
  echo Resultado A: $A
  sleep 1
  echo Resultado B: $B
  sleep 1
  echo Resultado C: $C
  sleep 1
  echo Resultado D: $D
  sleep 1
done

echo
echo '###############################'
echo

# Leemos una secuencia de números (1 2 3 4 5) y mostramos los valores de A, B, C, D y E
echo '1 2 3 4 5'| while read A B C D E
do 
  echo Resultado A: $A
  sleep 1
  echo Resultado B: $B
  sleep 1
  echo Resultado C: $C
  sleep 1
  echo Resultado D: $D
  sleep 1
  echo Resultado E: $E
  sleep 1
done
