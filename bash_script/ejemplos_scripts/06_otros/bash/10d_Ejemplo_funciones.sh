#!/bin/bash         

# Variable local/global
# Alcance de variables en las funciones. Verificar si la ejecución de una función modifica una variable global:
# #  No la modifica cuando dentro de la función usamos local o declare sin opción -g
# #  Sí la modifica en caso contrario

#---------------------------------------
n1=4                # Definimos variable global n1 con el valor 4
function f1() {     # Definimos la función f1
  n1=48             # Definimos dentro de la función la variable global n1 con el valor 48
}                   # Finaliza la definición de la función f1
f1                  # Llamamos a la función f1
echo $n1 "La función define n1 como variable global con lo cual modifica el valor inicial n1=4, siendo ahora n1=48"
#---------------------------------------


#---------------------------------------
n2=4                # Definimos variable global n2 con el valor 4
function f2() {     # Definimos la función f2
  local n2=48       # Definimos dentro de la función la variable local n2 con el valor 48
}                   # Finaliza la definición de la función f2
f2                  # Llamamos a la función f2
echo $n2 "La función define n2 como variable local con lo cual no modifica el valor inicial n2=4"
#---------------------------------------


#---------------------------------------
n3=4                # Definimos variable global n3 con el valor 4
function f3() {     # Definimos la función f3
  declare n3=48     # Definimos dentro de la función la variable local n3 con el valor 48
}                   # Finaliza la definición de la función f3
f3                  # Llamamos a la función f3
echo $n3 "La función define n3 como variable local con lo cual no modifica el valor inicial n3=4"
#---------------------------------------


#---------------------------------------
n4=4                # Definimos variable global n4 con el valor 4
function f4() {     # Definimos la función f4
  declare -g n4=48  # Definimos dentro de la función la variable global n4 con el valor 48
}                   # Finaliza la definición de la función f4
f4                  # Llamamos a la función f4
echo $n4 "La función define n4 como variable global con lo cual modifica el valor inicial n4=4, siendo ahora n4=48"
#---------------------------------------
