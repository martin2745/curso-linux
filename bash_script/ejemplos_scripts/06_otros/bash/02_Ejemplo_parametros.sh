#!/bin/bash     

# Ejemplo de ejecución:
# bash Ejemplo2_parametros.sh 1 2 3 4 5 6 7 8 9 a b c 

echo "Parámetro \$0 -> Nombre del script"
echo -e "\t \$0 toma el valor $0\n"

echo "Parámetros posicionale \$1, \$2, \$3, \$4,..., \$9, \${10}, \${11}, \${12}, \${n} -> Parámetros que recibe el script como argumentos"
echo -e "\t \$1 toma el valor $1\n"
echo -e "\t \$2 toma el valor $2\n"
echo -e "\t \$3 toma el valor $3\n"
echo -e "\t \$4 toma el valor $4\n"
echo -e "\t \$5 toma el valor $5\n"
echo -e "\t \$6 toma el valor $6\n"
echo -e "\t \$7 toma el valor $7\n"
echo -e "\t \$8 toma el valor $8\n"
echo -e "\t \$9 toma el valor $9\n"
echo -e "\t \$10 toma el valor $10\n"
echo -e "\t \${10} toma el valor ${10}\n"
echo -e "\t \t \$10 es distinto a \${10}\n"
echo -e "\t \${11} toma el valor ${11}\n"
echo -e "\t \${12} toma el valor ${12}\n"
echo -e "\t \${13} toma el valor ${13}\n"
echo -e "\t \${14} toma el valor ${14}\n"
echo -e "\t \${15} toma el valor ${15}\n"

echo "Parámetro \$# -> Número total de parámetros recibidos en la ejecución del script (excluido \$0)"
echo -e "\t \$# toma el valor $#\n"

echo -e "Comprobamos el separador interno de campo IFS"
IFS=$' \t\n'
set | grep IFS
oldIFS=$IFS
echo "Parámetro \$* -> Lista completa de parámetros (excluido \$0), separados por un espacio"
echo -e "\t \$* toma el valor $*\n"

echo "Parámetro \$@ -> Lista completa de parámetros (excluido \$0), separados por un espacio"
echo -e "\t \$@ toma el valor $@\n"

echo -e "\t \$* y \$@ son equivalentes siempre que el IFS tenga como primer carácter de separación el carácter espacio. (IFS afecta a \$*)\n\n"
echo -e "\t Cambiamos el separador interno de campo IFS"
IFS='Ñ\t\n'
set | grep IFS | grep -v old
echo "Volvemos a ejecutar:"
echo -e "\t \$* toma el valor $*\n"
echo -e "\t \$@ toma el valor $@\n"
echo -e "\t Devolvemos IFS al valor original"
IFS=$oldIFS
set | grep IFS | grep -v old

echo -e "\nParámetro \$\$ -> Identificador del proceso (PID)"
echo -e "\t \$\$ toma el valor $$\n"

echo "Parámetro \$? -> El estado de salida de la ejecución del último comando, el cual puede ser correcto (valor cero) o erróneo (valor distinto de cero)"
echo -e "\t Ejecución comando pwd" 
  pwd
echo -e "\t \$? toma el valor $?\n"

echo -e "\t Ejecución comando abcabc" 
  $(abcabc)
echo -e "\t \$? toma el valor $?"
