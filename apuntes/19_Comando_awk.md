# Comando awk

`awk` es un lenguaje de programación de patrones y acciones que se utiliza para el procesamiento de texto. Aunque es más poderoso y versátil que `cut`, también puede ser más complejo de usar. Su sintaxis básica es:

```bash
awk '{patrón}' archivo
```

- `{patrón}`: Especifica el patrón que `awk` buscará en cada línea del archivo y qué acciones tomará cuando encuentre una línea que coincida con el patrón.
- `archivo`: Es el archivo que se va a procesar.

Por ejemplo, para imprimir el primer campo de cada línea de un archivo, puedes usar:

```bash
awk -F'addr:' '{print $2 " y " $1}' archivo.txt
```

El comando de `awk` anterior realiza:

- `awk`: Es el comando `awk` que invoca el intérprete de `awk` para procesar el texto.
- `-F'addr:'`: La opción `-F` especifica el delimitador de campo utilizado por `awk`. En este caso, se establece como `'addr:'`, lo que significa que `awk` dividirá cada línea de entrada en campos cada vez que encuentre la cadena `'addr:'`.
- `' {print $2 $1}'`: Esta es la acción que `awk` tomará en cada línea de entrada. En este caso, `$2` hace referencia al segundo campo y `$1` al primer campo después de dividir la línea según el delimitador especificado. La acción `print` imprime los campos especificados. Al imprimir `$2` antes de `$1` y no separarlos con una coma ni espacio, se concatenarán los campos sin ningún espacio adicional entre ellos.
- `awk` es muy interesante para poder mostrar la última columna si no sabemos en que posicióne está con el valor `$NF`.

```bash
usuario@debian:~$ cat /etc/passwd | awk -F ':' '{print $NF}'
/bin/bash
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/bin/sync
```

Por ejemplo, si tenemos una línea de entrada como esta:

```
addr:192.168.1.1
```

El comando `awk` separará esta línea en dos campos: "addr" y "192.168.1.1". Luego, al imprimir `$2 $1`, producirá la salida:

```
192.168.1.1addr:
```

Lo que significa que `$2` se colocará antes que `$1`, y no habrá espacio ni otro carácter entre ellos.

Este comando puede ser útil para cambiar el orden o el formato de los campos en líneas de texto que siguen un patrón específico, como en este caso, donde se manipula una dirección IP precedida por la etiqueta "addr:".

_*Nota:*_ Es importante tener en cuenta que `cut` y `awk` permite separar por un campo pero en la salida `cut` **conservará el separador** a diferencia de `awk` **que eliminará el separador**, tal y como podemos ver a continuación.

```bash
usuario@debian:~/scripts$ cat script.sh
#!/bin/bash

echo "----- SALIDA DE CUT -----"

tail /etc/passwd | cut -d ':' -f1,6,7

echo -e '\n\n\n'

echo "----- SALIDA DE AWK -----"

tail /etc/passwd | awk -F ':' '{print $1 $6 $NF}'
```

```bash
usuario@debian:~/scripts$ bash script.sh
----- SALIDA DE CUT -----
colord:/var/lib/colord:/usr/sbin/nologin
geoclue:/var/lib/geoclue:/usr/sbin/nologin
pulse:/run/pulse:/usr/sbin/nologin
gnome-initial-setup:/run/gnome-initial-setup/:/bin/false
hplip:/run/hplip:/bin/false
gdm:/var/lib/gdm3:/bin/false
si:/home/si:/bin/bash
vboxadd:/var/run/vboxadd:/bin/false
sshd:/run/sshd:/usr/sbin/nologin
mysql:/nonexistent:/bin/false

----- SALIDA DE AWK -----
colord/var/lib/colord/usr/sbin/nologin
geoclue/var/lib/geoclue/usr/sbin/nologin
pulse/run/pulse/usr/sbin/nologin
gnome-initial-setup/run/gnome-initial-setup//bin/false
hplip/run/hplip/bin/false
gdm/var/lib/gdm3/bin/false
si/home/si/bin/bash
vboxadd/var/run/vboxadd/bin/false
sshd/run/sshd/usr/sbin/nologin
mysql/nonexistent/bin/false
```

Veamos otro ejemplo, esta vez tambien hacemos uso del comando `rev` que permite invertir el orden del resultado.

```bash
usuario@debian:~$ ls -l | awk -F ' ' '{print $NF}'
40
Desktop
Documents
Downloads
Music
Pictures
prueba
Public
snap
Templates
Videos

usuario@debian:~$ ls -l | awk -F ' ' '{print $NF}' | rev
04
potkseD
stnemucoD
sdaolnwoD
cisuM
serutciP
abeurp
cilbuP
pans
setalpmeT
soediV
```

_*Nota*_: Diferencia entre `NF` y `NR` en awk.

| Variable | Significado                           | Uso común                                    |
| -------- | ------------------------------------- | -------------------------------------------- |
| `NR`     | Número de la línea actual             | Numerar líneas, filtrar líneas específicas   |
| `NF`     | Número de columnas en la línea actual | Acceder a la última columna, contar columnas |
