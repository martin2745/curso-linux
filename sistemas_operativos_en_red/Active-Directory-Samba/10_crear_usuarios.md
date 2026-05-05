# 10 Crear usuarios

## Índice

1. [Introducción](#introducción)
2. [Estructura del fichero de entrada (`usuarios.csv`)](#estructura-del-fichero-de-entrada-usuarioscsv)
3. [Script de Creación (`crear-samba-users.sh`)](#script-de-creación-crear-samba-userssh)
4. [Script de Borrado (`borrar-samba-users.sh`)](#script-de-borrado-borrar-samba-userssh)

---

## Introducción

En entornos de administración de sistemas educativos o corporativos, es ineficiente crear cientos de cuentas manualmente a través de interfaces gráficas. Un proceso de enorme interés es **automatizar la creación masiva de usuarios y grupos** a partir de un archivo estandarizado como un `.csv`.

A continuación, se adjuntan los correspondientes scripts de prueba en Bash y la estructura del archivo `usuarios.csv`. 

> **Nota:** Estos scripts son una versión fundamental y son mejorables. Podrían escalarse fácilmente para incluir la creación automática de Unidades Organizativas (OUs) en `Samba`, configuración de atributos específicos (como perfiles móviles, caducidades de cuenta) o cualquier particularidad en función de la organización que estemos administrando.

---

## Estructura del fichero de entrada (`usuarios.csv`)

El fichero a procesar debe contener las cabeceras en la primera línea. Las columnas representan al usuario, su contraseña inicial, la ruta de la shell (para clientes Linux vinculados) y el grupo organizativo principal (ej. la clase o departamento).

```bash
root@dc:~/scripts# cat usuarios.csv
usuario,password,shell,grupo
juan.perez,abc123.,/bin/bash,clase1
maria.gomez,abc123.,/bin/bash,clase1
luis.rodriguez,abc123.,/bin/bash,clase2
ana.martinez,abc123.,/bin/bash,clase2
carlos.sanchez,abc123.,/bin/bash,clase1
```

---

## Script de Creación (`crear-samba-users.sh`)

Este script lee cada registro del CSV. Primero comprueba y crea el grupo si no existe, y luego crea al usuario con su contraseña asignándolo posteriormente a dicho grupo.

```bash
#!/bin/bash

## VARIABLES
ARCHIVO='usuarios.csv'
ARCHIVOTEMPORAL=$(mktemp)
ARCHIVODELOG='samba_usuarios.log'
FECHA=$(date)

## main()
clear
echo "--- Inicio del proceso: ${FECHA} ---" >> ${ARCHIVODELOG}

# Saltamos la cabecera y guardamos el resto en un fichero temporal
tail -n +2 $ARCHIVO > ${ARCHIVOTEMPORAL}

while read LINEA
do
  # Limpieza de caracteres de retorno de carro (vital por si el CSV fue creado en Windows)
  LINEA=$(echo ${LINEA} | tr -d '\r')

  # Extracción de campos usando coma como delimitador
  USUARIO=$(echo ${LINEA} | cut -d',' -f1)
  PASSWORD=$(echo ${LINEA} | cut -d',' -f2)
  SHELL_PATH=$(echo ${LINEA} | cut -d',' -f3)
  GRUPO=$(echo ${LINEA} | cut -d',' -f4)

  # 1. Gestión del GRUPO
  # Buscamos si el grupo existe en la lista de grupos de Samba
  samba-tool group list | grep -x ${GRUPO} >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "El grupo ${GRUPO} no existe. Creando..." >> ${ARCHIVODELOG}
    samba-tool group add ${GRUPO} >> ${ARCHIVODELOG} 2>&1
  fi

  # 2. Gestión del USUARIO
  # Buscamos si el usuario existe en la lista de usuarios de Samba
  samba-tool user list | grep -x ${USUARIO} >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    # El usuario no existe, procedemos a crearlo
    # Nota: El flag --login-shell requiere que el AD tenga soporte y configuración para RFC2307
    samba-tool user create ${USUARIO} ${PASSWORD} --login-shell=${SHELL_PATH} >> ${ARCHIVODELOG} 2>&1

    if [ $? -eq 0 ]; then
        # Si se creó correctamente, lo añadimos como miembro de su grupo
        samba-tool group addmembers ${GRUPO} ${USUARIO} >> ${ARCHIVODELOG} 2>&1
        echo "[OK] Usuario ${USUARIO} creado y añadido a ${GRUPO}"
    else
        echo "[ERROR] Falló la creación de ${USUARIO}" >> ${ARCHIVODELOG}
    fi
  else
    echo "El usuario ${USUARIO} ya existe en el sistema AD" >> ${ARCHIVODELOG}
  fi

done < ${ARCHIVOTEMPORAL}

# Limpieza del sistema
rm -f ${ARCHIVOTEMPORAL}
echo "Proceso finalizado. Revisa ${ARCHIVODELOG}"
```

> **Recuerda:** El comando nativo para añadir un grupo en `samba-tool` es `samba-tool group add`.

---

## Script de Borrado (`borrar-samba-users.sh`)

Este script realiza el proceso inverso (depuración o limpieza). Borra a los usuarios indicados en el archivo CSV y, opcionalmente, intenta borrar los grupos.

```bash
#!/bin/bash

## VARIABLES
ARCHIVO='usuarios.csv'
ARCHIVOTEMPORAL=$(mktemp)
ARCHIVODELOG='borrado_usuarios.log'
FECHA=$(date)

## main()
clear
echo "--- Inicio del proceso de borrado: ${FECHA} ---" >> ${ARCHIVODELOG}

# Saltamos la cabecera y guardamos en el fichero temporal
tail -n +2 $ARCHIVO > ${ARCHIVOTEMPORAL}

while read LINEA
do
  # Limpieza de caracteres de retorno de carro
  LINEA=$(echo ${LINEA} | tr -d '\r')

  # Extracción de campos (solo precisamos usuario y grupo para borrar)
  USUARIO=$(echo ${LINEA} | cut -d',' -f1)
  GRUPO=$(echo ${LINEA} | cut -d',' -f4)

  # 1. Gestión del USUARIO (Borrado)
  samba-tool user list | grep -x ${USUARIO} >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    samba-tool user delete ${USUARIO} >> ${ARCHIVODELOG} 2>&1
    if [ $? -eq 0 ]; then
        echo "[OK] Usuario ${USUARIO} eliminado correctamente."
    else
        echo "[ERROR] Falló el borrado del usuario ${USUARIO}." >> ${ARCHIVODELOG}
    fi
  else
    echo "El usuario ${USUARIO} no existe en el sistema, no se puede borrar." >> ${ARCHIVODELOG}
  fi

  # 2. Gestión del GRUPO (Borrado)
  # Intentamos borrar el grupo solo si existe en Samba
  samba-tool group list | grep -x ${GRUPO} >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    # Intentamos eliminar el grupo. Fallará automáticamente si todavía contiene miembros (seguridad de Samba).
    samba-tool group delete ${GRUPO} >> ${ARCHIVODELOG} 2>&1
    if [ $? -eq 0 ]; then
        echo "[OK] Grupo ${GRUPO} eliminado (ya había quedado vacío)." >> ${ARCHIVODELOG}
    else
        # No mostramos el error por pantalla para no ensuciar la salida de consola, 
        # ya que es el comportamiento normal y esperado si quedan usuarios vinculados a ese grupo. Se registra en el log.
        echo "[INFO] No se eliminó el grupo ${GRUPO} (probablemente todavía tenga miembros asociados)." >> ${ARCHIVODELOG}
    fi
  fi

done < ${ARCHIVOTEMPORAL}

# Limpieza del sistema
rm -f ${ARCHIVOTEMPORAL}
echo "Proceso de borrado finalizado. Revisa ${ARCHIVODELOG}"
```

> **Importante:** Por seguridad, `samba-tool group delete` se denegará de forma nativa si el grupo todavía posee miembros dentro de Active Directory, lo cual previene dejar a usuarios sin su grupo primario o con permisos huérfanos.
