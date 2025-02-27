#!/bin/bash             

i=1                     # Definimos la variable i con valor 1.
while [ $i -le 10 ]     # Comienza el bucle contador donde la variable i toma el valor de 1 a 10: Mientras i sea menor o igual a 10
do                      # hacer
    echo "Valor de i: $i" # Muestra el valor de la variable i para cada valor del bucle, siendo el primer valor 1
    i=$(($i+1))         # Aumenta una unidad al valor anterior, si era 1, entonces ahora el valor es 2
done                    # hecho

echo -------------------
sleep 3
echo -------------------

# Creación de archivo file.csv
cat > file.csv <<EOF
user;contrasinal;bash;uid;gid
user1;abc123.;false;1051;1051
user2;abc123.;bash;1052;1052
user3;abc123.;bash;1053;1053
user4;abc123.;false;1054;1054
EOF

while read LINE         # Comienza el bucle para recorrer cada línea (LINE) del archivo
do                      # hacer
    echo $LINE          # Muestra el valor de la variable LINE, siendo el primer valor la primera línea del archivo llamado a recorrer el bucle
    sleep 2             # Espera 2 segundos antes de continuar con el bucle
done < file.csv         # hecho y llamada al archivo para recorrer el bucle


echo -------------------
sleep 3
echo -------------------

cat file.csv | while read LINE         # Llamada al archivo y comienza el bucle para recorrer cada línea (LINE) del archivo
do                                     # hacer
    echo $LINE                         # Muestra el valor de la variable LINE, siendo el primer valor la primera línea del archivo llamado a recorrer el bucle
    sleep 2                            # Espera 2 segundos antes de continuar con el bucle
done                                   # hecho
