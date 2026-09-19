# Comando grep, egrep, expresiones regulares y metacaracteres

## Índice

1. [Expresiones regulares](#1-expresiones-regulares)
   1. [Elementos que representan un carácter](#11-elementos-que-representan-un-carácter)
   2. [Anclas de posición](#12-anclas-de-posición)
   3. [Cuantificadores](#13-cuantificadores)
   4. [Grupos y alternancia](#14-grupos-y-alternancia)
   5. [BRE y ERE: por qué existen grep y grep -E](#15-bre-y-ere-por-qué-existen-grep-y-grep--e)
   6. [Clases de caracteres POSIX](#16-clases-de-caracteres-posix)
2. [Uso de `grep` y `egrep`](#2-uso-de-grep-y-egrep)
   1. [Comando `grep`](#21-comando-grep)
   2. [Comando `egrep`](#22-comando-egrep)
3. [Metacaracteres](#3-metacaracteres)
   1. [Comodines de nombre de fichero (globbing)](#31-comodines-de-nombre-de-fichero-globbing)
   2. [Operadores de control](#32-operadores-de-control)

---

## 1. Expresiones regulares

### 1.1 Elementos que representan un carácter

Estos elementos ocupan la posición de **un solo carácter** dentro del patrón.

| Elemento | Significado |
|---|---|
| `a`, `7`, `-` | Un carácter literal se representa a sí mismo. |
| `.` | Cualquier carácter, sea cual sea, excepto el salto de línea. |
| `[ ]` | Cualquiera de los caracteres indicados entre los corchetes. |
| `[^ ]` | Cualquier carácter que **no** esté entre los corchetes. |
| `\` | Escapa el carácter siguiente para que se interprete literalmente. |

Dentro de los corchetes se pueden enumerar caracteres sueltos o indicar rangos con un guion:

| Conjunto | Coincide con |
|---|---|
| `[rfc]` | Una `r`, una `f` o una `c`. |
| `[a-z]` | Una letra minúscula. |
| `[A-Z]` | Una letra mayúscula. |
| `[a-zA-Z]` | Una letra, mayúscula o minúscula. |
| `[0-9]` | Un dígito. |
| `[^rfc]` | Un carácter que no sea `r`, `f` ni `c`. |
| `[^0-9]` | Un carácter que no sea un dígito. |

> **Advertencia:** El rango `[a-Z]` es **incorrecto** y no equivale a "cualquier letra". Los rangos se resuelven sobre el valor numérico de los caracteres, y en la tabla ASCII la `Z` (90) va antes que la `a` (97), de modo que el rango está invertido. Según la herramienta y el *locale*, el resultado será un error del tipo `Invalid range end` o una coincidencia con caracteres inesperados como `[`, `\` o `^`. La forma correcta de expresar "cualquier letra" es `[a-zA-Z]` o, mejor aún, `[[:alpha:]]`.

> **Nota:** Dentro de los corchetes, la mayoría de los metacaracteres pierden su significado especial y valen por sí mismos: `[.*]` coincide con un punto o un asterisco, no con "cualquier carácter" seguido de una repetición. Los tres caracteres que sí conservan un papel especial son `^` (solo si va en primera posición, donde niega el conjunto), `-` (entre dos caracteres, donde forma un rango) y `]` (que debe ir el primero para tomarse como literal).

### 1.2 Anclas de posición

Las anclas no consumen ningún carácter: fijan **dónde** debe producirse la coincidencia.

| Elemento | Significado |
|---|---|
| `^` | Principio de línea. |
| `$` | Final de línea. |
| `\<` y `\>` | Principio y final de palabra. |
| `\b` | Frontera de palabra, valga por el principio o por el final. |

> **Recuerda:** El carácter `^` desempeña dos papeles completamente distintos según dónde aparezca. Al principio del patrón es el ancla de inicio de línea (`^root` busca líneas que empiecen por `root`), mientras que dentro de unos corchetes y en primera posición niega el conjunto (`[^root]` coincide con cualquier carácter que no sea `r`, `o` ni `t`).

### 1.3 Cuantificadores

Un cuantificador indica cuántas veces debe repetirse **el elemento inmediatamente anterior**.

| Elemento | Significado |
|---|---|
| `*` | Cero o más repeticiones. |
| `+` | Una o más repeticiones. |
| `?` | Cero o una repetición, es decir, el elemento es opcional. |
| `{n}` | Exactamente `n` repeticiones. |
| `{n,}` | Como mínimo `n` repeticiones. |
| `{n,m}` | Entre `n` y `m` repeticiones. |

Aplicados a los conjuntos anteriores:

| Patrón | Coincide con |
|---|---|
| `[rfc]*` | Cero o más caracteres del conjunto `r`, `f`, `c`. |
| `[rfc]+` | Uno o más caracteres del conjunto `r`, `f`, `c`. |
| `[^a-z]?` | Como mucho un carácter que no sea minúscula. |
| `[a-z]{2}` | Exactamente dos letras minúsculas. |
| `[a-z]{2,}` | Dos o más letras minúsculas. |
| `[a-z]{2,4}` | Entre dos y cuatro letras minúsculas. |

> **Advertencia:** Un cuantificador afecta **solo al elemento que tiene justo delante**, no a todo el patrón. En `abc*`, el `*` se aplica únicamente a la `c`, de modo que coincide con `ab`, `abc`, `abcc`, `abccc`... Para repetir la secuencia completa hay que agruparla: `(abc)*`.

### 1.4 Grupos y alternancia

| Elemento | Significado |
|---|---|
| `( )` | Agrupa varios elementos para tratarlos como una unidad, normalmente para aplicarles un cuantificador. |
| `\|` | Alternancia lógica: coincide con lo que hay a la izquierda o con lo que hay a la derecha. |

| Patrón | Coincide con |
|---|---|
| `(rfc)` | La secuencia literal `rfc`. |
| `(r.c)` | Tres caracteres: una `r`, cualquier carácter y una `c`. |
| `(ab)+` | `ab`, `abab`, `ababab`... |
| `(gato\|perro)` | La palabra `gato` o la palabra `perro`. |

### 1.5 BRE y ERE: por qué existen grep y grep -E

Este es el punto que explica la existencia misma de `egrep`, y conviene entenderlo antes de seguir. Las expresiones regulares de POSIX vienen en dos dialectos:

- **BRE** (*Basic Regular Expressions*), que es lo que interpreta `grep` por defecto.
- **ERE** (*Extended Regular Expressions*), que es lo que interpreta `grep -E`.

Los elementos `.`, `*`, `^`, `$`, `[ ]` y `[^ ]` funcionan igual en ambos. La diferencia está en el resto, que en BRE **necesitan barra invertida** para conservar su significado especial, mientras que en ERE se escriben directamente:

| Significado | BRE (`grep`) | ERE (`grep -E`) |
|---|---|---|
| Una o más repeticiones | `\+` | `+` |
| Cero o una repetición | `\?` | `?` |
| Repeticiones contadas | `\{2,4\}` | `{2,4}` |
| Agrupación | `\(...\)` | `(...)` |
| Alternancia | `\|` | `|` |

El mismo patrón escrito en los dos dialectos:

```bash
usuario@debian:~$ grep    '^\(root\|daemon\):' /etc/passwd
usuario@debian:~$ grep -E '^(root|daemon):'     /etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
```

> **Importante:** La consecuencia práctica es que en BRE, un `+` escrito sin barra invertida **no es un cuantificador**: es un signo más literal. Por eso `grep '[0-9]+' fichero` no busca "uno o más dígitos", sino "un dígito seguido de un signo más", y devuelve resultados desconcertantes. En la práctica, y salvo que se persiga la máxima portabilidad, lo más cómodo es usar siempre `grep -E`.

> **Nota:** Existe un tercer dialecto, **PCRE** (*Perl Compatible Regular Expressions*), disponible con `grep -P`. Añade atajos muy usados como `\d` (dígito), `\w` (carácter de palabra), `\s` (espacio en blanco) y los cuantificadores perezosos `*?`. No forma parte de POSIX y no está garantizado en todos los sistemas, pero es el dialecto que emplean la mayoría de los lenguajes de programación modernos.

### 1.6 Clases de caracteres POSIX

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
| `-A N` | (*After*) Muestra además las `N` líneas posteriores a cada coincidencia. |
| `-B N` | (*Before*) Muestra además las `N` líneas anteriores a cada coincidencia. |
| `-C N` | (*Context*) Muestra `N` líneas antes y después. Es el atajo más práctico al revisar registros. |
| `-q` | (*Quiet*) No imprime nada: solo devuelve un código de salida `0` si hubo coincidencia. Pensado para usarse dentro de un `if` en un script. |
| `-F` | Trata el patrón como texto **literal**, sin interpretar ningún metacarácter. Equivale al antiguo `fgrep`. |
| `-x` | Exige que el patrón coincida con la línea **completa**, no con una parte. |
| `-L` | Lo contrario de `-l`: lista los ficheros en los que **no** hubo ninguna coincidencia. |
| `--color=auto` | Resalta en color la parte coincidente. En Debian suele venir ya activado mediante un alias. |

> **Recuerda:** `grep` comunica el resultado a través de su código de salida, que es lo que permite encadenarlo en scripts: `0` si encontró al menos una coincidencia, `1` si no encontró ninguna y `2` si se produjo un error, por ejemplo al no poder abrir el fichero.
>
> ```bash
> if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
>     echo "El acceso directo de root por SSH está habilitado."
> fi
> ```

### 2.1 Comando `grep`

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

### 2.2 Comando `egrep`

`egrep` es la forma histórica de invocar `grep` con expresiones regulares extendidas, sin necesidad de escapar los caracteres descritos en el apartado sobre BRE y ERE.

```bash
egrep [opciones] patrón [archivo...]
```

> **Advertencia:** Desde la versión 3.8 de GNU grep, publicada en 2022 e incluida en Debian 12 y posteriores, `egrep` y `fgrep` están declarados obsoletos y muestran un aviso al ejecutarse:
>
> ```bash
> usuario@debian:~$ egrep "root|daemon" /etc/passwd
> egrep: warning: egrep is obsolescent; using grep -E
> root:x:0:0:root:/root:/bin/bash
> daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
> ```
>
> Siguen funcionando, pero está previsto que desaparezcan. La forma correcta hoy es `grep -E` en lugar de `egrep`, y `grep -F` en lugar de `fgrep`. Conviene acostumbrarse a escribirlo así, sobre todo dentro de scripts que deban seguir funcionando dentro de unos años.

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

Bajo el nombre genérico de metacaracteres se agrupan dos familias de símbolos del intérprete de comandos que conviene no mezclar: los **comodines**, que el shell expande contra nombres de fichero antes de ejecutar nada, y los **operadores de control**, que determinan cómo se encadenan y ejecutan los comandos.

### 3.1 Comodines de nombre de fichero (globbing)

| Comodín | Significado |
|---|---|
| `*` | Cualquier cadena de caracteres, incluida la cadena vacía. |
| `?` | Un único carácter cualquiera. |
| `[ ]` | Un único carácter de entre los indicados. |
| `{a,b}` | Expansión de llaves: genera una alternativa por cada elemento de la lista. No es un comodín de ficheros, ya que funciona aunque el fichero no exista. |

> **Advertencia:** Aunque se escriban igual, `*` y `?` **no significan lo mismo** en el shell que en una expresión regular, y confundirlos es el error más frecuente al empezar.
>
> | Símbolo | En el shell (comodín) | En una expresión regular |
> |---|---|---|
> | `*` | Cualquier cadena de caracteres. | Cero o más repeticiones **del elemento anterior**. |
> | `?` | Exactamente un carácter cualquiera. | El elemento anterior es opcional. |
>
> El equivalente del `*` del shell dentro de una expresión regular es `.*`, y el equivalente del `?` del shell es `.`. Así, el comodín `file?.txt` se corresponde con la expresión regular `^file.\.txt$`.

> **Importante:** Los comodines los expande **el propio shell**, no el comando. Cuando se escribe `ls *.txt`, Bash sustituye el patrón por la lista de ficheros coincidentes y `ls` recibe ya los nombres completos, sin llegar a ver nunca el asterisco. Por eso, si ningún fichero coincide, el patrón se pasa tal cual y aparecen mensajes como `ls: no se puede acceder a '*.txt': No existe el fichero`. Y por eso mismo hay que entrecomillar el patrón cuando quien debe interpretarlo es el comando y no el shell, como ocurre en `find . -name "*.txt"`.

### 3.2 Operadores de control

| Operador | Función |
|---|---|
| `\|` | Tubería: conecta la salida estándar del comando de la izquierda con la entrada estándar del de la derecha. |
| `;` | Ejecuta los comandos de forma secuencial, con independencia de si el anterior tuvo éxito. |
| `&` | Lanza el comando en segundo plano y devuelve el control inmediatamente. |
| `&&` | Ejecuta el segundo comando **solo si** el primero terminó correctamente. |
| `\|\|` | Ejecuta el segundo comando **solo si** el primero falló. |

> **Recuerda:** La diferencia entre `;` y `&&` es importante en tareas de administración. Con `cd /tmp/datos ; rm *` el borrado se ejecuta aunque el `cd` haya fallado, y en ese caso se estarían borrando los ficheros del directorio en el que estuviéramos. Con `cd /tmp/datos && rm *` el borrado solo se produce si el cambio de directorio funcionó.

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
