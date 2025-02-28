#!/bin/bash

# Escribir o comando que mostre por pantalla cantos ficheiros e subdirectorios do
# directorio actual conteñen no seu nome a letra “b”

find . -iname "*b*" -maxdepth 1 2>/dev/null | wc -l