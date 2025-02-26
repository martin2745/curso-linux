#!/bin/bash

# Para la shell Bash:
#
#    Con el comando test o [, es preferible usar el operador =.
#    Con [[, es preferible usar el operador ==.
#
# Pero no existen diferencias al usar el operador == con el comando
# test en lugar del operador =, y no existen diferencias al usar el
# operador = con [[.

texto1="Juan y Medio"
texto2="juan y medio"

[ "${texto1}" = "${texto2}" ] && echo "Igual" || echo "Distinto"

[[ "${texto1}" == "${texto2}" ]] && echo "Igual" || echo "Distinto"

[ "${texto1}" == "${texto2}" ]  && echo "Igual" || echo "Distinto"

[[ "${texto1}" = "${texto2}" ]] && echo "Igual" || echo "Distinto"