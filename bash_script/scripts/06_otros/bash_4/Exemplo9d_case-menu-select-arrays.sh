#!/bin/bash

PS3='Opción? '
opcions=("Ver directorio actual" "Ler /tmp" "Saír")
select opcion in "${opcions[@]}"
do
  case $opcion in
    "Ver directorio actual") pwd
                             break
                             ;;
    "Ler /tmp") ls /tmp
                break
                ;;

    "Saír") break
            ;;

    *) echo "Non elixiches ningunha opción válida";;
  esac
done
