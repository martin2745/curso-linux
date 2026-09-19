# Comando head y tail

## Índice

1. [Comando head](#1-comando-head)
   1. [Sintaxis básica](#11-sintaxis-básica)
   2. [Opciones comunes](#12-opciones-comunes)
   3. [Ejemplos](#13-ejemplos)
2. [Comando tail](#2-comando-tail)
   1. [Sintaxis básica](#21-sintaxis-básica)
   2. [Opciones comunes](#22-opciones-comunes)
   3. [Ejemplos](#23-ejemplos)
   4. [Uso avanzado: el operador de compensación (`+`)](#24-uso-avanzado-el-operador-de-compensación-)
3. [Combinación de head y tail](#3-combinación-de-head-y-tail)

---

## 1. Comando head

El comando `head` ("cabeza") se utiliza para mostrar las primeras líneas de uno o más archivos directamente por la salida estándar. Por defecto, si no se le especifican parámetros adicionales, muestra las primeras 10 líneas. Es extremadamente útil para inspeccionar rápidamente el contenido, estructura o cabeceras de grandes conjuntos de datos.

### 1.1 Sintaxis básica

```bash
head [OPCIÓN]... [ARCHIVO]...
```

### 1.2 Opciones comunes

| Parámetro / Opción | Descripción |
|--------------------|-------------|
| `-n K`, `--lines=K`| Muestra estrictamente las primeras `K` líneas del archivo. Por ejemplo, `head -n 5 archivo.txt` volcará solo las primeras 5 líneas. |
| `-c K`, `--bytes=K`| Muestra los primeros `K` bytes del archivo en lugar de procesar saltos de línea. Por ejemplo, `head -c 100 archivo.txt` muestra los primeros 100 bytes. |
| `-q`, `--quiet`, `--silent` | No imprime la cabecera con el nombre del archivo cuando se trabaja con múltiples archivos de forma simultánea. |
| `-v`, `--verbose`  | Siempre imprime una cabecera con el nombre del archivo para separar los contenidos en la terminal. |
| `-n -K` | Con el número precedido de un signo menos, muestra **todo el archivo excepto las últimas `K` líneas**. Es la forma habitual de descartar un pie de página o una línea de totales. |
| `-z`, `--zero-terminated` | Considera que las líneas terminan en el byte nulo `\0` en lugar de en salto de línea. Se usa al encadenar con `find -print0`. |

### 1.3 Ejemplos

- Mostrar las primeras 10 líneas (por defecto):

```bash
head archivo.txt
```

- Mostrar de forma específica las primeras 20 líneas:

```bash
head -n 20 archivo.txt
```

- Extraer e inspeccionar los primeros 50 bytes (muy útil para comprobar caracteres mágicos en archivos binarios):

```bash
head -c 50 archivo.txt
```

- Volcar las primeras 5 líneas de dos archivos distintos sin que el comando imprima los títulos de cada archivo separándolos:

```bash
head -n 5 -q archivo1.txt archivo2.txt
```

- Mostrar el archivo entero salvo las tres últimas líneas:

```bash
head -n -3 archivo.txt
```

---

## 2. Comando tail

El comando `tail` ("cola") se utiliza para mostrar las últimas líneas de uno o más archivos. Por defecto, muestra las últimas 10 líneas. Es una de las herramientas más imprescindibles en la administración de sistemas para la monitorización de eventos en vivo.

### 2.1 Sintaxis básica

```bash
tail [OPCIÓN]... [ARCHIVO]...
```

### 2.2 Opciones comunes

| Parámetro / Opción | Descripción |
|--------------------|-------------|
| `-n K`, `--lines=K`| Muestra estrictamente las últimas `K` líneas del archivo. Por ejemplo, `tail -n 5 archivo.txt` volcará solo las últimas 5. |
| `-c K`, `--bytes=K`| Muestra los últimos `K` bytes del archivo (final del documento). |
| `-f`, `--follow`   | Sigue el archivo en tiempo real, bloqueando la terminal y mostrando nuevas líneas automáticamente a medida que se añaden. Esencial para ver *logs*. |
| `-F`               | Similar a `-f`, pero la monitorización persiste y se reconecta incluso si el archivo es rotado, renombrado o se borra y recrea. |
| `--pid=PID`        | En combinación con `-f`, finaliza el seguimiento automáticamente después de que el proceso con el identificador `PID` especificado finalice. |
| `-q`, `--quiet`, `--silent` | No imprime la cabecera con el nombre del archivo al inspeccionar múltiples rutas. |
| `-v`, `--verbose`  | Siempre imprime la cabecera superior con el nombre del archivo. |

> **Nota:** Aunque los sistemas Linux modernos recomiendan utilizar la sintaxis con el argumento explícito (como `tail -n 2`), por pura retrocompatibilidad histórica se sigue aceptando la sintaxis directa omitiendo el parámetro (como `tail -2`). Ambos formatos son funcionalmente idénticos.

### 2.3 Ejemplos

- Mostrar las últimas 10 líneas (por defecto):

```bash
tail archivo.txt
```

- Mostrar explícitamente las últimas 20 líneas:

```bash
tail -n 20 archivo.txt
```

- Extraer los últimos 50 bytes de un fichero:

```bash
tail -c 50 archivo.txt
```

- Seguir un archivo de registro (*log*) en tiempo real y visualizar los eventos en vivo:

```bash
tail -f archivo.txt
```

- Seguir un archivo en tiempo real robustamente (si es un fichero de log gestionado por `logrotate`, `-F` logrará reconectarse si el archivo actual se renombra y se crea uno nuevo vacío en su lugar):

```bash
tail -F archivo.txt
```

### 2.4 Uso avanzado: el operador de compensación (`+`)

A continuación, veremos un ejemplo interactuando con un archivo CSV (`users.csv`). Podemos extraer simplemente las dos últimas líneas:

```bash
usuario@debian:/tmp/prueba$ tail -2 users.csv
user04;abc123.;group02;s
user05;abc123.;group02;S
```

Sin embargo, si utilizamos el símbolo `+` en el número de líneas, el comportamiento del comando cambia por completo. En lugar de mostrar las *últimas* líneas, **empieza a mostrar todo el documento a partir de la línea indicada**. Esto es extremadamente útil para saltarse la línea de cabecera de un archivo CSV de datos:

```bash
usuario@debian:/tmp/prueba$ tail +2 users.csv
user01;abc123.;group01;N
user02;abc123.;group01;s
user03;abc123.;group01;n
user04;abc123.;group02;s
user05;abc123.;group02;S
```

> **Advertencia:** La forma abreviada `tail +2` procede de la sintaxis histórica de UNIX y no está garantizada en las versiones actuales de GNU coreutils, donde el `+2` puede interpretarse como el nombre de un fichero y devolver `tail: cannot open '+2' for reading: No such file or directory`. Conviene acostumbrarse a escribir siempre la forma explícita `tail -n +2`, que es la documentada y la que funciona en cualquier sistema.

El mismo comportamiento con el formato de sintaxis explícito (`-n`), que es el recomendado:

```bash
usuario@debian:/tmp/prueba$ tail -n -2 users.csv
user04;abc123.;group02;s
user05;abc123.;group02;S

usuario@debian:/tmp/prueba$ tail -n +2 users.csv
user01;abc123.;group01;N
user02;abc123.;group01;s
user03;abc123.;group01;n
user04;abc123.;group02;s
user05;abc123.;group02;S
```

---

## 3. Combinación de head y tail

Encadenando ambos comandos con una tubería se puede extraer un **rango concreto de líneas**, algo que ninguno de los dos hace por sí solo. La clave está en el orden: primero se recorta por arriba y después por abajo, o al revés.

Para mostrar exclusivamente la línea 5 de un fichero:

```bash
usuario@debian:~$ head -n 5 /etc/passwd | tail -n 1
sync:x:4:65534:sync:/bin:/bin/sync
```

Para mostrar el rango de la línea 3 a la 6, ambas incluidas:

```bash
usuario@debian:~$ head -n 6 /etc/passwd | tail -n 4
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
```

> **Nota:** La aritmética es sencilla: `head -n FIN` deja las líneas de la 1 a la `FIN`, y sobre ese resultado `tail -n (FIN - INICIO + 1)` se queda con el tramo pedido. Para rangos más complejos suele ser más cómodo `sed -n '3,6p'`, que se explica en el documento 15.

> **Recuerda:** `head` termina de leer en cuanto alcanza el número de líneas solicitado, mientras que `tail` necesita llegar hasta el final del fichero. Por eso `head -n 5 fichero_enorme.log` es instantáneo y `tail -n 5 fichero_enorme.log` puede tardar, aunque ambos muestren solo cinco líneas.
