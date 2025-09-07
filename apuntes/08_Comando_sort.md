# Comando sort

El comando sort ordena líneas de texto en un archivo o entrada estándar según un criterio específico, como orden alfabético (predeterminado) o numérico. Parámetros:

1. -k: indica la columna por la que se realiza la ordenación.

```bash
usuario@debian:/tmp/prueba$ echo -e "1 2 3 4 \n4 3 2 1\n11 22 33 44" | sort -k1
1 2 3 4
11 22 33 44
4 3 2 1
```

2. -n: Indica que se debe realizar una ordenación numérica en lugar de una ordenación alfabética.

```bash
usuario@debian:/tmp/prueba$ echo -e "1 2 3 4 \n4 3 2 1\n11 22 33 44" | sort -k1n
1 2 3 4
4 3 2 1
11 22 33 44
```

3. -t: Establece el delimitador.

```bash
usuario@debian:/tmp/prueba$ echo -e "1,2,3,4 \n4,3,2,1\n11,22,33,44" | sort -t',' -k1n
1,2,3,4
4,3,2,1
11,22,33,44
```

4. -f: Ignora diferencia entre mayúsculas y minúsculas.

```bash
usuario@debian:/tmp/prueba$ echo -e "1 2 3 A\n4 3 2 a" | sort -k4 -f
1 2 3 A
4 3 2 a

usuario@debian:/tmp/prueba$ echo -e "1 2 3 a\n4 3 2 A" | sort -k4 -f
1 2 3 a
4 3 2 A
```

5. -r: Realiza la ordenación inversa.

```bash
usuario@debian:/tmp/prueba$ echo -e "a b c\nA B C" | sort -k1
a b c
A B C

usuario@debian:/tmp/prueba$ echo -e "a b c\nA B C" | sort -k1 -r
A B C
a b c
```

6. -u: Ignora duplicados. Lo que significa que da el mismo resultado que utilizar el comando _uniq_.

```bash
usuario@debian:/tmp/prueba$ echo -e "a b c\nA B C\na b c" | sort -u
a b c
A B C
```

_*Nota*_: Como comando _uniq_ tiene los siguientes parámetros a destacar:

- _-dimprime_: Ignorá renglones duplicados.
- _-u_: Elimina lineas consecutivas iguales.
- _-c_: Cuenta el número de ocurrencias.
- _-i_: Considera iguales las mayúsculas y minúsculas.

Otros

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
