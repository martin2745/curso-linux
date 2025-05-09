# Comando sort

El comando sort ordena líneas de texto en un archivo o entrada estándar según un criterio específico, como orden alfabético (predeterminado) o numérico. Parámetros:

1. -k: indica la columna por la que se realiza la ordenación.

```bash
martin@debian12:/tmp/prueba$ echo -e "1 2 3 4 \n4 3 2 1\n11 22 33 44" | sort -k1
1 2 3 4
11 22 33 44
4 3 2 1
```

2. -n: Indica que se debe realizar una ordenación numérica en lugar de una ordenación alfabética.

```bash
martin@debian12:/tmp/prueba$ echo -e "1 2 3 4 \n4 3 2 1\n11 22 33 44" | sort -k1n
1 2 3 4
4 3 2 1
11 22 33 44
```

3. -t: Establece el delimitador.

```bash
martin@debian12:/tmp/prueba$ echo -e "1,2,3,4 \n4,3,2,1\n11,22,33,44" | sort -t',' -k1n
1,2,3,4
4,3,2,1
11,22,33,44
```

4. -f: Ignora diferencia entre mayúsculas y minúsculas.

```bash
martin@debian12:/tmp/prueba$ echo -e "1 2 3 A\n4 3 2 a" | sort -k4 -f
1 2 3 A
4 3 2 a

martin@debian12:/tmp/prueba$ echo -e "1 2 3 a\n4 3 2 A" | sort -k4 -f
1 2 3 a
4 3 2 A
```

5. -r: Realiza la ordenación inversa.

```bash
martin@debian12:/tmp/prueba$ echo -e "a b c\nA B C" | sort -k1
a b c
A B C

martin@debian12:/tmp/prueba$ echo -e "a b c\nA B C" | sort -k1 -r
A B C
a b c
```

6. -u: Ignora duplicados. Lo que significa que da el mismo resultado que utilizar el comando *uniq*.

```bash
martin@debian12:/tmp/prueba$ echo -e "a b c\nA B C\na b c" | sort -u
a b c
A B C
```

_*Nota*_: Como comando *uniq* tiene los siguientes parámetros a destacar:
- *-dimprime*: Ignorá renglones duplicados.
- *-u*: Elimina lineas consecutivas iguales.
- *-c*: Cuenta el número de ocurrencias.
- *-i*: Considera iguales las mayúsculas y minúsculas.

Otros

```bash
martin@debian12:/tmp/prueba$ echo -e "1 2 3 A\n4 3 2 a\n1 2 3 4" | sort -k4
1 2 3 4
4 3 2 a
1 2 3 A

martin@debian12:/tmp/prueba$ echo -e "1 2 3 A\n4 3 2 a\n1 2 3 4" | sort -k4n
1 2 3 A
4 3 2 a
1 2 3 4


root@debian:~# du / > /tmp/size_bytes
root@debian:~# wc /tmp/size_bytes
 14532  29069 587487 /tmp/size_bytes
root@debian:~# sort -n /tmp/size_bytes
root@debian:~# sort -h /tmp/size_bytes

root@debian:~# sort -t ':' -k 1 /etc/passwd | tail -3
vagrant:x:1000:1000:vagrant,,,:/home/vagrant:/bin/bash
vboxadd:x:999:1::/var/run/vboxadd:/bin/false
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
```