# Comando head y tail

## Índice

1. [head](#head)
   - [Sintaxis básica](#sintaxis-básica)
   - [Opciones comunes](#opciones-comunes)
   - [Ejemplos](#ejemplos)
2. [tail](#tail)
   - [Sintaxis básica](#sintaxis-básica-1)
   - [Opciones comunes](#opciones-comunes-1)
   - [Ejemplos](#ejemplos-1)

---

## `head`

El comando `head` ("cabeza") se utiliza para mostrar las primeras líneas de uno o más archivos directamente por la salida estándar. Por defecto, si no se le especifican parámetros adicionales, muestra las primeras 10 líneas. Es extremadamente útil para inspeccionar rápidamente el contenido, estructura o cabeceras de grandes conjuntos de datos.

### Sintaxis básica

```bash
head [OPCIÓN]... [ARCHIVO]...
```

### Opciones comunes

| Parámetro / Opción | Descripción |
|--------------------|-------------|
| `-n K`, `--lines=K`| Muestra estrictamente las primeras `K` líneas del archivo. Por ejemplo, `head -n 5 archivo.txt` volcará solo las primeras 5 líneas. |
| `-c K`, `--bytes=K`| Muestra los primeros `K` bytes del archivo en lugar de procesar saltos de línea. Por ejemplo, `head -c 100 archivo.txt` muestra los primeros 100 bytes. |
| `-q`, `--quiet`, `--silent` | No imprime la cabecera con el nombre del archivo cuando se trabaja con múltiples archivos de forma simultánea. |
| `-v`, `--verbose`  | Siempre imprime una cabecera con el nombre del archivo para separar los contenidos en la terminal. |

### Ejemplos

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

---

## `tail`

El comando `tail` ("cola") se utiliza para mostrar las últimas líneas de uno o más archivos. Por defecto, muestra las últimas 10 líneas. Es una de las herramientas más imprescindibles en la administración de sistemas para la monitorización de eventos en vivo.

### Sintaxis básica

```bash
tail [OPCIÓN]... [ARCHIVO]...
```

### Opciones comunes

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

### Ejemplos

- Mostrar las últimas 10 líneas (por defecto):

```bash
tail archivo.txt
```

- Mostrar explícitamente las últimas 20 líneas:

```bash
tail -n 20 archivo.txt
```

#### Uso avanzado: El operador de compensación (`+`)

A continuación, veremos un ejemplo interactuando con un archivo CSV (`users.csv`). Podemos extraer simplemente las dos últimas líneas:

```bash
usuario@debian:/tmp/prueba$ tail -2 users.csv
user04;abc123.;group02;s
user05;abc123.;group02;S
```

Sin embargo, si utilizamos el símbolo `+` en el número de líneas, el comportamiento del comando cambia drásticamente. En lugar de mostrar las *últimas* líneas, **empieza a mostrar todo el documento a partir de la línea indicada**. Esto es extremadamente útil para saltarse la línea de cabecera de un archivo CSV de datos:

```bash
usuario@debian:/tmp/prueba$ tail +2 users.csv
user01;abc123.;group01;N
user02;abc123.;group01;s
user03;abc123.;group01;n
user04;abc123.;group02;s
user05;abc123.;group02;S
```

Este mismo comportamiento aplica utilizando el formato de sintaxis moderno explícito (`-n`):

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
