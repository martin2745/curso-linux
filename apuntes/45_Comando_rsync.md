# Comando rsync

## Índice

1. [Sintaxis básica y primer ejemplo](#1-sintaxis-básica-y-primer-ejemplo)
2. [La barra final del origen: el detalle que más confunde](#2-la-barra-final-del-origen-el-detalle-que-más-confunde)
3. [Opciones esenciales](#3-opciones-esenciales)
4. [rsync sobre la red, a través de SSH](#4-rsync-sobre-la-red-a-través-de-ssh)
5. [Copias de seguridad incrementales con --link-dest](#5-copias-de-seguridad-incrementales-con---link-dest)
6. [La opción --delete y sus riesgos](#6-la-opción---delete-y-sus-riesgos)
7. [rsync frente a cp y tar](#7-rsync-frente-a-cp-y-tar)

---

## 1. Sintaxis básica y primer ejemplo

La forma general del comando es `rsync [opciones] ORIGEN DESTINO`. Tanto el origen como el destino pueden ser rutas locales o remotas.

La copia local más habitual sincroniza un directorio en otro. La opción `-a` es la que casi siempre se usa, y `-v` muestra lo que va haciendo:

```bash
usuario@debian:~$ rsync -av /home/usuario/documentos/ /mnt/backup/documentos/
sending incremental file list
informe.odt
fotos/vacaciones.jpg
notas.txt

sent 4.812.334 bytes  received 58 bytes  9.624.784,00 bytes/sec
total size is 4.810.921  speedup is 1,00
```

Si se vuelve a ejecutar el mismo comando sin haber cambiado nada, `rsync` compara ambos lados, comprueba que ya están sincronizados y no transfiere nada:

```bash
usuario@debian:~$ rsync -av /home/usuario/documentos/ /mnt/backup/documentos/
sending incremental file list

sent 1.234 bytes  received 12 bytes  2.492,00 bytes/sec
total size is 4.810.921  speedup is 3.860,29
```

Ese `speedup` altísimo es precisamente lo que hace valioso a `rsync`: la segunda copia apenas ha movido datos.

---

## 2. La barra final del origen: el detalle que más confunde

Antes de seguir con las opciones hay que dominar un detalle de `rsync` que causa más errores que ningún otro: la **barra `/` al final de la ruta de origen** cambia el resultado por completo.

- **Con barra final** (`origen/`): copia el **contenido** del directorio dentro del destino.
- **Sin barra final** (`origen`): copia el **directorio en sí** dentro del destino, creándolo dentro.

El siguiente par de ejemplos lo deja claro:

```bash
usuario@debian:~$ rsync -a /datos/ /backup/
# Resultado: el CONTENIDO de /datos aparece directamente en /backup/
#   /backup/fichero1.txt, /backup/fichero2.txt ...

usuario@debian:~$ rsync -a /datos /backup/
# Resultado: se crea /backup/datos/ con el contenido dentro
#   /backup/datos/fichero1.txt, /backup/datos/fichero2.txt ...
```

> **Importante:** Esta diferencia es la fuente de error número uno con `rsync`. Antes de lanzar una copia conviene tener claro cuál de los dos comportamientos se quiere, y en caso de duda comprobarlo con la opción `--dry-run` que se explica en el apartado siguiente. La barra final del **destino**, en cambio, no tiene efecto y se suele poner por costumbre.

---

## 3. Opciones esenciales

| Opción | Descripción |
|---|---|
| `-a` | (*Archive*) El modo de copia habitual. Equivale a `-rlptgoD`: copia de forma recursiva y **conserva** permisos, propietario, grupo, fechas y enlaces simbólicos. Es lo que se quiere casi siempre para una copia de seguridad fiel. |
| `-v` | (*Verbose*) Muestra los ficheros que se van transfiriendo. |
| `-z` | (*Compress*) Comprime los datos durante la transferencia. Útil por red, inútil (y contraproducente) en copias locales. |
| `-P` | Muestra una barra de progreso por fichero y permite **reanudar** transferencias interrumpidas. |
| `-n` | (*Dry-run*) **Simula** la operación sin copiar nada. Imprescindible antes de cualquier copia delicada. |
| `--delete` | Borra en el destino lo que ya no existe en el origen, dejando ambos **idénticos**. |
| `--exclude=PATRÓN` | Excluye de la copia lo que coincida con el patrón, por ejemplo `--exclude='*.tmp'`. |

> **Recuerda:** La combinación `-avz` es la más frecuente para copias por red, y `-av` para copias locales. Añadir siempre `-n` la primera vez que se ejecuta un comando nuevo permite ver qué haría **antes** de que lo haga, lo que ahorra sustos.

---

## 4. rsync sobre la red, a través de SSH

La verdadera potencia de `rsync` aparece al copiar entre máquinas. Cuando el origen o el destino tienen la forma `usuario@host:/ruta`, `rsync` establece automáticamente una conexión **SSH** y transfiere los datos cifrados por ella, aprovechando toda la configuración de SSH del documento 34 (claves, alias de `~/.ssh/config`, puertos).

Copia local hacia un servidor remoto (subida):

```bash
usuario@debian:~$ rsync -avz /var/www/ admin@192.168.1.10:/var/www/
```

Copia desde un servidor remoto hacia la máquina local (descarga):

```bash
usuario@debian:~$ rsync -avz admin@192.168.1.10:/var/www/ /var/www/
```

Si el servidor SSH no escucha en el puerto estándar, se indica con la opción `-e`:

```bash
usuario@debian:~$ rsync -avz -e "ssh -p 2222" /datos/ admin@servidor:/datos/
```

> **Nota:** Como `rsync` sobre red usa SSH, hereda su autenticación. Si se han configurado claves SSH (documento 34), la copia se realiza sin pedir contraseña, lo que es imprescindible para automatizarla con `cron`. Y si se ha definido un alias en `~/.ssh/config`, se puede usar directamente: `rsync -avz /datos/ servidor:/datos/`.

---

## 5. Copias de seguridad incrementales con --link-dest

Aquí es donde `rsync` se convierte en una herramienta de copia de seguridad de nivel profesional. La opción `--link-dest` permite hacer copias que parecen completas pero apenas ocupan espacio: los ficheros que **no** han cambiado desde la copia anterior no se copian de nuevo, sino que se enlazan a ella mediante **enlaces duros** (documento 03).

El resultado es que cada copia diaria es un directorio con la foto completa del sistema en ese día, navegable de forma independiente, pero en disco solo se almacenan una vez los ficheros que se repiten. Es exactamente el mecanismo por el que preguntan los cuestionarios de LPIC al hablar de enlaces duros y copias de seguridad.

Un guion de copia diaria con esta técnica tendría esta forma:

```bash
#!/bin/bash
ORIGEN="/datos/"
DESTINO="/backup/$(date +%F)"          # carpeta con la fecha de hoy
ANTERIOR="/backup/ultimo"              # enlace a la copia de ayer

rsync -av --delete --link-dest="$ANTERIOR" "$ORIGEN" "$DESTINO"

rm -f "$ANTERIOR"
ln -s "$DESTINO" "$ANTERIOR"           # 'ultimo' pasa a apuntar a la de hoy
```

Tras varios días, el directorio `/backup` contiene una carpeta por fecha, cada una con el estado completo de ese día:

```bash
root@debian:~# du -sh /backup/*
2,1G    /backup/2026-09-16
15M     /backup/2026-09-17
8,0M    /backup/2026-09-18
```

La primera copia ocupa el tamaño real (2,1 GB); las siguientes solo ocupan lo que ha cambiado cada día, porque el resto son enlaces duros a la primera.

> **Recuerda:** Este método, combinado con una tarea de `cron` que lo ejecute cada noche (documento 35), constituye un sistema de copias de seguridad incremental completo y muy eficiente, hecho solo con herramientas estándar de Linux. Es la base sobre la que funcionan utilidades de backup muy conocidas como *rsnapshot* o *Time Machine*.

---

## 6. La opción --delete y sus riesgos

La opción `--delete` hace que el destino quede **idéntico** al origen, lo que implica **borrar** en el destino todo lo que ya no exista en el origen. Es necesaria para que una copia de seguridad refleje también los ficheros eliminados, pero es igualmente la opción más peligrosa de `rsync`.

El riesgo se combina con el detalle de la barra final del apartado 2: si se equivoca el origen o se invierten origen y destino en un comando con `--delete`, se puede vaciar el directorio equivocado en un instante.

```bash
# Peligroso si el origen esta vacio o mal escrito:
# vaciaria por completo /backup/importante/
usuario@debian:~$ rsync -av --delete /origen/vacio/ /backup/importante/
```

> **Advertencia:** Con `--delete`, ejecutar siempre primero el comando con `-n` (*dry-run*) para ver exactamente qué ficheros se borrarían **antes** de borrarlos de verdad. Es una regla que no conviene saltarse nunca, porque `rsync` no envía nada a la papelera: lo que borra, lo borra de forma inmediata y definitiva.

```bash
usuario@debian:~$ rsync -avn --delete /datos/ /backup/datos/
# Revisar la lista de lo que se transferiria y se borraria.
# Solo si es correcta, repetir el comando sin la 'n'.
```

---

## 7. rsync frente a cp y tar

Para cerrar, conviene situar `rsync` frente a las otras dos herramientas de copia que ya se han visto, porque cada una tiene su terreno:

| Herramienta | Cuándo usarla |
|---|---|
| `cp` | Copias puntuales y sencillas dentro de la misma máquina, sin necesidad de red ni de detectar cambios. |
| `tar` | Empaquetar un conjunto de ficheros en un **único archivo** comprimido, por ejemplo para archivarlo o distribuirlo (documento 23). |
| `rsync` | **Sincronizar** directorios, especialmente de forma repetida o entre máquinas: copias de seguridad, réplicas de un sitio web, despliegues. |

> **Nota:** `rsync` y `tar` no son rivales, sino complementarios. Una estrategia de copia habitual combina ambos: `rsync` mantiene una réplica sincronizada y rápida para la recuperación del día a día, mientras que un `tar` periódico genera un archivo comprimido y autónomo para el almacenamiento a largo plazo o fuera de las instalaciones.
