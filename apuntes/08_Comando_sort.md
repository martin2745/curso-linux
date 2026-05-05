# Comando sort

## Índice

1. [Parámetros principales](#1-parámetros-principales)
2. [El comando uniq](#2-el-comando-uniq)
3. [Ejemplos de uso avanzado](#3-ejemplos-de-uso-avanzado)

---

El comando `sort` ordena líneas de texto en un archivo o entrada estándar según un criterio específico, como orden alfabético (predeterminado) o numérico. 

> **Recuerda:** Este comando es muy útil en combinación con tuberías (`|`) para procesar salidas de otros comandos, como `ls`, `ps` o `du`, permitiendo organizar la información antes de mostrarla o procesarla.

---

## 1. Parámetros principales

1. `-k`: indica la columna por la que se realiza la ordenación.

```bash
usuario@debian:/tmp/prueba$ echo -e "1 2 3 4 \n4 3 2 1\n11 22 33 44" | sort -k1
1 2 3 4
11 22 33 44
4 3 2 1
```

| Parámetro | Descripción |
|-----------|-------------|
| `-k` | Ordena utilizando una clave o columna específica, separadas por espacios por defecto. |

2. `-n`: Indica que se debe realizar una ordenación numérica en lugar de una ordenación alfabética.

```bash
usuario@debian:/tmp/prueba$ echo -e "1 2 3 4 \n4 3 2 1\n11 22 33 44" | sort -k1n
1 2 3 4
4 3 2 1
11 22 33 44
```

| Parámetro | Descripción |
|-----------|-------------|
| `-n` | Trata el inicio de cada línea como una cadena numérica y la ordena según su valor aritmético. |

3. `-t`: Establece el delimitador.

```bash
usuario@debian:/tmp/prueba$ echo -e "1,2,3,4 \n4,3,2,1\n11,22,33,44" | sort -t',' -k1n
1,2,3,4
4,3,2,1
11,22,33,44
```

| Parámetro | Descripción |
|-----------|-------------|
| `-t` | Define el carácter que separa las columnas. Útil para archivos CSV o como `/etc/passwd`. |

4. `-f`: Ignora diferencia entre mayúsculas y minúsculas.

```bash
usuario@debian:/tmp/prueba$ echo -e "1 2 3 A\n4 3 2 a" | sort -k4 -f
1 2 3 A
4 3 2 a

usuario@debian:/tmp/prueba$ echo -e "1 2 3 a\n4 3 2 A" | sort -k4 -f
1 2 3 a
4 3 2 A
```

| Parámetro | Descripción |
|-----------|-------------|
| `-f` | Considera iguales las mayúsculas y minúsculas durante la ordenación. |

5. `-r`: Realiza la ordenación inversa.

```bash
usuario@debian:/tmp/prueba$ echo -e "a b c\nA B C" | sort -k1
a b c
A B C

usuario@debian:/tmp/prueba$ echo -e "a b c\nA B C" | sort -k1 -r
A B C
a b c
```

| Parámetro | Descripción |
|-----------|-------------|
| `-r` | Revierte el resultado de las comparaciones (orden descendente). |

6. `-u`: Ignora duplicados. Lo que significa que da el mismo resultado que utilizar el comando `uniq`.

```bash
usuario@debian:/tmp/prueba$ echo -e "a b c\nA B C\na b c" | sort -u
a b c
A B C
```

| Parámetro | Descripción |
|-----------|-------------|
| `-u` | Imprime solo las líneas que son únicas basándose en el criterio de ordenación. |

---

## 2. El comando uniq

> **Nota:** Como comando complementario, `uniq` tiene los siguientes parámetros a destacar:

- `-d`: Imprime solo renglones duplicados.
- `-u`: Elimina lineas consecutivas iguales (imprime únicas).
- `-c`: Cuenta el número de ocurrencias de cada línea.
- `-i`: Considera iguales las mayúsculas y minúsculas.

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
