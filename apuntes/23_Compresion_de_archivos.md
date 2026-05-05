# Compresión de archivos y directorios

## Índice

1. [Comando tar y parámetros comunes](#1-comando-tar-y-parámetros-comunes)
2. [Compresión en gzip (.gz)](#2-compresión-en-gzip-gz)
3. [Compresión en bzip2 (.bz2)](#3-compresión-en-bzip2-bz2)
4. [Compresión en xz (.xz)](#4-compresión-en-xz-xz)
5. [Otros comandos de compresión en flujo (zcat, bzcat...)](#5-otros-comandos-de-compresión-en-flujo)
6. [Comandos zip y unzip](#6-comandos-zip-y-unzip)
7. [Comando rar](#7-comando-rar)

---

El comando `tar` (_tape archive_) se utiliza de forma estandarizada en sistemas Linux y Unix para crear, listar, extraer y manipular archivos y directorios empaquetados en un solo archivo resultante.

---

## 1. Comando tar y parámetros comunes

A diferencia de `zip` que empaqueta y comprime en el mismo paso internamente, en Linux el estándar tradicional consiste primero en **empaquetar** múltiples archivos en uno solo (con `tar`), y luego pasar ese archivo por un algoritmo de **compresión** (`gzip`, `bzip2`, `xz`). `tar` es capaz de realizar ambos pasos transparentemente mediante flags.

| Parámetro | Descripción |
|-----------|-------------|
| `-c`      | Crea (Create) un nuevo archivo empaquetado. |
| `-x`      | Extrae (eXtract) los archivos de un paquete `.tar` o comprimido. |
| `-t`      | Lista el contenido interno del archivo sin extraerlo. |
| `-v`      | Muestra información detallada (verbose) de cada archivo procesado. |
| `-f`      | Especifica el nombre del archivo final a generar, manipular o extraer. |
| `-z`      | Utiliza el algoritmo rápido **gzip** (`.tar.gz` o `.tgz`). |
| `-j`      | Utiliza el algoritmo intermedio **bzip2** (`.tar.bz2`). |
| `-J`      | Utiliza el algoritmo de alta compresión **xz** (`.tar.xz`). |
| `-k`      | (`--keep-old-files`) Pide confirmación si el archivo a extraer ya existe. |
| `-C`      | Especifica el directorio de destino final donde se va a extraer el contenido. |

> **Importante:** El flag `-f` **siempre** debe ser el último de los parámetros agrupados, ya que el argumento que lo sigue inmediatamente se tomará como el nombre del archivo. Ejemplo correcto: `tar -cvzf archivo.tar.gz`. Ejemplo incorrecto: `tar -cvfz archivo.tar.gz`.

---

## 2. Compresión en gzip (.gz)

Para este bloque crearemos primero un directorio `prueba` y generaremos de golpe 10 archivos dentro mediante un bucle de Bash:

```bash
root@debian:/tmp# mkdir prueba
root@debian:/tmp# for i in $(seq 1 10); do echo "Archivo $i" > prueba/archivo$i.txt; done
```

Empaquetamos y comprimimos a formato `.gz` con la bandera `z`:

```bash
root@debian:/tmp# tar cvfz prueba.tar.gz prueba/
prueba/
prueba/archivo2.txt
prueba/archivo5.txt
...
```

> **Nota:** La extensión `.tar.gz` y su forma acortada `.tgz` son equivalentes.

Para listar el contenido del archivo sin descomprimirlo usamos la opción de test `t`:

```bash
root@debian:/tmp# tar tvfz prueba.tar.gz
drwxr-xr-x root/root         0 2025-04-28 17:08 prueba/
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo2.txt
...
```

Para extraer el archivo, empleamos `x`. Si no se especifica ruta, lo extraerá en la ruta activa actual (`$PWD`):

```bash
root@debian:/tmp# tar xvfz prueba.tar.gz
```

> **Recuerda:** Es muy habitual extraer archivos en otra ubicación concreta usando el parámetro `-C` (en mayúsculas):
> ```bash
> root@debian:/tmp# tar xvfz prueba.tar.gz -C /root
> ```

---

## 3. Compresión en bzip2 (.bz2)

Este algoritmo tarda un poco más en comprimir que gzip, pero el archivo resultante suele ser más pequeño. La sintaxis es la misma pero reemplazando la `z` por la `j`.

Comprimimos el directorio en `prueba.tar.bz2`:

```bash
root@debian:/tmp# tar cvfj prueba.tar.bz2 prueba/
```

Visualizamos contenido y descomprimimos:

```bash
root@debian:/tmp# tar tvfj prueba.tar.bz2
root@debian:/tmp# tar xvfj prueba.tar.bz2
```

---

## 4. Compresión en xz (.xz)

Este es el algoritmo de compresión nativo de Linux que mayor ratio de compresión ofrece, a costa de requerir mucha mayor CPU durante la creación del archivo. Utiliza el flag de descompresión con `J` mayúscula, o dependiendo de la versión de `tar`, detectará automáticamente la cabecera.

Comprimir directorio a formato `xz`:

```bash
root@debian:/tmp# tar cvfJ prueba.tar.xz prueba/
```

> **Nota:** En el contenido original aparece `cvfj` para `xz`, pero la `j` minúscula corresponde a bzip2. Para `xz` se usa la `J` mayúscula. Las versiones modernas de GNU tar no requieren el flag de compresión para extraer (`tar xvf archivo.tar.xz` detectará el algoritmo transparente).

---

## 5. Otros comandos de compresión en flujo

A menudo necesitamos visualizar o filtrar archivos de texto que están comprimidos, y extraerlos en el disco físicamente sería perder espacio. Para eso existen las utilidades que leen el contenido de archivos comprimidos "al vuelo":

| Comando | Compresor | Finalidad |
| ------- | --------- | --------- |
| `zcat`  | gzip      | Imprime todo el contenido de un archivo `.gz` en texto plano por pantalla. |
| `zless` | gzip      | Muestra el texto de un archivo `.gz` paginándolo (similar a usar `less`). |
| `bzcat` | bzip2     | Imprime el texto de archivos `.bz2`. |
| `bzless`| bzip2     | Pagina el texto de archivos `.bz2`. |
| `xzcat` | xz        | Imprime el texto de archivos `.xz`. |
| `xzless`| xz        | Pagina el texto de archivos `.xz`. |

Ejemplo volcando a pantalla el contenido de un backup comprimido de registros (log):

```bash
root@debian:/tmp# zcat prueba.tar.gz
```

---

## 6. Comandos zip y unzip

Aunque no es un formato POSIX tradicional, `.zip` se utiliza masivamente para la compartición con otros sistemas como Windows. Es necesario instalarlo manualmente muchas veces: `sudo apt install zip unzip -y`.

Comprimir recursivamente un directorio (requiere `-r` de recursivo):

```bash
root@debian:/tmp# zip -r prueba.zip prueba
  adding: prueba/ (stored 0%)
```

Descomprimir un `.zip`:

```bash
root@debian:/tmp# unzip prueba.zip
Archive:  prueba.zip
   creating: prueba/
 extracting: prueba/arch9.txt
...
```

> **Nota:** Si queremos indicar una ruta de destino diferente con `unzip` no usamos `-C` como en `tar`, sino el parámetro `-d` indicando el directorio destino final:
> ```bash
> root@debian:/tmp# unzip -d /root prueba.zip
> ```

---

## 7. Comando rar

El uso del compresor privativo `rar` no es habitual en servidores Linux por defecto, pero se utiliza de la siguiente forma una vez instalados los paquetes `rar` y `unrar`:

Para comprimir un archivo o directorio a `.rar`:

```bash
rar -a archivo.rar /carpeta/archivos
```

Para descomprimir un `.rar`:

```bash
rar -x archivo.rar
```
