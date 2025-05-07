# Comando grep, egrep, expresiones regulares y metacaracteres

Las expresiones regulares (regex o regexp) son patrones utilizados para encontrar una determinada secuencia de caracteres dentro de una cadena de texto. Son ampliamente utilizadas en la búsqueda y manipulación de cadenas de texto en diversos contextos de programación y procesamiento de datos. A continuación, se presenta una guía básica de los elementos fundamentales de las expresiones regulares:

## 1. Caracteres Literales

- **.**: Representa cualquier caracter excepto un salto de línea.
- **[ ]**: Define un conjunto de caracteres permitidos en esa posición.

## 2. Conjuntos de Caracteres

- **[rfc]+**: 1 o más coincidencias de 'r', 'f' o 'c'.
- **[a-z]+**: 1 o más letras minúsculas.
- **[A-Z]+**: 1 o más letras mayúsculas.
- **[a-Z]+**: 1 o más letras, tanto minúsculas como mayúsculas.
- **[^rfc]+**: 1 o más caracteres que no sean 'r', 'f' o 'c'.
- **[^a-z]?**: 0 o 1 caracter que no sea una letra minúscula.
- **[^A-Z]?**: 0 o 1 caracter que no sea una letra mayúscula.

## 3. Anclas de Línea

- **^**: Indica el inicio de una línea.
- **$**: Indica el final de una línea.

## 4. Operadores de Cantidad

- **\***: 0 o más coincidencias del patrón anterior.

## 5. Grupos

- **\( \)**: Permite agrupar expresiones regulares.

## 6. Caracteres de Escape

- **\\**: Escapa un metacarácter para que sea interpretado literalmente.

## 7. Repeticiones

- **\{n\}**: Exactamente n coincidencias del patrón anterior.
- **\{n,\}**: Como mínimo n coincidencias del patrón anterior.
- **\{n,m\}**: `Entre` n y m coincidencias del patrón anterior.

#### Ejemplos

- **[rfc]\***: Cero o más ocurrencias de 'r', 'f' o 'c'.
- **\(rfc\)**: Agrupa los caracteres 'rfc'.
- **\(r.c\)**: Agrupa un conjunto de tres caracteres donde el primero es 'r', el tercero es 'c' y el segundo puede ser cualquier caracter.
- **\{2\}**: Exactamente 2 caracteres minúsculos.
- **[a-z]\{2,\}**: Como mínimo 2 caracteres minúsculos.
- **[a-z]\{2,4\}**: `Entre` 2 y 4 caracteres minúsculos.

#### Clases de Caracteres POSIX

**POSIX** (*Portable Operating System Interface for Unix*) es un **estándar** que define cómo deben comportarse los sistemas operativos tipo **Unix** (como Linux, macOS y BSD) para garantizar compatibilidad entre ellos.  

🔹 **Objetivo:** Permitir que los programas sean **portables** y funcionen en diferentes sistemas sin cambios importantes.  
🔹 **Incluye:** Comandos, utilidades, programación en shell (`sh`), llamadas al sistema (API).  
🔹 **Ejemplo:** Un script POSIX-compatible se ejecutará en Bash, Dash y otros shells sin problemas.  

Podemos concluir que **POSIX** es una norma que unifica el comportamiento de sistemas Unix para mejorar la compatibilidad y portabilidad.

Las clases de caracteres POSIX son atajos para definir conjuntos de caracteres comunes:

- **[:lower:]**: [a-z].
- **[:upper:]**: [A-Z].
- **[:alpha:]**: [A-Za-z] o [:lower:] + [:upper:].
- **[:digit:]**: [0-9].
- **[:xdigit:]**: [0-9A-Fa-f].
- **[:alnum:]**: [0-9A-Za-z] o [:alpha:] + [:digit:].
- **[:blank:]**: Caracteres de espacio y tabulado.
- **[:cntrl:]**: Caracteres de control.
- **[:punct:]**: Caracteres de puntuación, equivalente a los símbolos de puntuación comunes.
- **[:graph:]**: [:alnum:] + [:punct:].
- **[:print:]**: [:alnum:] + [:punct:] + espacio.
- **[:space:]**: Caracteres de espacio en blanco, como tabuladores, saltos de línea, etc.

## Uso de `grep` y `egrep`

`grep` es una herramienta de línea de comandos que busca patrones en archivos o en la salida de otros comandos. `egrep` es una versión extendida de `grep` que admite una sintaxis de expresiones regulares más amplia.

```bash
grep [opciones] patrón [archivo...]
```

- **Opciones Comunes**:
  - *-v*: Invierte la búsqueda para mostrar líneas que NO coincidan.
  - *-l*: Sólo indica el nombre del fichero donde ha encontrado alguna coincidencia.
  - *-w*: El patrón tiene que ser una palabra independiente.
  - *-n*: Muestra el número de línea junto con la coincidencia.
  - *-i*: Ignora mayúsculas y minúsculas.
  - *-c*: Muestra la contidad de lineas que cumplen con el patrón.
  - *-r*: Busca en los ficheros de forma recursiva.
  - *-e*: Permite encadenar varios patrones de busqueda.
  - *-E*: Interprete el patrón de búsqueda como una expresión regular extendida (ERE), lo que significa que puedes utilizar una sintaxis más avanzada de expresiones regulares (también puede emplearse el comando *egrep* en este caso).
  - *-o*: Solo muestre las partes de las líneas que coinciden con el patrón de búsqueda, en lugar de toda la línea. Esto es útil cuando solo estás interesado en ver qué partes de las líneas coinciden con tu patrón.

### Comando `grep`

- Buscar una palabra en un archivo:

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

### Comando `egrep`

`egrep` es una versión más potente de `grep` que admite una sintaxis extendida de expresiones regulares sin necesidad de escapar ciertos caracteres.

```bash
egrep [opciones] patrón [archivo...]
```

#### Ejemplos de `egrep`

- Buscar múltiples palabras en un archivo:

  ```bash
  egrep "patrón1|patrón2" archivo.txt
  ```

- Buscar una palabra ignorando mayúsculas y minúsculas:
  ```bash
  egrep -i "patrón" archivo.txt
  ```

  
## Metacaracteres

Son caracteres con significado especial que representan clases de caracteres o repeticiones.

- Algunos metacaracteres comunes incluyen:
  - `.`: coincide con cualquier carácter excepto nueva línea.
  - `*`: coincide con cero o más repeticiones del elemento anterior.
  - `+`: coincide con una o más repeticiones del elemento anterior.
  - `?`: coincide con cero o una repetición del elemento anterior.
  - `[ ]`: coincide con cualquier carácter dentro del conjunto especificado.
  - `^`: coincide con el inicio de una línea.
  - `$`: coincide con el final de una línea.

1. Asterisco (\*)

   - `ls *.txt`: Lista todos los archivos con extensión ".txt" en el directorio actual.
   - `cp file* directory/`: Copia todos los archivos cuyo nombre comience con "file" al directorio especificado.

2. Signo de interrogación (?)

   - `ls file?.txt`: Lista archivos como "file1.txt", "fileA.txt", pero no "file10.txt".
   - `rm file?.txt`: Elimina archivos como "file1.txt", "fileA.txt", pero no "file10.txt".

3. Corchetes ([])

   - `ls [aeiou]*`: Lista archivos cuyos nombres comiencen con una vocal, es decir, puede ser solo un caracter igual a una de las vocales indicadas.
   - `rm [0-9]*`: Elimina archivos cuyos nombres comiencen con un dígito.

4. Barra vertical (|)

   - `ls -l | grep filename`: Muestra detalles de archivos que contienen "filename".
   - `cat file.txt | sed 's/old/new/g'`: Reemplaza todas las instancias de "old" con "new" en el contenido del archivo.

5. Punto y coma ( ; )

   - `mkdir folder1 ; cp file.txt folder1/`: Crea un directorio y copia un archivo en una sola línea.
   - `rm *.txt ; rm *.csv`: Elimina todos los archivos con extensión ".txt" y ".csv".

6. Ampersand (&)

   - `./script.sh &`: Ejecuta un script en segundo plano.
   - `make &`: Compila un programa en segundo plano mientras se realizan otras tareas en el terminal.
