#!/bin/bash

# Engade unha liña no ficheiro .bashrc do usuario para que o prompt que lle apareza
# sexa “Bos dias, loginUsuario >”

# export PS1="Bos dias, \u> "
export PS1="Bos dias, ${USER}> "