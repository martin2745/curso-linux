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
| `-r`      | Habilita el uso de expresiones regulares extendidas. |

> **Nota:** Si indicamos `sed -i.bak 's/antiguo/nuevo/g' archivo` estamos creando automáticamente una copia de seguridad original llamada `archivo.bak` antes de aplicar la modificación.

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

El flag `-n` impide que se muestren los cambios por pantalla:

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

### Uso de expresiones regulares

`sed` permite el uso de expresiones regulares extendidas con la opción `-r` (o `-E` en algunas distribuciones).

El siguiente ejemplo intercepta una URL, la divide en grupos de captura y los reorganiza usando referencias hacia atrás (`\1`, `\2`):

```bash
usuario@debian:~$ echo 'http://www.example1.local/cig/' | sed -r 's|(http)(://)(www.example1.local/cig)|\1s\2example1.local/cig|'
https://example1.local/cig/
```

**Desglose del patrón de búsqueda**

1. `(http)`: Captura la cadena `http` y la guarda en el grupo de captura 1.
2. `(://)`: Captura los caracteres `://` y los guarda en el grupo de captura 2.
3. `(www.example1.local/cig)`: Captura la cadena `www.example1.local/cig` y la guarda en el grupo de captura 3.

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
