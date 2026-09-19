# Comando sort

## Índice

1. [Parámetros principales](#1-parámetros-principales)
2. [El comando uniq](#2-el-comando-uniq)
3. [Ejemplos de uso avanzado](#3-ejemplos-de-uso-avanzado)

---

## 1. Parámetros principales

| Parámetro | Descripción |
|-----------|-------------|
| `-k CAMPO` | Ordena utilizando el campo indicado como clave, en lugar de la línea completa. |
| `-n` | Ordenación numérica: interpreta el campo como un número y lo compara por su valor aritmético. |
| `-h` | Ordenación numérica con sufijos legibles (`2K`, `1M`, `3G`). Es el complemento natural de `du -h` y `ls -lh`. |
| `-V` | Ordenación por número de versión, de forma que `1.10` queda después de `1.9`. |
| `-t CAR` | Define el carácter que separa los campos. Imprescindible en CSV o en `/etc/passwd`. |
| `-f` | Considera iguales mayúsculas y minúsculas durante la ordenación. |
| `-r` | Invierte el resultado de las comparaciones (orden descendente). |
| `-u` | Descarta las líneas duplicadas según la clave de ordenación, dejando solo la primera de cada grupo. |
| `-b` | Ignora los espacios iniciales de cada campo, que de otro modo cuentan como parte del valor. |
| `-s` | Ordenación estable: mantiene el orden original entre las líneas cuya clave coincide. |
| `-c` | No ordena: solo comprueba si la entrada ya estaba ordenada e informa de la primera línea que incumple. |
| `-o FICHERO` | Escribe el resultado en el fichero indicado. Admite con seguridad el mismo fichero de entrada. |
| `-R` | Ordenación aleatoria: baraja las líneas. |

> **Advertencia:** El orden alfabético depende del *locale*. Con `LANG=es_ES.UTF-8` las mayúsculas y minúsculas se intercalan y se ignoran algunos signos de puntuación, mientras que con `LC_ALL=C` se ordena estrictamente por el valor de cada byte, de modo que todas las mayúsculas preceden a las minúsculas. Si un script debe dar siempre el mismo resultado, conviene forzar `LC_ALL=C sort`.

A continuación se detalla cada parámetro con un ejemplo.

1. `-k`: indica el campo por el que se realiza la ordenación.

```bash
usuario@debian:/tmp/prueba$ echo -e "1 2 3 4 \n4 3 2 1\n11 22 33 44" | sort -k1
1 2 3 4
11 22 33 44
4 3 2 1
```

> **Importante:** `-k1` no significa "ordena por la primera columna". Significa "usa como clave desde el principio del campo 1 **hasta el final de la línea**". Para limitar la clave a una única columna hay que indicar principio y fin: `-k1,1`. La diferencia se nota cuando la primera columna tiene valores repetidos, porque con `-k1` el desempate lo deciden las columnas siguientes y con `-k1,1` no.
>
> ```bash
> usuario@debian:/tmp/prueba$ printf 'b 2\nb 1\na 3\n' | sort -k1,1
> a 3
> b 2
> b 1
> ```


2. `-n`: Indica que se debe realizar una ordenación numérica en lugar de una ordenación alfabética.

```bash
usuario@debian:/tmp/prueba$ echo -e "1 2 3 4 \n4 3 2 1\n11 22 33 44" | sort -k1n
1 2 3 4
4 3 2 1
11 22 33 44
```


3. `-t`: Establece el delimitador.

```bash
usuario@debian:/tmp/prueba$ echo -e "1,2,3,4 \n4,3,2,1\n11,22,33,44" | sort -t',' -k1n
1,2,3,4
4,3,2,1
11,22,33,44
```


4. `-f`: Ignora diferencia entre mayúsculas y minúsculas.

```bash
usuario@debian:/tmp/prueba$ echo -e "1 2 3 A\n4 3 2 a" | sort -k4 -f
1 2 3 A
4 3 2 a

usuario@debian:/tmp/prueba$ echo -e "1 2 3 a\n4 3 2 A" | sort -k4 -f
1 2 3 a
4 3 2 A
```


5. `-r`: Realiza la ordenación inversa.

```bash
usuario@debian:/tmp/prueba$ echo -e "a b c\nA B C" | sort -k1
a b c
A B C

usuario@debian:/tmp/prueba$ echo -e "a b c\nA B C" | sort -k1 -r
A B C
a b c
```


6. `-u`: Descarta los duplicados durante la ordenación.

```bash
usuario@debian:/tmp/prueba$ echo -e "a b c\nA B C\na b c" | sort -u
a b c
A B C
```

> **Advertencia:** `sort -u` **no** es equivalente a `uniq`. Son dos operaciones distintas:
>
> - `sort -u` elimina duplicados en todo el fichero, estén donde estén, y decide qué es un duplicado según la **clave de ordenación**. Con `sort -u -k2,2` se descartarían líneas enteramente distintas por el simple hecho de compartir la segunda columna.
> - `uniq` solo compara cada línea con la **inmediatamente anterior**, y ofrece opciones que `sort` no tiene, como contar repeticiones (`-c`) o mostrar exclusivamente las líneas repetidas (`-d`).
>
> La equivalencia `sort fichero | uniq` ≡ `sort -u fichero` solo se cumple en el caso más simple: sin `-k` y sin ninguna opción de `uniq`.


---

## 2. El comando uniq

El comando `uniq` actúa sobre líneas **consecutivas** iguales. Invocado sin opciones, colapsa cada grupo de repeticiones en una sola línea.

| Parámetro | Descripción |
|---|---|
| (sin opciones) | Colapsa cada grupo de líneas consecutivas idénticas en una sola aparición. |
| `-c` | (*Count*) Antepone a cada línea el número de veces que aparecía repetida. |
| `-d` | (*Duplicated*) Muestra únicamente las líneas que estaban repetidas, una vez cada una. |
| `-D` | Muestra **todas** las apariciones de las líneas repetidas, no solo una. |
| `-u` | (*Unique*) Muestra únicamente las líneas que aparecían una sola vez, descartando por completo las repetidas. |
| `-i` | Considera iguales mayúsculas y minúsculas. |
| `-f N` | Ignora los `N` primeros campos al comparar. |
| `-s N` | Ignora los `N` primeros caracteres al comparar. |

> **Advertencia:** No deben confundirse `uniq` sin opciones y `uniq -u`. El primero deja **una** copia de cada línea, incluidas las que estaban repetidas. El segundo **descarta** las repetidas y deja solo las que apenas aparecían una vez.

El siguiente ejemplo muestra las tres variantes sobre la misma entrada:

```bash
usuario@debian:~$ printf 'pera\npera\nuva\n' | uniq
pera
uva
usuario@debian:~$ printf 'pera\npera\nuva\n' | uniq -d
pera
usuario@debian:~$ printf 'pera\npera\nuva\n' | uniq -u
uva
```

El uso más frecuente en administración de sistemas es el recuento ordenado de ocurrencias, combinando `sort`, `uniq -c` y de nuevo `sort -rn`. Por ejemplo, para ver qué intérpretes de comandos se usan en el sistema y cuántas cuentas tiene cada uno:

```bash
usuario@debian:~$ cut -d: -f7 /etc/passwd | sort | uniq -c | sort -rn
     22 /usr/sbin/nologin
      3 /bin/bash
      2 /bin/sync
      1 /bin/false
```

> **Importante:** El comando `uniq` solo detecta duplicados si están en líneas consecutivas. Por ello, suele ser necesario ejecutar `sort` primero y pasar su salida a `uniq` (ej. `sort archivo | uniq -c`).

---

## 3. Ejemplos de uso avanzado

A continuación se muestra la diferencia entre ordenar la misma columna con y sin el modificador numérico:

```bash
usuario@debian:/tmp/prueba$ echo -e "1 2 3 A\n4 3 2 a\n1 2 3 4" | sort -k4
1 2 3 4
4 3 2 a
1 2 3 A

usuario@debian:/tmp/prueba$ echo -e "1 2 3 A\n4 3 2 a\n1 2 3 4" | sort -k4n
1 2 3 A
4 3 2 a
1 2 3 4
```

> **Nota:** Observa cómo al añadir el flag `-n`, `sort` evalúa el valor numérico para determinar el orden, dejando las letras al principio en este caso.
