# 10 Crear usuarios

Un proceso interesante es automatizar la creación de usuarios y grupos a partir de un csv.

A continuación, se adjuntan los correspondientes scripts de prueba y archivo.csv. Estos scripts son mejorables y podrían incluir la creación de unidades organizativas o cualquier particularidad en función de la organización que estemos administrando.

## usuarios.csv

```bash
root@dc:~/scripts# cat usuarios.csv
usuario,password,shell,grupo
juan.perez,abc123.,/bin/bash,clase1
maria.gomez,abc123.,/bin/bash,clase1
luis.rodriguez,abc123.,/bin/bash,clase2
ana.martinez,abc123.,/bin/bash,clase2
carlos.sanchez,abc123.,/bin/bash,clase1
```

## crear-samba-users.sh

```bash
#!/bin/bash

##VARIABLES
ARCHIVO='usuarios.csv'
ARCHIVOTEMPORAL=$(mktemp)
ARCHIVODELOG='samba_usuarios.log'
FECHA=$(date)

##main()
clear
echo "--- Inicio del proceso: ${FECHA} ---" >> ${ARCHIVODELOG}

# Saltamos la cabecera y guardamos en el temporal
tail -n +2 $ARCHIVO > ${ARCHIVOTEMPORAL}

while read LINEA
do
  # Limpieza de caracteres de retorno de carro (por si el CSV viene de Windows)
  LINEA=$(echo ${LINEA} | tr -d '\r')

  # Extracción de campos usando coma como delimitador
  USUARIO=$(echo ${LINEA} | cut -d',' -f1)
  PASSWORD=$(echo ${LINEA} | cut -d',' -f2)
  SHELL_PATH=$(echo ${LINEA} | cut -d',' -f3)
  GRUPO=$(echo ${LINEA} | cut -d',' -f4)

  # 1. Gestión del GRUPO
  # Buscamos si el grupo existe en la lista de grupos de samba
  samba-tool group list | grep -x ${GRUPO} >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "El grupo ${GRUPO} no existe. Creando..." >> ${ARCHIVODELOG}
    samba-tool group create ${GRUPO} >> ${ARCHIVODELOG} 2>&1
  fi

  # 2. Gestión del USUARIO
  # Buscamos si el usuario existe en la lista de usuarios de samba
  samba-tool user list | grep -x ${USUARIO} >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    # El usuario no existe, procedemos a crearlo
    # Nota: --login-shell requiere que el AD tenga soporte RFC2307
    samba-tool user create ${USUARIO} ${PASSWORD} --login-shell=${SHELL_PATH} >> ${ARCHIVODELOG} 2>&1

    if [ $? -eq 0 ]; then
        # Si se creó bien, lo añadimos al grupo
        samba-tool group addmembers ${GRUPO} ${USUARIO} >> ${ARCHIVODELOG} 2>&1
        echo "[OK] Usuario ${USUARIO} creado y añadido a ${GRUPO}"
    else
        echo "[ERROR] Falló la creación de ${USUARIO}" >> ${ARCHIVODELOG}
    fi
  else
    echo "El usuario ${USUARIO} ya existe en el sistema AD" >> ${ARCHIVODELOG}
  fi

done<${ARCHIVOTEMPORAL}

# Limpieza
rm -f ${ARCHIVOTEMPORAL}
echo "Proceso finalizado. Revisa ${ARCHIVODELOG}"
```

## borrar-samba-users.sh

```bash
#!/bin/bash

##VARIABLES
ARCHIVO='usuarios.csv'
ARCHIVOTEMPORAL=$(mktemp)
ARCHIVODELOG='borrado_usuarios.log'
FECHA=$(date)

##main()
clear
echo "--- Inicio do proceso de borrado: ${FECHA} ---" >> ${ARCHIVODELOG}

# Saltamos a cabeceira e gardamos no temporal
tail -n +2 $ARCHIVO > ${ARCHIVOTEMPORAL}

while read LINEA
do
  # Limpeza de caracteres de retorno de carro
  LINEA=$(echo ${LINEA} | tr -d '\r')

  # Extracción de campos (só precisamos usuario e grupo para borrar)
  USUARIO=$(echo ${LINEA} | cut -d',' -f1)
  GRUPO=$(echo ${LINEA} | cut -d',' -f4)

  # 1. Xestión do USUARIO (Borrado)
  samba-tool user list | grep -x ${USUARIO} >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    samba-tool user delete ${USUARIO} >> ${ARCHIVODELOG} 2>&1
    if [ $? -eq 0 ]; then
        echo "[OK] Usuario ${USUARIO} eliminado correctamente."
    else
        echo "[ERRO] Fallou o borrado do usuario ${USUARIO}." >> ${ARCHIVODELOG}
    fi
  else
    echo "O usuario ${USUARIO} non existe no sistema, non se pode borrar." >> ${ARCHIVODELOG}
  fi

  # 2. Xestión do GRUPO (Borrado)
  # Tentamos borrar o grupo só se existe
  samba-tool group list | grep -x ${GRUPO} >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    # Tentamos eliminar o grupo. Fallará se aínda ten membros.
    samba-tool group delete ${GRUPO} >> ${ARCHIVODELOG} 2>&1
    if [ $? -eq 0 ]; then
        echo "[OK] Grupo ${GRUPO} eliminado (xa quedou baleiro)." >> ${ARCHIVODELOG}
    else
        # Non amosamos erro por pantalla para non ensuciar, xa que é normal
        # que falle se quedan usuarios doutras liñas. Vai ao log.
        echo "[INFO] Non se eliminou o grupo ${GRUPO} (probablemente aínda teña membros)." >> ${ARCHIVODELOG}
    fi
  fi

done<${ARCHIVOTEMPORAL}

rm -f ${ARCHIVOTEMPORAL}
echo "Proceso de borrado rematado. Revisa ${ARCHIVODELOG}"
```
