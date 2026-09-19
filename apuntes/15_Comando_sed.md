# Comando sed

## Índice

1. [Opciones principales](#1-opciones-principales)
2. [Ejemplos de uso](#2-ejemplos-de-uso)
   - [Sustituciones básicas y múltiples](#sustituciones-básicas-y-múltiples)
   - [Eliminación de líneas](#eliminación-de-líneas)
   - [Sustituciones mediante rangos](#sustituciones-mediante-rangos)
   - [Guardar en un nuevo archivo](#guardar-en-un-nuevo-archivo)
   - [Uso de expresiones regulares](#uso-de-expresiones-regulares)

---

El comando `sed` (_stream editor_) en Linux es un potente editor de flujo de texto que permite realizar cambios en archivos de texto desde la línea de comandos sin necesidad de abrirlos en un editor interactivo (como nano o vim). Por ejemplo, para reemplazar todas las instancias de "hola" por "adiós" en un archivo llamado `archivo.txt`, usarías el siguiente comando:

```bash
sed 's/hola/adiós/g' archivo.txt
```

> **Recuerda:** La estructura de sustitución general es `s/antiguo/nuevo/g`, donde `s` significa _substitute_ (sustituir) y `g` significa _global_ (para reemplazar todas las ocurrencias en cada línea en lugar de solo la primera).

---

## 1. Opciones principales

A continuación se explican los parámetros más relevantes de `sed`:

| Parámetro | Descripción |
|-----------|-------------|
| `-e`      | Permite especificar múltiples comandos de `sed` concatenados en una sola ejecución. |
| `-i`      | Modifica el archivo de entrada directamente (_in-place_) en lugar de imprimir a la salida estándar. |
| `-n`      | Suprime la salida automática de `sed`. Solo imprime líneas explícitamente indicadas. |
| `-r`      | Habilita el uso de expresiones regulares extendidas (ERE). |
| `-E`      | Idéntico a `-r`. Es la forma preferible, porque la reconocen tanto GNU sed como el sed de BSD y macOS. |
| `-s`      | Trata cada fichero de entrada por separado en lugar de como un único flujo continuo. Afecta al significado de direcciones como `1` o `$`. |
| `-f GUION` | Lee los comandos desde un fichero de guión en lugar de la línea de órdenes. |

> **Nota:** Aunque `-r` y `-E` son equivalentes en GNU sed, conviene acostumbrarse a `-E`. La opción `-r` es exclusiva de GNU y un guión que la use fallará en macOS o en BSD.

Además de la sustitución `s`, `sed` dispone de otros comandos internos que se indican tras la dirección de línea:

| Comando | Descripción |
|---|---|
| `s` | Sustituye texto. Es el más empleado con diferencia. |
| `d` | (*Delete*) Elimina las líneas seleccionadas. |
| `p` | (*Print*) Imprime las líneas seleccionadas. Se combina casi siempre con `-n`. |
| `a TEXTO` | (*Append*) Añade una línea nueva **después** de la seleccionada. |
| `i TEXTO` | (*Insert*) Añade una línea nueva **antes** de la seleccionada. |
| `c TEXTO` | (*Change*) Sustituye por completo la línea seleccionada. |
| `y/abc/xyz/` | Transcribe caracteres uno a uno, igual que hace el comando `tr`. |
| `q` | (*Quit*) Termina la lectura del fichero. `sed '100q'` deja de leer en la línea 100. |
| `=` | Imprime el número de línea. |
| `!` | Niega la dirección: `sed '2!d'` borra todas las líneas **salvo** la segunda. |

Las direcciones que preceden al comando pueden expresarse de varias formas:

| Dirección | Selecciona |
|---|---|
| `5` | La línea 5. |
| `2,7` | De la línea 2 a la 7. |
| `$` | La última línea del fichero. |
| `2,$` | Desde la segunda línea hasta el final. |
| `/patrón/` | Todas las líneas que coincidan con la expresión regular. |
| `/inicio/,/fin/` | Desde la línea que coincida con `inicio` hasta la que coincida con `fin`. |
| `0~3` | Una de cada tres líneas. Extensión de GNU sed. |

> **Nota:** Si indicamos `sed -i.bak 's/antiguo/nuevo/g' archivo` estamos creando automáticamente una copia de seguridad original llamada `archivo.bak` antes de aplicar la modificación.

> **Advertencia:** La opción `-i` **no tiene deshacer**. Un patrón mal escrito puede arrasar un fichero de configuración en un instante. La costumbre recomendable es ejecutar siempre el comando primero sin `-i`, comprobar en pantalla que la salida es la esperada, y solo entonces repetirlo añadiendo `-i` o, mejor aún, `-i.bak`.

> **Importante:** `sed -i` no edita el fichero en su sitio pese a lo que sugiere su nombre: crea un fichero temporal y lo renombra sobre el original. Esto tiene dos consecuencias que sorprenden. La primera, que el inodo cambia, de modo que si el fichero tenía enlaces duros, estos dejan de apuntar al contenido nuevo. La segunda, que si se aplica sobre un enlace simbólico, `sed` reemplaza el enlace por un fichero normal en lugar de modificar el destino, salvo que se emplee `--follow-symlinks`.

---

## 2. Ejemplos de uso

### Sustituciones básicas y múltiples

Cambia los caracteres `"` y `,` por un espacio en blanco (` `) y edita directamente el fichero `file.tmp`.

```bash
usuario@debian:~$ sed -i -e 's#"# #g' -e 's#,# #g' file.tmp
 user11   p11   /bin/bash   /tmp
 user2   p2   /bin/false   /home/user2
 user2   p2   /bin/false   /home/user2
```

> **Nota:** Observa que en el comando anterior se ha usado el separador `#` en lugar de `/` (`s#"# #g`). El comando `sed` permite usar cualquier delimitador inmediatamente posterior a la `s`, lo cual es útil si el texto a buscar incluye el carácter `/` (como rutas de directorios).

El flag `-n` desactiva la impresión automática de cada línea procesada, de modo que `sed` no muestra nada salvo que se lo pidamos expresamente con el comando `p`:

```bash
usuario@debian:~$ sed -n -e 's#"# #g' -e 's#,# #g' file.tmp
usuario@debian:~$
```

Si no se usa el flag global `g`, solo se elimina o reemplaza la **primera ocurrencia por línea**:

```bash
usuario@debian:~$ sed -e 's#user2#usuario#g' file.tmp
"user11","p11","/bin/bash","/tmp"
"usuario","p2","/bin/false","/home/usuario"
"usuario","p2","/bin/false","/home/usuario"

usuario@debian:~$ sed -e 's#user2#usuario#' file.tmp
"user11","p11","/bin/bash","/tmp"
"usuario","p2","/bin/false","/home/user2"
"usuario","p2","/bin/false","/home/user2"
```

La opción de impresión `p` hace que se muestren explícitamente las líneas donde se han realizado sustituciones. Si se combina con `-n`, obtenemos solo las líneas que efectivamente cambiaron:

```bash
usuario@debian:~$ sed -e 's/user2/usuario/gp' file.tmp
"user11","p11","/bin/bash","/tmp"
"usuario","p2","/bin/false","/home/usuario"
"usuario","p2","/bin/false","/home/usuario"
"usuario","p2","/bin/false","/home/usuario"
"usuario","p2","/bin/false","/home/usuario"

usuario@debian:~$ sed -n -e 's/user2/usuario/gp' file.tmp
"usuario","p2","/bin/false","/home/usuario"
"usuario","p2","/bin/false","/home/usuario"
```

### Eliminación de líneas

Podemos eliminar líneas con `sed` usando el comando `d` (_delete_). Primero creamos un archivo de prueba con números del 1 al 80:

> **Nota:** El bucle que aparece a continuación funciona, pero da un rodeo innecesario: envuelve la orden en una sustitución de comandos `$(...)` que no aporta nada, ya que la redirección al fichero se produce dentro. El mismo fichero se obtiene con una sola orden, `seq 1 80 > prueba.txt`, sin bucle ni `touch`.

```bash
usuario@debian:~$ for i in $(seq 1 80); do $(touch prueba.txt && echo "${i}" >> prueba.txt); done;
usuario@debian:~$ head prueba.txt
1
2
3
4
5
6
7
8
9
10
```

Eliminar un rango de líneas (de la 2 a la 7):

```bash
usuario@debian:~$ sed -i '2,7d' prueba.txt
usuario@debian:~$ head prueba.txt
1
8
9
10
11
12
13
14
15
16
```

Eliminar solo la primera línea:

```bash
usuario@debian:~$ sed -i '1d' prueba.txt
usuario@debian:~$ head prueba.txt
8
9
10
11
12
13
14
15
16
17
```

> **Nota:** La sintaxis es muy flexible; puedes usar `1d`, `1'd'`, o `1,5d` para rangos, con idéntico resultado lógico:

```bash
usuario@debian:~$ sed -i 1'd' prueba.txt
usuario@debian:~$ head prueba.txt
9
10
11
12
13
14
15
16
17
18

usuario@debian:~$ sed -i 1,5'd' prueba.txt
usuario@debian:~$ head prueba.txt
14
15
16
17
18
19
20
21
22
23
```

### Sustituciones mediante rangos

Podemos aplicar sustituciones de texto solo a determinadas líneas:

Sustituir de forma general:
```bash
usuario@debian:~$ sed -i 's/false/bash/g' file.tmp
usuario@debian:~$ cat file.tmp
"user11","p11","/bin/bash","/tmp"
"user2","p2","/bin/bash","/home/user2"
"user2","p2","/bin/bash","/home/user2"
```

Sustituir solo en la línea 2 (`2s`):
```bash
usuario@debian:~$ sed 2's/bash/false/g' file.tmp
"user11","p11","/bin/bash","/tmp"
"user2","p2","/bin/false","/home/user2"
"user2","p2","/bin/bash","/home/user2"

usuario@debian:~$ sed '2s/bash/false/g' file.tmp
"user11","p11","/bin/bash","/tmp"
"user2","p2","/bin/false","/home/user2"
"user2","p2","/bin/bash","/home/user2"
```

Sustituir en un rango, de la línea 1 a la 3 (`1,3s`):
```bash
usuario@debian:~$ sed 1,3's/bash/false/g' file.tmp
"user11","p11","/bin/false","/tmp"
"user2","p2","/bin/false","/home/user2"
"user2","p2","/bin/false","/home/user2"

usuario@debian:~$ sed '1,3s/bash/false/g' file.tmp
"user11","p11","/bin/false","/tmp"
"user2","p2","/bin/false","/home/user2"
"user2","p2","/bin/false","/home/user2"
```

### Guardar en un nuevo archivo

Para guardar la modificación resultante en otro fichero directamente podemos usar el modificador `w` (_write_) en el comando de sustitución:

```bash
usuario@debian:~$ sed -e "s/user/usuario/gw fileModificado.tmp" file.tmp
"usuario11","p11","/bin/bash","/tmp"
"usuario2","p2","/bin/bash","/home/usuario2"
"usuario2","p2","/bin/bash","/home/usuario2"

usuario@debian:~$ cat fileModificado.tmp
"usuario11","p11","/bin/bash","/tmp"
"usuario2","p2","/bin/bash","/home/usuario2"
"usuario2","p2","/bin/bash","/home/usuario2"
```

### Imprimir líneas concretas con -n y p

La combinación de `-n` con el comando `p` convierte a `sed` en una herramienta de extracción de líneas mucho más flexible que `head` y `tail`:

```bash
usuario@debian:~$ sed -n '5p' /etc/passwd
sync:x:4:65534:sync:/bin:/bin/sync
usuario@debian:~$ sed -n '3,6p' /etc/passwd
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
usuario@debian:~$ sed -n '$p' /etc/passwd
usuario:x:1000:1000:usuario,,,:/home/usuario:/bin/bash
```

> **Recuerda:** En el documento 05 se explicaba cómo extraer un rango de líneas encadenando `head` y `tail`. Con `sed -n '3,6p'` se consigue lo mismo sin aritmética mental y con un solo proceso.

También puede seleccionarse por contenido en lugar de por número de línea:

```bash
usuario@debian:~$ sed -n '/bash/p' /etc/passwd
root:x:0:0:root:/root:/bin/bash
usuario:x:1000:1000:usuario,,,:/home/usuario:/bin/bash
```

> **Nota:** Añadiendo `q` se evita recorrer el resto del fichero una vez encontrado lo que buscábamos, algo que se agradece en registros de varios gigabytes: `sed -n '/ERROR/{p;q}' enorme.log` imprime la primera coincidencia y termina.

### Insertar, añadir y eliminar líneas

```bash
usuario@debian:~$ printf 'uno\ndos\ntres\n' > lista.txt
usuario@debian:~$ sed '2i INSERTADA' lista.txt
uno
INSERTADA
dos
tres
usuario@debian:~$ sed '2a ANEXADA' lista.txt
uno
dos
ANEXADA
tres
usuario@debian:~$ sed '2c CAMBIADA' lista.txt
uno
CAMBIADA
tres
```

Un uso muy frecuente en administración consiste en depurar un fichero de configuración eliminando comentarios y líneas en blanco para ver de un vistazo qué directivas están realmente activas:

```bash
usuario@debian:~$ sed -e 's/#.*//' -e '/^\s*$/d' /etc/ssh/sshd_config
Include /etc/ssh/sshd_config.d/*.conf
KbdInteractiveAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
Subsystem	sftp	/usr/lib/openssh/sftp-server
```

> **Recuerda:** El comando `!` invierte la selección, de modo que `sed -n '1!p' fichero` imprime todo salvo la primera línea, y `sed '$!d' fichero` deja únicamente la última.

### Uso de expresiones regulares

`sed` permite el uso de expresiones regulares extendidas con la opción `-r`, o su sinónimo `-E`. Sin ellas, `sed` interpreta el patrón como expresión regular básica (BRE) y los paréntesis de agrupación habría que escribirlos `\(` y `\)`, tal como se explicaba en el documento 09.

El siguiente ejemplo intercepta una URL, la divide en grupos de captura y los reorganiza usando referencias hacia atrás (`\1`, `\2`):

```bash
usuario@debian:~$ echo 'http://www.example1.local/cig/' | sed -r 's|(http)(://)(www.example1.local/cig)|\1s\2example1.local/cig|'
https://example1.local/cig/
```

**Desglose del patrón de búsqueda**

1. `(http)`: Captura la cadena `http` y la guarda en el grupo de captura 1.
2. `(://)`: Captura los caracteres `://` y los guarda en el grupo de captura 2.
3. `(www.example1.local/cig)`: Captura la cadena `www.example1.local/cig` y la guarda en el grupo de captura 3.

> **Advertencia:** En este patrón los puntos de `www.example1.local` no están escapados, de modo que `sed` los interpreta como "cualquier carácter" y no como un punto literal. Aquí el resultado es el correcto por casualidad, porque el texto de entrada sí contiene puntos en esas posiciones, pero el mismo patrón coincidiría también con `wwwXexample1Ylocal/cig`. Para que la coincidencia sea exacta habría que escribirlos como `\.`: `(www\.example1\.local/cig)`.

> **Nota:** El grupo 3 se captura pero nunca se utiliza en el reemplazo, donde se reescribe como texto literal. Un patrón equivalente y más directo sería `sed -E 's|http://www\.|https://|'`, que se limita a cambiar lo que hay que cambiar.

**Desglose del patrón de reemplazo**

- `\1`: Referencia al contenido capturado en el grupo 1, que es `http`.
- `s`: Un carácter literal que se inserta en el resultado, convirtiendo http en https.
- `\2`: Referencia al contenido capturado en el grupo 2, que es `://`.
- `example1.local/cig`: Texto literal que se inserta directamente en el resultado, omitiendo el "www." anterior.

**Funcionamiento del comando completo**

1. **Entrada**: `'http://www.example1.local/cig/'`
2. **Patrón de búsqueda**: `(http)(://)(www.example1.local/cig)`
3. **Coincidencia**:
   - `http` se guarda en el grupo 1.
   - `://` se guarda en el grupo 2.
   - `www.example1.local/cig` se guarda en el grupo 3.
4. **Reemplazo**: `\1s\2example1.local/cig`
   - `\1` se reemplaza con `http`.
   - `s` se inserta literalmente.
   - `\2` se reemplaza con `://`.
   - `example1.local/cig` se inserta literalmente.

> **Importante:** Las expresiones regulares amplían drásticamente las posibilidades de `sed`, permitiendo automatizar migraciones complejas de código, formatos y URLs dentro de archivos masivos en cuestión de segundos.
