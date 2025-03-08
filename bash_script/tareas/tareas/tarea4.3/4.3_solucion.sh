#!/bin/bash
if [[ $# -ne 2 ]]
then 
  echo "Uso: ./$0 -i|-e archivo"
  exit
fi

if [[ $1 == "-i" ]]
then
  if [[ ! -f $2 ]] #Compruebo si el archivo es regular
  then
    echo "$2 no existe o no es un archivo regular"
    exit
  elif [[ ! -r $2 ]] #Compruebo si se puede leer
  then
    echo "$2 no tiene permiso de lectura"
    exit
  else
    primera=1
    while IFS= read -r line
    do
      if [[ $primera -eq 1 ]] #Saltamos la primera línea
      then
        primera=0
        continue
      fi
      # Nota: todo este if es innecesario si hacemos la alternativa que hay después del done, cortesía de un compañero vuestro.

      usuario=$(echo $line | tr -d '"' | cut -d ',' -f1) #Variable usuario: valor primera columna.
      PASSWORD=$(echo $line | tr -d '"' | cut -d ',' -f2) #Variable PASSWORD: valor segunda columna.
      nombre=$(echo $line | tr -d '"' | cut -d ',' -f3) #Variable nombre: valor tercera columna.
      directorio=$(echo $line | tr -d '"' | cut -d ',' -f4) #Variable directorio: valor cuarta columna.
      consola=$(echo $line | tr -d '"' | cut -d ',' -f5) #Variable consola: valor quinta columna.

      sudo useradd -m -d $directorio -c "$nombre" -s $consola $usuario #Comando para crear los usuarios cifrando la PASSWORD
      echo $usuario:$PASSWORD | sudo chpasswd
    done < $2
    # alternativa para no tener que poner el if que comprueba la primera línea: done < <(tail -n +2 $2)
  fi
elif [[ $1 == "-e" ]]
then
  if [[ ! -e $2 ]]
  then 
    echo "\"USUARIO\",\"PASSWORD\",\"NOMBRE\",\"CONSOLA\",\"HOME\"" > $2
    getent passwd | awk -F':' '{print "\""$1"\""",""\"""?""\""",""\""$5"\""",""\""$7"\""",""\""$6"\""}' >> $2
  else
    echo "Error: el archivo ya existe"
  fi
else
  echo "Opción inválida: $1" 
  echo "Uso: ./$0 -i|-e archivo"
fi
