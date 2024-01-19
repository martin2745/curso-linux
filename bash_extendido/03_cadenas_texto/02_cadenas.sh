#!/bin/bash
# Author: Martín Gil Blanco

# Uso de cadenas

saludo="Hola"
separador=", "
destinatario="mundo"
punto="."
pregunta="¿Qué tal?"

expresion=$saludo$separador$destinatario$punto$pregunta" ¿Comó están ustedes?"

echo $expresion

# Podemos ver que no es necesario en el echo especificar "" y el espacio
# pregunta se respeta igualmente. Si hicieramos uso del operador -n de echo
# tendríamos que poner las "" ya que este operador no interpreta correctamente
# este espacio.

echo -n $saludo
# echo -n $separador
echo -n "$separador"
echo -n $pregunta
