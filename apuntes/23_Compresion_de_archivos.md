# Compresión de archivos y directorios

## Índice

1. [Comando tar y parámetros comunes](#1-comando-tar-y-parámetros-comunes)
2. [Compresión en gzip (.gz)](#2-compresión-en-gzip-gz)
   1. [Los comandos gzip y gunzip por separado](#21-los-comandos-gzip-y-gunzip-por-separado)
   2. [Comparativa de los tres algoritmos](#22-comparativa-de-los-tres-algoritmos)
3. [Compresión en bzip2 (.bz2)](#3-compresión-en-bzip2-bz2)
4. [Compresión en xz (.xz)](#4-compresión-en-xz-xz)
5. [Otros comandos de compresión en flujo](#5-otros-comandos-de-compresión-en-flujo)
6. [Comandos zip y unzip](#6-comandos-zip-y-unzip)
7. [Comando rar](#7-comando-rar)

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
| `-k`      | (`--keep-old-files`) **No** sobrescribe los ficheros que ya existan en el destino: los conserva y avisa con un error para cada uno. No pide confirmación. |
| `-w`      | (`--interactive`) Esta sí pide confirmación por teclado para cada fichero antes de actuar. |
| `-p`      | (`--preserve-permissions`) Restaura los permisos originales. Es el comportamiento por defecto cuando extrae `root`. |
| `--exclude=PATRÓN` | Omite del paquete los ficheros que coincidan con el patrón, por ejemplo `--exclude='*.log'`. |
| `-r`      | Añade ficheros a un paquete `.tar` ya existente. No funciona sobre paquetes comprimidos. |
| `--strip-components=N` | Descarta los `N` primeros niveles de directorio al extraer. Sirve para sacar el contenido sin la carpeta que lo envuelve. |
| `-C`      | Especifica el directorio de destino final donde se va a extraer el contenido. |

> **Importante:** El flag `-f` **siempre** debe ser el último de los parámetros agrupados, ya que el argumento que lo sigue inmediatamente se tomará como el nombre del archivo. Ejemplo correcto: `tar -cvzf archivo.tar.gz`. Ejemplo incorrecto: `tar -cvfz archivo.tar.gz`.
>
> Esta segunda forma no da error, y ahí está el peligro: `tar` toma la `z` como nombre del paquete y genera un fichero llamado literalmente `z`, mientras intenta añadir `archivo.tar.gz` al contenido:
>
> ```bash
> usuario@debian:/tmp$ tar -cvfz p2.tar.gz prueba/
> tar: p2.tar.gz: Cannot stat: No such file or directory
> prueba/
> prueba/a.txt
> ```

> **Nota:** En los ejemplos de este documento aparece la forma `tar cvfz`, **sin guion**, que a primera vista parece contradecir la regla anterior. No la contradice, porque se trata de una sintaxis distinta. `tar` admite dos estilos:
>
> | Estilo | Ejemplo | Comportamiento |
> |---|---|---|
> | Antiguo, sin guion | `tar cvfz paquete.tar.gz dir/` | Las letras se leen como un grupo y los argumentos que necesiten se van tomando **en orden** de las palabras siguientes. Como aquí solo `f` requiere argumento, recibe `paquete.tar.gz` y el orden de las letras da igual. |
> | Moderno, con guion | `tar -cvzf paquete.tar.gz dir/` | Cada letra se procesa como una opción independiente y la que sigue a `-f` es su argumento, de modo que `f` **debe** ir en último lugar. |
>
> Ambos estilos funcionan, pero conviene elegir uno y no mezclarlos. La forma con guion es la habitual hoy y la que aparece en la documentación.

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

### 2.1 Los comandos gzip y gunzip por separado

Al margen de `tar`, `gzip` existe como comando independiente para comprimir **un único fichero**. Conviene conocerlo porque su comportamiento sorprende: por defecto **sustituye** el fichero original por su versión comprimida en lugar de crear una copia.

```bash
root@debian:/tmp# ls -l registro.log
-rw-r--r-- 1 root root 204800 abr 28 17:20 registro.log
root@debian:/tmp# gzip registro.log
root@debian:/tmp# ls -l registro.log*
-rw-r--r-- 1 root root 8192 abr 28 17:20 registro.log.gz
```

El fichero `registro.log` ha desaparecido. Para recuperarlo:

```bash
root@debian:/tmp# gunzip registro.log.gz
```

| Parámetro | Descripción |
|---|---|
| `-k` | (*Keep*) Conserva el fichero original en lugar de reemplazarlo. |
| `-d` | Descomprime. `gzip -d` equivale a `gunzip`. |
| `-1` a `-9` | Nivel de compresión, de más rápido a más compacto. Por defecto es `-6`. |
| `-l` | (*List*) Muestra el tamaño original, el comprimido y el porcentaje ahorrado. |
| `-t` | (*Test*) Comprueba la integridad del fichero comprimido sin extraerlo. |
| `-r` | Recorre un directorio comprimiendo **cada fichero por separado**. No crea un único paquete. |
| `-c` | Escribe el resultado por la salida estándar y no toca el original. |

> **Advertencia:** `gzip -r directorio/` no produce un fichero comprimido del directorio: comprime individualmente cada fichero que hay dentro, dejando el árbol lleno de `.gz` sueltos. Es un error muy común. Para empaquetar un directorio completo hay que usar `tar`.

> **Nota:** `bzip2`/`bunzip2` y `xz`/`unxz` funcionan igual y admiten las mismas opciones principales. Los tres pueden comprimir desde la entrada estándar con `-c`, lo que permite construir tuberías como `mysqldump base | gzip > copia.sql.gz`.

### 2.2 Comparativa de los tres algoritmos

| Algoritmo | Extensión | Flag de `tar` | Velocidad | Ratio de compresión |
|---|---|---|---|---|
| gzip | `.gz` | `-z` | Muy rápida | Moderado |
| bzip2 | `.bz2` | `-j` | Lenta | Bueno |
| xz | `.xz` | `-J` | Muy lenta | El mejor |

> **Recuerda:** El criterio de elección habitual es `gzip` para copias de seguridad diarias, donde importa el tiempo; `xz` para distribuir software o archivar a largo plazo, donde el fichero se comprime una vez y se descarga muchas. La descompresión, en cambio, es rápida en los tres casos.

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

> **Advertencia:** Conviene no confundir la `j` minúscula, que corresponde a **bzip2**, con la `J` mayúscula, que es la de **xz**. Es una fuente habitual de errores al teclear.

> **Nota:** Las versiones modernas de GNU tar detectan solas el algoritmo al extraer gracias a la cabecera del fichero, de modo que `tar xvf archivo.tar.xz` funciona sin indicar `J`. El flag sigue siendo obligatorio al **crear** el paquete, porque ahí no hay nada que detectar. En la práctica, para extraer basta con recordar `tar xvf`.

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

> **Advertencia:** Antes de extraer un paquete de procedencia ajena conviene listar su contenido con `tar tvf`. Un paquete puede contener rutas absolutas (`/etc/passwd`) o ascendentes (`../../`) y sobrescribir ficheros fuera del directorio actual. GNU tar se protege de ello descartando por defecto la barra inicial y avisando con `Removing leading '/' from member names`, pero conviene comprobarlo igualmente. La opción `-P` desactiva esa protección y no debe usarse sin un motivo claro.

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
rar a archivo.rar /carpeta/archivos
```

Para descomprimir un `.rar`:

```bash
unrar x archivo.rar
```

> **Advertencia:** `rar` no sigue el convenio habitual de Unix: sus órdenes (`a` de añadir, `x` de extraer, `l` de listar, `t` de comprobar) se escriben **sin guion delante**, igual que ocurre con la sintaxis antigua de `tar`. Escribir `rar -a` no funciona, porque `rar` esperaría una orden y encontraría un modificador.

> **Nota:** El paquete `rar` es privativo y solo se distribuye como versión de evaluación, de modo que en Debian vive en la sección `non-free`. El paquete `unrar` basta para **descomprimir**, que es lo que se necesita casi siempre.
