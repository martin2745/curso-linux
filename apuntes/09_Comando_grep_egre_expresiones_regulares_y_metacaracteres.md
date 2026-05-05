# Comando grep, egrep, expresiones regulares y metacaracteres

## Índice

1. [Expresiones Regulares](#1-expresiones-regulares)
   - [Caracteres Literales](#caracteres-literales)
   - [Conjuntos de Caracteres](#conjuntos-de-caracteres)
   - [Anclas de Línea](#anclas-de-línea)
   - [Operadores de Cantidad](#operadores-de-cantidad)
   - [Grupos](#grupos)
   - [Caracteres de Escape](#caracteres-de-escape)
   - [Repeticiones](#repeticiones)
   - [Clases de Caracteres POSIX](#clases-de-caracteres-posix)
2. [Uso de grep y egrep](#2-uso-de-grep-y-egrep)
   - [Comando grep](#comando-grep)
   - [Comando egrep](#comando-egrep)
3. [Metacaracteres](#3-metacaracteres)

---

Las expresiones regulares (regex o regexp) son patrones utilizados para encontrar una determinada secuencia de caracteres dentro de una cadena de texto. Son ampliamente utilizadas en la búsqueda y manipulación de cadenas de texto en diversos contextos de programación y procesamiento de datos. A continuación, se presenta una guía básica de los elementos fundamentales de las expresiones regulares:

---

## 1. Expresiones Regulares

### Caracteres Literales

- `.`: Representa cualquier caracter excepto un salto de línea.
- `[ ]`: Define un conjunto de caracteres permitidos en esa posición.

### Conjuntos de Caracteres

- `[rfc]+`: 1 o más coincidencias de 'r', 'f' o 'c'.
- `[a-z]+`: 1 o más letras minúsculas.
- `[A-Z]+`: 1 o más letras mayúsculas.
- `[a-Z]+`: 1 o más letras, tanto minúsculas como mayúsculas.
- `[^rfc]+`: 1 o más caracteres que no sean 'r', 'f' o 'c'.
- `[^a-z]?`: 0 o 1 caracter que no sea una letra minúscula.
- `[^A-Z]?`: 0 o 1 caracter que no sea una letra mayúscula.

### Anclas de Línea

- `^`: Indica el inicio de una línea.
- `$`: Indica el final de una línea.

### Operadores de Cantidad

- `*`: 0 o más coincidencias del patrón anterior.

### Grupos

- `( )`: Permite agrupar expresiones regulares.

### Caracteres de Escape

- `\`: Escapa un metacarácter para que sea interpretado literalmente.

### Repeticiones

- `{n}`: Exactamente `n` coincidencias del patrón anterior.
- `{n,}`: Como mínimo `n` coincidencias del patrón anterior.
- `{n,m}`: Entre `n` y `m` coincidencias del patrón anterior.

> **Nota:** Ejemplos comunes de repeticiones y conjuntos:
> - `[rfc]*`: Cero o más ocurrencias de 'r', 'f' o 'c'.
> - `(rfc)`: Agrupa los caracteres 'rfc'.
> - `(r.c)`: Agrupa un conjunto de tres caracteres donde el primero es 'r', el tercero es 'c' y el segundo puede ser cualquier caracter.
> - `{2}`: Exactamente 2 caracteres minúsculos (requiere el conjunto previo como `[a-z]{2}`).
> - `[a-z]{2,}`: Como mínimo 2 caracteres minúsculos.
> - `[a-z]{2,4}`: Entre 2 y 4 caracteres minúsculos.

### Clases de Caracteres POSIX

**POSIX** (_Portable Operating System Interface for Unix_) es un **estándar** que define cómo deben comportarse los sistemas operativos tipo **Unix** (como Linux, macOS y BSD) para garantizar compatibilidad entre ellos.

- **Objetivo:** Permitir que los programas sean **portables** y funcionen en diferentes sistemas sin cambios importantes.  
- **Incluye:** Comandos, utilidades, programación en shell (`sh`), llamadas al sistema (API).  
- **Ejemplo:** Un script POSIX-compatible se ejecutará en Bash, Dash y otros shells sin problemas.

> **Recuerda:** POSIX es una norma que unifica el comportamiento de sistemas Unix para mejorar la compatibilidad y portabilidad.

Las clases de caracteres POSIX son atajos para definir conjuntos de caracteres comunes:

- `[:lower:]`: `[a-z]`.
- `[:upper:]`: `[A-Z]`.
- `[:alpha:]`: `[A-Za-z]` o `[:lower:]` + `[:upper:]`.
- `[:digit:]`: `[0-9]`.
- `[:xdigit:]`: `[0-9A-Fa-f]`.
- `[:alnum:]`: `[0-9A-Za-z]` o `[:alpha:]` + `[:digit:]`.
- `[:blank:]`: Caracteres de espacio y tabulado.
- `[:cntrl:]`: Caracteres de control.
- `[:punct:]`: Caracteres de puntuación, equivalente a los símbolos de puntuación comunes.
- `[:graph:]`: `[:alnum:]` + `[:punct:]`.
- `[:print:]`: `[:alnum:]` + `[:punct:]` + espacio.
- `[:space:]`: Caracteres de espacio en blanco, como tabuladores, saltos de línea, etc.

---

## 2. Uso de `grep` y `egrep`

`grep` es una herramienta de línea de comandos que busca patrones en archivos o en la salida de otros comandos. `egrep` es una versión extendida de `grep` que admite una sintaxis de expresiones regulares más amplia.

```bash
grep [opciones] patrón [archivo...]
```

| Parámetro | Descripción |
|-----------|-------------|
| `-v` | Invierte la búsqueda para mostrar líneas que NO coincidan. |
| `-l` | Sólo indica el nombre del fichero donde ha encontrado alguna coincidencia. |
| `-w` | El patrón tiene que ser una palabra independiente. |
| `-n` | Muestra el número de línea junto con la coincidencia. |
| `-i` | Ignora mayúsculas y minúsculas. |
| `-c` | Muestra la cantidad de líneas que cumplen con el patrón. |
| `-r` | Busca en los ficheros de forma recursiva. |
| `-e` | Permite encadenar varios patrones de búsqueda. |
| `-E` | Interpreta el patrón como una expresión regular extendida (equivalente a usar `egrep`). |
| `-o` | Muestra solo las partes de las líneas que coinciden con el patrón de búsqueda. |

### Comando `grep`

A continuación se muestran ejemplos para buscar palabras en un archivo y la salida de otros comandos:

```bash
root@debian:~# netstat -putan | grep tcp
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      1/init
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      588/sshd: /usr/sbin
tcp        0     52 192.168.33.11:22        192.168.33.1:54291      ESTABLISHED 874/sshd: vagrant [
tcp6       0      0 :::80                   :::*                    LISTEN      681/apache2
tcp6       0      0 :::111                  :::*                    LISTEN      1/init
tcp6       0      0 :::22                   :::*                    LISTEN      588/sshd: /usr/sbin

root@debian:~# netstat -putan | grep -i listen
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      1/init
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      588/sshd: /usr/sbin
tcp6       0      0 :::80                   :::*                    LISTEN      681/apache2
tcp6       0      0 :::111                  :::*                    LISTEN      1/init
tcp6       0      0 :::22                   :::*                    LISTEN      588/sshd: /usr/sbin

root@debian:~# netstat -putan | grep -w tcp
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      1/init
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      588/sshd: /usr/sbin
tcp        0     52 192.168.33.11:22        192.168.33.1:54291      ESTABLISHED 874/sshd: vagrant [

root@debian:~# netstat -putan | grep -v tcp
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
udp        0      0 127.0.0.1:323           0.0.0.0:*                           598/chronyd
udp        0      0 0.0.0.0:68              0.0.0.0:*                           843/dhclient
udp        0      0 0.0.0.0:111             0.0.0.0:*                           1/init
udp6       0      0 ::1:323                 :::*                                598/chronyd
udp6       0      0 :::111                  :::*                                1/init

root@debian:~# netstat -putan | grep -n tcp
3:tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      1/init
4:tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      588/sshd: /usr/sbin
5:tcp        0     52 192.168.33.11:22        192.168.33.1:54291      ESTABLISHED 874/sshd: vagrant [
6:tcp6       0      0 :::80                   :::*                    LISTEN      681/apache2
7:tcp6       0      0 :::111                  :::*                    LISTEN      1/init
8:tcp6       0      0 :::22                   :::*                    LISTEN      588/sshd: /usr/sbin

root@debian:~# netstat -putan | grep -w -e tcp -e udp
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      1/init
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      588/sshd: /usr/sbin
tcp        0     52 192.168.33.11:22        192.168.33.1:54291      ESTABLISHED 874/sshd: vagrant [
udp        0      0 127.0.0.1:323           0.0.0.0:*                           598/chronyd
udp        0      0 0.0.0.0:68              0.0.0.0:*                           843/dhclient
udp        0      0 0.0.0.0:111             0.0.0.0:*                           1/init
```

Ejemplos extrayendo exclusivamente el texto que coincide:

```bash
root@debian:~# grep -o vagrant /etc/passwd
vagrant
vagrant
vagrant

root@debian:~# ip a | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}'
127.0.0.1/8
10.0.2.15/24
192.168.33.11/24

root@debian:~# ip a | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}' | xargs
127.0.0.1/8 10.0.2.15/24 192.168.33.11/24
```

> **Nota:** Al usar `-oE`, se combina `-o` (imprimir solo coincidencias) con `-E` (expresiones regulares extendidas) permitiendo construir filtros potentes para extraer, por ejemplo, direcciones IP.

### Comando `egrep`

`egrep` es una versión más potente de `grep` que admite una sintaxis extendida de expresiones regulares sin necesidad de escapar ciertos caracteres.

```bash
egrep [opciones] patrón [archivo...]
```

Para buscar múltiples palabras en un archivo utilizando un OR lógico:

```bash
egrep "patrón1|patrón2" archivo.txt
```

Para buscar una palabra ignorando mayúsculas y minúsculas:

```bash
egrep -i "patrón" archivo.txt
```

---

## 3. Metacaracteres

Son caracteres con significado especial que representan clases de caracteres o repeticiones. A diferencia de las expresiones regulares de `grep`, los metacaracteres del intérprete de comandos o Shell (Wildcards) se aplican fundamentalmente a los nombres de los ficheros y rutas.

- `*`: Coincide con cero o más repeticiones de cualquier elemento.
- `?`: Coincide con cualquier carácter individual.
- `[ ]`: Coincide con cualquier carácter dentro del conjunto especificado.
- `|`: La tubería (pipe) pasa la salida estándar del comando izquierdo a la entrada del comando derecho.
- `;`: El punto y coma permite ejecutar comandos secuencialmente.
- `&`: Ejecuta un comando en segundo plano.

Ejemplos prácticos:

1. **Asterisco** (`*`):

```bash
ls *.txt
cp file* directory/
```

2. **Signo de interrogación** (`?`):

```bash
ls file?.txt
rm file?.txt
```

3. **Corchetes** (`[ ]`):

```bash
ls [aeiou]*
rm [0-9]*
```

4. **Barra vertical** (`|`):

```bash
ls -l | grep filename
cat file.txt | sed 's/old/new/g'
```

5. **Punto y coma** (`;`):

```bash
mkdir folder1 ; cp file.txt folder1/
rm *.txt ; rm *.csv
```

6. **Ampersand** (`&`):

```bash
./script.sh &
make &
```

> **Advertencia:** El uso descuidado de metacaracteres como `*` junto con comandos destructivos como `rm` puede ocasionar pérdida de datos irremediable (ej: `rm *` borrará todos los archivos en el directorio actual).
