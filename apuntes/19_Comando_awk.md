# Comando awk

## Índice

1. [Sintaxis y conceptos básicos](#1-sintaxis-y-conceptos-básicos)
2. [Ejemplos de procesamiento con awk](#2-ejemplos-de-procesamiento-con-awk)
3. [Diferencias clave entre cut y awk](#3-diferencias-clave-entre-cut-y-awk)
4. [Variables internas NF y NR](#4-variables-internas-nf-y-nr)

---

`awk` es un lenguaje de programación de patrones y acciones que se utiliza para el procesamiento avanzado de texto. Aunque es más poderoso y versátil que `cut`, también puede ser más complejo de usar. 

---

## 1. Sintaxis y conceptos básicos

Su sintaxis básica es:

```bash
awk '{patrón}' archivo
```

- `{patrón}`: Especifica el patrón que `awk` buscará en cada línea del archivo y qué acciones tomará cuando encuentre una línea que coincida.
- `archivo`: Es el archivo que se va a procesar.

Por ejemplo, para imprimir el primer y segundo campo de cada línea de un archivo, puedes usar:

```bash
awk -F'addr:' '{print $2 " y " $1}' archivo.txt
```

El comando de `awk` anterior realiza lo siguiente:

- `awk`: Es el comando que invoca el intérprete para procesar el texto.
- `-F'addr:'`: La opción `-F` especifica el delimitador de campo. En este caso, se establece como `'addr:'`, lo que significa que dividirá cada línea en campos cada vez que encuentre dicha cadena.
- `'{print $2 $1}'`: Esta es la acción que se tomará. `$2` hace referencia al segundo campo y `$1` al primero tras dividir por el delimitador. La acción `print` imprime los campos especificados de forma contigua si no se separan.

Si tenemos una línea de entrada como esta:

```text
addr:192.168.1.1
```

El comando separará esta línea en dos campos: vacío (o espacio anterior) y `192.168.1.1`. Al imprimir `$2 $1`, producirá la salida invertida.

> **Nota:** Este comando puede ser muy útil para cambiar el orden o el formato de los campos en líneas de texto que siguen un patrón específico, manipulando libremente el orden de impresión de las variables de columna `$N`.

---

## 2. Ejemplos de procesamiento con awk

`awk` es sumamente interesante para poder extraer directamente la última columna de una salida sin importar cuántas columnas haya en total en cada línea, haciendo uso de la variable `$NF`.

```bash
usuario@debian:~$ cat /etc/passwd | awk -F ':' '{print $NF}'
/bin/bash
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/bin/sync
```

Veamos otro ejemplo, esta vez combinando `awk` con el comando `rev` que permite invertir el orden de los caracteres de un texto:

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

---

## 3. Diferencias clave entre cut y awk

> **Importante:** Es crucial tener en cuenta que, aunque tanto `cut` como `awk` permiten separar un texto por un delimitador, en la salida `cut` **conservará el separador**, a diferencia de `awk` **que eliminará el separador** (a menos que lo incluyas manualmente en el bloque `print`).

A continuación demostramos esta diferencia de comportamiento:

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

---

## 4. Variables internas NF y NR

`awk` cuenta con diversas variables reservadas que facilitan el procesamiento del flujo.

> **Recuerda:** Diferencia vital entre `NF` (Number of Fields) y `NR` (Number of Records) en awk:

| Variable | Significado                           | Uso común                                    |
| -------- | ------------------------------------- | -------------------------------------------- |
| `NR`     | Número de la línea o registro actual  | Numerar líneas, filtrar líneas específicas o procesar por rango de líneas |
| `NF`     | Número total de columnas en la línea actual | Acceder a la última columna con `$NF`, contar columnas |
