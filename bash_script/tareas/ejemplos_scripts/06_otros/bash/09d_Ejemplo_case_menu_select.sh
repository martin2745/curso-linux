#!/bin/bash

PS3='¿Opción? '
opcions=("Ver directorio actual" "Leer /tmp" "Salir")
select opcion in "${opcions[@]}"
do
  case $opcion in
    "Ver directorio actual") pwd
                             break
                             ;;
    "Leer /tmp") ls /tmp
                break
                ;;

    "Salir") break
            ;;

    *) echo "No elegiste ninguna opción válida";;
  esac
done
