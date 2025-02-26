#!/bin/bash       # Línea necesaria para saber qué shell ejecutará el script

a=ls              # Definimos la variable a con el valor ls

echo 1 '$a'       # Entrecomillado con comillas simples -> muestra $a
                    # Comillas simples -> NO interpreta caracteres especiales: $(dólar) `(comilla invertida) \(barra invertida=carácter de escape), *(asterisco), @(arroba)
                    # Comillas simples -> el entrecomillado PRESERVA el VALOR LITERAL de cada carácter
                    # Una comilla simple dentro del entrecomillado de comillas simples -> ERROR -> aunque esté precedida por el carácter de escape \, una comilla simple NO puede estar dentro de comillas simples -> ver echo 23


echo 2 "$a"       # Entrecomillado con comillas dobles -> muestra ls
                    # Comillas dobles -> SÍ interpreta caracteres especiales: $(dólar) `(comilla invertida) \(barra invertida=carácter de escape), *(asterisco), @(arroba)
                    # Comillas dobles -> valor literal para caracteres no especiales
                    # Comillas dobles -> todo el entrecomillado se considera como un solo parámetro
                    # Una comilla doble dentro del entrecomillado de comillas dobles -> SÍ puede existir una comilla doble precedida por el carácter de escape \ -> ver echo 24

echo 3 `$a`       # Entrecomillado con comillas invertidas -> ejecuta el contenido dentro de las comillas -> ejecuta ls

echo 4 $($a)      # Equivale al comando anterior: `$a`



echo 5 "'$a'"     # Comillas dobles -> interpreta el carácter $ -> expande $a -> comillas simples -> valor literal -> muestra 'ls'

echo 6 "`$a`"     # Comillas dobles -> interpreta el carácter $ -> expande $a -> comillas invertidas -> ejecuta ls

echo 7 "$($a)"    # Equivale al comando anterior: "`$a`"



echo 8 '"$a"'     # Comillas simples -> valor literal -> muestra "$a"

echo 9 '`$a`'     # Comillas simples -> valor literal -> muestra `$a`

echo 10 '$($a)'   # Comillas simples -> valor literal -> muestra $($a)



echo 11 ''$a      # Comillas simples duplicadas -> en su entrecomillado no existe nada -> se consideran como si no existieran -> equivale a $a -> ver echo 2

##echo 12 ''$a'     # Comillas simples impares -> error sintáctico
                    # Las dos primeras comillas simples trabajan juntas -> en su entrecomillado no existe nada -> la última comilla simple está esperando ser cerrada por otra comilla simple

echo 13 ''$a\'    # Comillas simples duplicadas -> en su entrecomillado no existe nada -> se consideran como si no existieran -> expande $a -> escapa el carácter comilla simple -> muestra ls'

echo 14 ''$a''    # Comillas simples duplicadas -> en su entrecomillado no existe nada -> se consideran como si no existieran -> equivale a $a -> ver echo 2

echo 15 ''`$a`''  # Comillas simples duplicadas -> en su entrecomillado no existe nada -> se consideran como si no existieran -> ver echo 3

echo 16 ''$($a)'' # Comillas simples duplicadas -> en su entrecomillado no existe nada -> se consideran como si no existieran -> ver echo 4



echo 17 ""$a      # Comillas dobles duplicadas -> en su entrecomillado no existe nada -> se consideran como si no existieran -> equivale a $a -> ver echo 2

##echo 18 ""$a"     # Comillas dobles impares -> error sintáctico
                    # Las dos primeras comillas dobles trabajan juntas -> en su entrecomillado no existe nada -> la última comilla doble está esperando ser cerrada por otra comilla doble

echo 19 ""$a\"    # Comillas dobles duplicadas -> en su entrecomillado no existe nada -> se consideran como si no existieran -> expande $a -> escapa el carácter comilla doble -> muestra ls"

echo 20 ""$a""    # Comillas dobles duplicadas -> en su entrecomillado no existe nada -> se consideran como si no existieran -> equivale a $a -> ver echo 2

echo 21 ""`$a`""  # Comillas dobles duplicadas -> en su entrecomillado no existe nada ->  se consideran como si no existieran -> ver echo 3

echo 22 ""$($a)"" # Comillas dobles duplicadas -> en su entrecomillado no existe nada -> se consideran como si no existieran -> ver echo 4



##echo 23 '\''      # Comillas simples impares -> una comilla simple escapada no funciona -> consola espera cerrar la sintaxis del comando con otra comilla simple

echo 24 "\""      # Comillas dobles impares -> una comilla doble escapada -> se considera valor literal -> muestra "
