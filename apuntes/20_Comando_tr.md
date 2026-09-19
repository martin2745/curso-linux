# Comando tr

## Índice

1. [Particularidades del comando tr](#1-particularidades-del-comando-tr)
   1. [Resumen de opciones](#11-resumen-de-opciones)
2. [Ejemplos de interés](#2-ejemplos-de-interés)
   1. [Ejemplo 1: conversión de formatos MAC](#21-ejemplo-1-conversión-de-formatos-mac)
   2. [Ejemplo 2: limpieza de variables para scripts](#22-ejemplo-2-limpieza-de-variables-para-scripts)
   3. [Ejemplo 3: conversión de finales de línea](#23-ejemplo-3-conversión-de-finales-de-línea)
   4. [Ejemplo 4: convertir un texto en una lista de palabras](#24-ejemplo-4-convertir-un-texto-en-una-lista-de-palabras)

---

## 1. Particularidades del comando tr

A diferencia de otros comandos, `tr` no acepta un nombre de archivo como argumento; solo lee desde la entrada estándar, por lo que casi siempre se usa junto con tuberías (`|`) o con redirección de entrada:

```bash
usuario@debian:~$ tr 'a-z' 'A-Z' < /etc/hostname
DEBIAN
```

> **Importante:** `tr` trabaja **carácter a carácter**, nunca con cadenas completas. Los dos conjuntos que recibe no son dos palabras a intercambiar, sino dos listas de caracteres que se emparejan por posición: el primero del conjunto 1 se sustituye por el primero del conjunto 2, el segundo por el segundo, y así sucesivamente.
>
> ```bash
> usuario@debian:~$ echo "abc" | tr 'abc' 'xyz'
> xyz
> usuario@debian:~$ echo "cab" | tr 'abc' 'xyz'
> zxy
> ```
>
> Por eso `tr 'hola' 'adios'` **no** cambia la palabra "hola" por "adios": sustituye cada `h` por una `a`, cada `o` por una `d`, cada `l` por una `i` y cada `a` por una `o`, y descarta la `s` sobrante. Para sustituir cadenas hay que recurrir a `sed`.

> **Nota:** Si el conjunto 2 es más corto que el conjunto 1, `tr` repite su último carácter hasta igualar la longitud. Así, `tr '[:lower:]' 'X'` convierte en `X` todas las minúsculas.

1. **Traducción de caracteres**: `tr` puede traducir un conjunto de caracteres a otro. Por ejemplo, puede convertir letras minúsculas en mayúsculas o viceversa.

```bash
usuario@debian:/tmp/prueba$  echo "Vamos a cambiar las a minusculas por mayusculas" | tr 'a' 'A'
VAmos A cAmbiAr lAs A minusculAs por mAyusculAs
```

2. **Eliminación de caracteres (`-d`)**: Usando la opción `-d`, `tr` puede eliminar caracteres específicos de la entrada.

```bash
usuario@debian:/tmp/prueba$  echo "Vamos a eliminar las letras a" | tr -d 'a'
Vmos  eliminr ls letrs
```

3. **Compresión de caracteres repetidos (`-s`)**: Con la opción `-s` (_squeeze_), `tr` puede comprimir secuencias repetidas de caracteres en uno solo.

```bash
usuario@debian:/tmp/prueba$  echo "A     A   A   B" | tr -s ' '
A A A B
```

4. **Uso de clases de caracteres**: `tr` permite el uso de clases de caracteres predefinidas POSIX como `[:upper:]` para letras mayúsculas, `[:lower:]` para letras minúsculas, `[:digit:]` para dígitos, etc.

```bash
usuario@debian:/tmp/prueba$  echo "Vamos a cambiar a mayusculas" | tr '[[:lower:]]' '[[:upper:]]'
VAMOS A CAMBIAR A MAYUSCULAS
```

> **Advertencia:** La forma correcta de escribir una clase POSIX en `tr` es con **un solo par de corchetes**: `tr '[:lower:]' '[:upper:]'`. Los corchetes exteriores ya forman parte de la propia clase, de modo que al duplicarlos, como en `'[[:lower:]]'`, los corchetes sobrantes se añaden a los conjuntos como caracteres más.
>
> En el ejemplo anterior el resultado sale bien por casualidad: ambos conjuntos ganan un `[` al principio y un `]` al final, que acaban traduciéndose a sí mismos. Pero en cuanto los conjuntos dejan de ser simétricos, el error aflora:
>
> ```bash
> usuario@debian:~$ echo "a1b[2]c3" | tr -d '[:digit:]'
> ab[]c
> usuario@debian:~$ echo "a1b[2]c3" | tr -d '[[:digit:]]'
> abc
> ```
>
> La segunda orden ha borrado también los corchetes del texto, que no eran dígitos. Conviene escribir siempre `'[:digit:]'`.

5. **Complemento del conjunto (`-c`)**: Con `-c`, `tr` actúa sobre todos los caracteres que **no** están en el conjunto indicado. Combinado con `-d`, es la forma habitual de depurar una entrada dejando únicamente los caracteres admitidos:

```bash
usuario@debian:~$ echo "Tel: +34 986-11-22-33" | tr -cd '[:digit:]\n'
34986112233
```

6. **Truncado del conjunto (`-t`)**: Por defecto, si el conjunto 1 es más largo, `tr` repite el último carácter del conjunto 2. La opción `-t` cambia ese comportamiento y descarta los caracteres sobrantes del conjunto 1:

```bash
usuario@debian:~$ echo "abcde" | tr 'abcde' 'xy'
xyyyy
usuario@debian:~$ echo "abcde" | tr -t 'abcde' 'xy'
xycde
```

### 1.1 Resumen de opciones

| Parámetro | Descripción |
|---|---|
| `-d` | (*Delete*) Elimina los caracteres del conjunto 1. No se indica conjunto 2. |
| `-s` | (*Squeeze*) Comprime en uno solo los caracteres repetidos consecutivos. |
| `-c` | (*Complement*) Opera sobre el complemento del conjunto 1, es decir, sobre todo lo que no aparece en él. |
| `-t` | (*Truncate*) Recorta el conjunto 1 a la longitud del conjunto 2 en lugar de repetir el último carácter. |

Además de las clases POSIX, `tr` entiende rangos con guion (`a-z`, `0-9`) y las secuencias de escape habituales:

| Secuencia | Carácter |
|---|---|
| `\n` | Salto de línea |
| `\t` | Tabulador |
| `\r` | Retorno de carro |
| `\0` | Byte nulo |
| `\\` | Barra invertida |

---

## 2. Ejemplos de interés

### 2.1 Ejemplo 1: conversión de formatos MAC

```bash
echo 'AA:BB:CC:DD:EE:FF' | tr '[[:upper:]]' '[[:lower:]]'
```

En este ejemplo:
- `echo 'AA:BB:CC:DD:EE:FF'` produce la cadena `'AA:BB:CC:DD:EE:FF'`.
- La tubería (`|`) pasa esta cadena como entrada a `tr`.
- `tr '[[:upper:]]' '[[:lower:]]'` traduce todas las letras mayúsculas a minúsculas usando clases POSIX.

El resultado será:

```bash
aa:bb:cc:dd:ee:ff
```

### 2.2 Ejemplo 2: limpieza de variables para scripts

```bash
linea='"user1","p1","/bin/bash","/tmp"'
user=$(echo ${linea} | tr -d '"' | cut -d',' -f1)
```

En este ejemplo de Bash:
1. `echo ${linea}` imprime el valor de la variable `linea`.
2. `tr -d '"'` elimina todos los caracteres de comillas dobles (`"`) del flujo.
3. `cut -d',' -f1` corta la cadena resultante en campos separados por comas (`,`) y selecciona el primer campo.

Por ejemplo, el flujo funciona así:
- `echo ${linea}` produce la cadena `'"user1","p1",...'`.
- `tr -d '"'` elimina las comillas dobles, produciendo `user1,p1,...`.
- `cut -d',' -f1` selecciona el primer campo, que es `user1`.

> **Nota:** Finalmente, el valor limpio `user1` se asigna a la variable `$user`, un patrón muy útil al parsear archivos CSV rudimentarios en scripts de automatización.

### 2.3 Ejemplo 3: conversión de finales de línea

Un fichero creado en Windows termina cada línea con dos caracteres, retorno de carro y salto de línea (`\r\n`), mientras que en Linux basta con el salto (`\n`). Ese `\r` sobrante provoca errores desconcertantes en los guiones, del tipo `bad interpreter: /bin/bash^M`. `tr` lo elimina en una sola orden:

```bash
usuario@debian:~$ tr -d '\r' < guion_windows.sh > guion_linux.sh
```

> **Recuerda:** Para detectar el problema basta con `file guion.sh`, que responderá `ASCII text, with CRLF line terminators`, o con `cat -A guion.sh`, que muestra cada `\r` como `^M`. La herramienta específica para esta conversión es `dos2unix`.

### 2.4 Ejemplo 4: convertir un texto en una lista de palabras

Combinando `tr` con `sort` y `uniq` se obtiene el recuento de frecuencia de palabras de un texto:

```bash
usuario@debian:~$ tr -cs '[:alpha:]' '\n' < texto.txt | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -rn | head -5
     42 de
     37 la
     29 el
     21 en
     18 que
```

El primer `tr` sustituye por saltos de línea todo lo que no sea una letra (`-c`) y comprime los saltos consecutivos (`-s`), de modo que cada palabra queda en su propia línea. El resto de la tubería es el idiom de recuento que se explicaba en el documento 08.
