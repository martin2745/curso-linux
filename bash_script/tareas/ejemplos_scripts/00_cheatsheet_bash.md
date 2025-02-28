# CheatSheet de bash

Aquí encontrarás las principales estructuras y ejemplos de bash resumidas.

## Índice

1. [Estructuras](#estructuras)
   - [Recorrer ficheros](#1-recorrer-ficheros)
   - [Control de flujo](#2-control-de-flujo)
   - [Menú](#3-menú)
   - [Funciones](#4-funciones)
   - [ErrorLevel: $?](#5-errorlevel)
   - [Arrays](#6-arrays)
   - [Contadores](#7-contadores)

2. [Ejemplos](#ejemplos)
   - [Comillas](#1-comillas)
   - [Parámetros $](#2-parámetros)
   - [Operaciones matemáticas](#3-operaciones-matemáticas)
   - [Pedir variables](#4-pedir-variables)
   - [Condicional](#5-condicional)
   - [Mejorando la condición](#5-mejorando-la-condición)
   - [Contador](#6-contador)
   - [While](#7-while)
   - [Until](#8-until)
   - [Menú con case](#9-menú-con-case)
   - [Funciones](#10-funciones)
   - [Backup del /home de un usuario](#11-backup-del-home-de-un-usuario)
   - [Backup del directorio indicado por el usuario](#12-backup-del-directorio-indicado-por-el-usuario)

## Estructuras

### 1. Recorrer ficheros

Estructura `while read LINE`.
```bash
while read LINE
do
...
done < file
```

Estructura `cat file | while read LINE`.
```bash
cat file | while read LINE
do
...
done
```

Ejemplo de uso.
```bash
#!/bin/bash
while read LINE
do
    USUARIO=$(echo ${LINE} | cut -d ':' -f1)
    USUARIO_ID=$(echo ${LINE} | cut -d ':' -f3)
    GRUPO_ID=$(echo ${LINE} | cut -d ':' -f4)
    DIRECTORIO=$(echo ${LINE} | cut -d ':' -f6)
    CONSOLA=$(echo ${LINE} | cut -d ':' -f7)
    echo -e "USER=${USUARIO}\tUID=${USUARIO_ID}\tGID=${GRUPO_ID}\tHOME=${DIRECTORIO}\tSHELL=${CONSOLA}"
    sleep 1
done < /etc/passwd
```

### 2. Control de flujo

Estructura `if then fi`.
```bash
if test CONDICION; then ...; fi
    equivale a
if [ CONDICION ]; then ...; fi
    equivale a
[ CONDICION ] && comando
```

Ejemplos de uso.
```bash
#!/bin/bash
##--------------------------------
if test -f /etc/passwd; then
echo Existe
fi
##--------------------------------
if [ -f /etc/passwd ]; then
echo Existe
fi
##--------------------------------
[ -f /etc/passwd ] && echo Existe
```

```bash
#!/bin/bash
##--------------------------------
CADENA='string'
##--------------------------------
if test -n ${CADENA}; then
echo Long. no nula
fi
##--------------------------------
if [ -n ${CADENA} ]; then
echo Long. no nula
fi
##--------------------------------
[ -n ${CADENA] && echo Long. no nula
```

Estructura `if then else fi`.
```bash
if test CONDICION; then ...; else ...; fi
    equivale a
if [ CONDICION ]; then ...; else ...; fi
    equivale a
[ CONDICION ] && comando1 || comando2
```

Ejemplos de uso.
```bash
#!/bin/bash
##--------------------------------
if test ! -f /etc/passwd; then
echo No existe
else
echo Existe
fi
##--------------------------------
if [ ! -f /etc/passwd ]; then
echo No existe
else
echo Existe
fi
##--------------------------------
[ ! -f /etc/passwd ] && echo No existe || echo Existe
```

```bash
##--------------------------------
CADEA='string'
##--------------------------------
if test ! -z ${CADEA}; then
echo Long. no nula
else
echo Long. nula
fi
##--------------------------------
if [ ! -z ${CADEA} ]; then
echo Long. no nula
else
echo Long. nula
fi
##--------------------------------
[ ! -z ${CADEA} ] && echo Long. no nula || echo Long. nula
```

### 3. Menú

Estructura `echo read case ... esac`.
```bash
echo Opción 1...
echo Opción 2...
echo Opción 3...
read -p 'Elige opción: 1,2,3? ' opcion
case $opcion in
    1) 
        comandos
        ;;
    2) 
        comandos
        ;;
    3) 
        comandos
        ;;
    *) 
        echo Opción no correcta
        ;;
esac
```

Ejemplo de uso.
```bash
#!/bin/bash

echo "Opción 1. Ver directorio actual"
echo "Opción 2. Leer /tmp"
echo "Opción 3. Salir"
read -p 'Elige opción: 1, 2, 3? ' opcion

case $opcion in
    1) 
        pwd
        ;;
    2) 
        ls /tmp
        ;;
    3) 
        exit
        ;;
    *) 
        echo "No elegiste ni 1, 2 ni 3"
        ;;
esac
```

Estructura `select do case ... esac done`.
```bash
#!/bin/bash

PS3='Elige opción: 1, 2, 3? '  # Mensaje para que el usuario elija una opción
OPCION1='Texto1'
OPCION2='Texto2'
OPCION3='Texto3'

select opcion in "${OPCION1}" "${OPCION2}" "${OPCION3}"
do
    case ${opcion} in
        ${OPCION1}) 
            # comandos
            ;;
        ${OPCION2}) 
            # comandos
            ;;
        ${OPCION3}) 
            # comandos
            ;;
        *) 
            echo "Opción no correcta"
            ;;
    esac
done
```

Ejemplo de uso.
```bash
#!/bin/bash

PS3='Elige opción: 1, 2, 3? '  # Mensaje para que el usuario elija una opción
OPCION1='Ver directorio actual'
OPCION2='Leer /tmp'
OPCION3='Salir'

select opcion in "${OPCION1}" "${OPCION2}" "${OPCION3}"
do
    case ${opcion} in
        ${OPCION1}) 
            pwd  # Muestra el directorio actual
            ;;
        ${OPCION2}) 
            ls /tmp  # Muestra el contenido de /tmp
            ;;
        ${OPCION3}) 
            exit  # Sale del script
            ;;
        *) 
            echo "No elegiste ni 1, 2 ni 3"  # Mensaje si la opción no es válida
            ;;
    esac
done
```

Estructura `array: select do case esac done`.
```bash
#!/bin/bash

PS3='¿Opción? '  # Mensaje para que el usuario elija una opción
opcions=("Texto1" "Texto2" "Texto3")  # Lista de opciones

select opcion in "${opcions[@]}"
do
    case $opcion in
        "Texto1") 
            # comandos
            ;;
        "Texto2") 
            # comandos
            ;;
        "Texto3") 
            break  # Sale del bucle
            ;;
        *) 
            echo "No elegiste ninguna opción válida"  # Mensaje si la opción no es válida
            ;;
    esac
done
```

Ejemplo de uso.
```bash
#!/bin/bash

PS3='¿Opción? '  # Mensaje para que el usuario elija una opción
opcions=("Ver directorio actual" "Leer /tmp" "Salir")  # Lista de opciones

select opcion in "${opcions[@]}"
do
    case $opcion in
        "Ver directorio actual") 
            pwd  # Muestra el directorio actual
            ;;
        "Leer /tmp") 
            ls /tmp  # Muestra el contenido de /tmp
            ;;
        "Salir") 
            break  # Sale del bucle
            ;;
        *) 
            echo "No elegiste ninguna opción válida"  # Mensaje si la opción no es válida
            ;;
    esac
done
```

### 4. Funciones

Estructura `Definir e Invocar`.
```bash
#!/bin/bash

function f_name() {
    comandos
}

f_name
```

Ejemplo de uso.
```bash
#!/bin/bash

function f_suma() {
    read -p 'Introduce número: ' n1
    read -p 'Otro número: ' n2
    echo "Suma: $n1 + $n2 = $(($n1 + $n2))"
}

f_suma
```

Estructura `Menú`.
```bash
#!/bin/bash

function f_op1() { 
    comandos; 
}

function f_op2() { 
    comandos; 
}

function f_menu() {
    echo Opcion1. Texto1
    echo Opcion2. Texto1
    read -p 'Elixe opcion:1,2? ' opcion
    case $opcion in
        1) 
            comandos;;
        2) 
            comandos;;
        *) 
            echo Opción non correcta && f_menu;;
    esac
}

function f_main() {
    f_menu
}

f_main
```

Ejemplo de uso.
```bash
#!/bin/bash

function f_op1() { 
    pwd; 
}

function f_op2() { 
    ls /tmp; 
}

function f_op3() { 
    exit; 
}

function f_menu() {
    echo Opcion1. Ver directorio actual
    echo Opcion2. Ler /tmp
    echo Opcion3. Sair
    read -p 'Elixe opcion:1,2,3? ' opcion
    case $opcion in
        1) 
            f_op1;;
        2) 
            f_op2;;
        3) 
            f_op3;;
        *) 
            echo Non elixiches nin 1,2,3 && f_menu;;
    esac
}

function f_main() {
    f_menu
}

f_main
```

Estructura `Invocar parámetros`.
```bash
#!/bin/bash

function f_help() {
    echo "Exemplo execución: \$1 \$2" && exit
}

function f_parametros() {
    [ $# -ne 2 ] && f_help
}

function f_main() {
    f_parametros $*
}

f_main $*
```

Ejemplo de uso.
```bash
#!/bin/bash

function f_help() {
    echo "Exemplo execución: 4 17"
    exit
}

function f_parametros() {
    [ $# -ne 2 ] && f_help
}

function f_suma() {
    echo A suma de $1 + $2 é: $(($1+$2))
}

function f_main() {
    f_parametros $*
    f_suma $*
}

f_main $*
```

### 5. ErrorLevel: $?

Estructura.
```bash
comando
[ $? -eq 0 ] && echo OK || echo KO
```

Ejemplo de uso.
```bash
#!/bin/bash
ping -c2 127.0.0.1
[ $? -eq 0 ] && echo OK || echo KO

nc -vz 127.0.0.1 80
[ $? -eq 0 ] && echo OK || echo KO

read -p 'Número: ' n1
[[ $n1 =~ ^-?[0-9]+$ ]] && echo SI || echo NO
```

### 6. Arrays

Estructura.
```bash
array_name=(1 2 3)
for i in "${array_name[@]}"
do
    echo $i
done
```

Ejemplo de uso.
```bash
#!/bin/bash

array_ports_TCP=(21 22 23 80 443 445)
array_IPs=(127.0.0.1 127.127.127.127)

function f_port() {
    for i in "${array_IPs[@]}"
    do
        nc -vz $i "${array_ports_TCP[@]}"
    done
}

f_port
```

### 7. Contadores

Estructura `for i in $(seq 1 10)`.
```bash
#!/bin/bash
for i in $(seq 1 10)
do
...
done
```

Ejemplos de uso.
```bash
#!/bin/bash
for i in $(seq 1 10)
do
    echo Valor de i: $i
done
```

Estructura `for ((i=1;i<=10;i++))`.
```bash
#!/bin/bash
for ((i=1;i<=10;i++))
do
...
done
```

Ejemplos de uso.
```bash
#!/bin/bash
for ((i=1;i<=10;i++))
do
    echo Valor de i: $i
done
```

## Ejemplos

### 1. Comillas
Script para entender el tipo de comillas existentes en bash.

```bash
#!/bin/bash         #Línea necesaria para saber qué shell ejecutará el script 
a=ls                #Definimos la variable a con el valor ls 
echo '$a'           #Comillas simples, no interpreta caracteres especiales como el carácter $ 
echo "$a"           #Comillas dobles, interpreta caracteres especiales como el carácter $ y todo lo que se encuentre entre ellas es  considerado como un solo parámetro 
echo `$a`           #Comillas invertidas, ejecuta el contenido dentro de las comillas
```

### 2. Parámetros $
Script para entender el tipo de parámetros existentes.

```bash
#!/bin/bash 
echo "El parámetro cero, $0, es el propio nombre del script" 
echo "Primer parámetro que recibo: $1, segundo: $2..." 
echo "El número total de parámetros pasados en la ejecución del script (excluido $0) es: $#" 
echo "La lista completa de parámetros (excluido $0), separados por un espacio, es $*" 
echo "El Identificador del proceso (PID) es $$" 
echo "La salida de la ejecución del último comando puede ser correcta (valor cero) o errónea (valor distinto de cero), siendo en este caso $?" 
```

### 3. Operaciones matemáticas
Script para hacer operaciones matemáticas con números enteros.

```bash
#!/bin/bash
expr  2  \*  2              #Realiza la operación 2*2  
echo  "2  *  2"  |  bc      #Realiza la operación 2*2  
echo $((2*2))               #Realiza la operación 2*2  
```

### 4. Pedir variables
Script para pedir variables por teclado.

```bash
#!/bin/bash
echo Dame tu nombre #Pedimos el nombre del usuario  
read nombre #Lo que se introduce por teclado se guarda como la variable nombre  
echo Hola $nombre #Mostramos en pantalla "Hola" y el contenido de la variable nombre  
```

### 5. Condicional
Scripts para hacer una condición.

```bash
#!/bin/bash

echo "Dame un número" # Pedimos un número 
read n1 # Lo que se introduce por teclado se guarda como la variable n1 

if [ $n1 -lt 100 ] # Inicio de la condición: Si el valor de n1 es menor que 100 
then  
    echo "El número $n1 es menor que 100" # Muestra un mensaje en pantalla 
else  
    echo "El número $n1 es mayor o igual que 100" # Muestra un mensaje en pantalla 
fi  
```

Mejorando la condición.

```bash
#!/bin/bash

echo "Dame un número" # Pedimos un número 
read n1 # Lo que se introduce por teclado se guarda como la variable n1 

if [ $n1 -le 100 ] # Inicio de la condición: Si el valor de n1 es menor o igual que 100 
then  
    if [ $n1 -lt 100 ] # Inicio de la segunda condición: Si el valor de n1 es menor que 100  
    then  
        echo "El número $n1 es menor que 100" # Muestra un mensaje en pantalla  
    else  
        echo "El número es igual a 100" # Muestra un mensaje en pantalla  
    fi # Fin de la segunda condición  
else  
    echo "El número $n1 es mayor que 100" # Muestra un mensaje en pantalla  
fi # Fin de la condición principal  
```

### 6. Contador
Script para hacer un contador.

```bash
#!/bin/bash

for i in $(seq 1 100) # Comienza el bucle contador donde la variable i toma valores de 1 a 100 
do  # Hacer  
    echo "Valor de i: $i" # Muestra el valor de la variable i en cada iteración del bucle, es decir, los números del 1 al 100  
done # Fin del bucle  
```

### 7. While
Script de funcionamiento de while.

```bash
#!/bin/bash

i=1 # Definimos la variable i con el valor 1.  
while [ $i -le 100 ] # Comienza el bucle contador donde la variable i toma valores de 1 a 100: Mientras i sea menor o igual a 100  
do  # Hacer  
    echo "Valor de i: $i" # Muestra el valor de la variable i en cada iteración del bucle, siendo el primer valor 1  
    i=$((i+1)) # Aumenta en una unidad el valor anterior, si era 1, ahora será 2  
done # Fin del bucle  
```

### 8. Until
Script de funcionamiento de until.

```bash
#!/bin/bash

i=1 # Definimos la variable i con el valor 1.  
until [ $i -ge 101 ] # Comienza el bucle contador donde la variable i toma valores de 1 a 100: Hasta que i sea mayor o igual a 101  
do  # Hacer  
    echo "Valor de i: $i" # Muestra el valor de la variable i en cada iteración del bucle, siendo el primer valor 1  
    i=$((i+1)) # Aumenta en una unidad el valor anterior, si era 1, ahora será 2  
done # Fin del bucle  
```

### 9. Menú con case
Script de funcionamiento de un menú con case.

```bash
#!/bin/bash

echo "Opción 1. Ver directorio actual" # Muestra en pantalla  
echo "Opción 2. Leer /tmp" # Muestra en pantalla  
echo "Opción 3. Salir" # Salir  
echo "Elige opción: 1, 2, 3?" # Escoge opción  
read opcion # La opción escogida se guarda como valor en la variable opcion  

case $opcion in # Comienza el case para crear el menú  
    1) pwd # Si el valor de la variable opcion es 1, se ejecutan los siguientes comandos.  
    ;; # Toda opción debe terminar con ;;  
    2) ls /tmp # Si el valor de la variable opcion es 2, se ejecutan los siguientes comandos.  
    ;; # Toda opción debe terminar con ;;  
    3) exit # Si el valor de la variable opcion es 3, se ejecutan los siguientes comandos.  
    ;; # Toda opción debe terminar con ;;  
    *) echo "No elegiste ni 1, 2 ni 3"  # Mensaje en pantalla  
    ;; # Toda opción debe terminar con ;;  
esac # Fin del case para crear el menú  
```

### 10. Funciones
Script de funcionamiento de funciones.

```bash
#!/bin/bash

suma() { # Definimos la función suma  
    echo "Dame un número" # Pedimos un número  
    read n1 # Recogemos el número como valor en la variable n1  
    echo "Dame otro número" # Pedimos otro número  
    read n2 # Recogemos el número como valor en la variable n2  
    echo "La suma de $n1 y $n2 es: $(($n1+$n2))" # Realizamos la suma  
} # Finaliza la definición de la función suma  

suma # Llamamos a la función suma  
```

### 11. Backup del /home de un usuario
Script de copia de seguridad o backup del /home de un usuario.

```bash
#!/bin/bash

inicio() { # Definimos la función inicio  
    echo "Dame usuario" # Mensaje por pantalla  
    read user # Recogemos el usuario como valor en la variable user  
    testear # Llamamos a la función testear  
} # Finaliza la definición de la función inicio  

testear() { # Definimos la función testear  
    if test -d /home/$user # Comienza la condición: Si existe el directorio /home/$user  
    then # Entonces  
        echo "El directorio /home/$user existe" # Mensaje por pantalla  
        tar -czvf user.tar.gz /home/$user # Empaquetar y comprimir el directorio /home/$user  
    else # Sino  
        echo "El directorio /home/$user no existe" # Mensaje por pantalla  
        echo "El contenido de /home es el siguiente:" `ls /home` # Muestra el directorio /home para elegir bien el usuario  
        inicio # Llamamos a la función inicio  
    fi  # Finaliza la condición  
}  

inicio # Llamamos a la función inicio  
```

### 12. Backup del directorio indicado por el usuario
Script de funcionamiento para realizar una copia de seguridad o backup de un directorio concreto.

```bash
#!/bin/bash

inicio() { # Definimos la función inicio  
    echo "Dame carpeta" # Mensaje por pantalla  
    read cartafol # Recogemos lo escrito como valor en la variable cartafol  
    testear # Llamamos a la función testear  
} # Finaliza la definición de la función inicio  

testear() { # Definimos la función testear  
    if test -d $cartafol # Comienza la condición: Si existe el directorio $cartafol  
    then # Entonces  
        echo "El directorio $cartafol existe" # Mensaje por pantalla  
        tar -cvjf cartafol.tar.bz2 $cartafol # Empaquetar y comprimir el directorio $cartafol  
    else # Sino  
        echo "El directorio $cartafol no existe" # Mensaje por pantalla  
        inicio # Llamamos a la función inicio  
    fi  # Finaliza la condición  
}  

inicio # Llamamos a la función inicio  
```