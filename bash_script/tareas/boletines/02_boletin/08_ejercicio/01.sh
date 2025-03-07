#!/bin/bash

# Añadir una línea en el archivo .bashrc del usuario para que el prompt que le aparezca
# sea “Buenos días, loginUsuario >”

# export PS1="Buenos días, \u> "
export PS1="Buenos días, ${USER}> "
