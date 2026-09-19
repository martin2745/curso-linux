# Comando awk

## Índice

1. [Sintaxis y conceptos básicos](#1-sintaxis-y-conceptos-básicos)
2. [Ejemplos de procesamiento con awk](#2-ejemplos-de-procesamiento-con-awk)
3. [Diferencias clave entre cut y awk](#3-diferencias-clave-entre-cut-y-awk)
4. [Variables internas NF y NR](#4-variables-internas-nf-y-nr)
5. [Patrones y bloques BEGIN y END](#5-patrones-y-bloques-begin-y-end)

---

## 1. Sintaxis y conceptos básicos

Su sintaxis básica es:

```bash
awk 'patrón { acción }' archivo
```

- `patrón`: Condición que se evalúa para **cada línea** del fichero. Puede ser una expresión regular entre barras (`/error/`), una comparación (`$3 > 100`), una de las palabras reservadas `BEGIN` o `END`, o nada en absoluto.
- `{ acción }`: Lo que se ejecuta sobre las líneas que cumplan el patrón. Va **siempre entre llaves**.
- `archivo`: El fichero que se va a procesar. Si se omite, `awk` lee de la entrada estándar.

> **Importante:** Los dos elementos son opcionales, y de ahí nacen las tres formas que se ven a diario:
>
> | Forma | Comportamiento |
> |---|---|
> | `awk '{ print $1 }'` | Sin patrón: la acción se aplica a **todas** las líneas. |
> | `awk '/error/'` | Sin acción: se imprimen íntegras las líneas que cumplan el patrón, igual que hace `grep`. |
> | `awk '/error/ { print $1 }'` | Ambos: la acción se aplica solo a las líneas coincidentes. |

> **Recuerda:** `awk` divide automáticamente cada línea en campos y los numera desde `$1`. La variable `$0` contiene la **línea completa**, sin dividir. Por defecto el separador de campos es cualquier secuencia de espacios o tabuladores, lo que hace que las columnas queden bien alineadas aunque el número de espacios varíe.

Por ejemplo, para imprimir el primer y segundo campo de cada línea de un archivo, puedes usar:

```bash
awk -F'addr:' '{print $2 " y " $1}' archivo.txt
```

El comando de `awk` anterior realiza lo siguiente:

- `awk`: Es el comando que invoca el intérprete para procesar el texto.
- `-F'addr:'`: La opción `-F` especifica el delimitador de campo. En este caso, se establece como `'addr:'`, lo que significa que dividirá cada línea en campos cada vez que encuentre dicha cadena.
- `'{print $2 " y " $1}'`: Esta es la acción que se tomará. `$2` hace referencia al segundo campo y `$1` al primero tras dividir por el delimitador. Entre ambos se intercala la cadena literal `" y "`, que `print` imprime tal cual.

Si tenemos una línea de entrada como esta:

```text
addr:192.168.1.1
```

El comando separará esta línea en dos campos: el primero queda vacío, porque antes del delimitador no hay nada, y el segundo es `192.168.1.1`. Al imprimir `$2 " y " $1` se obtiene la salida en orden invertido.

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

> **Importante:** Aunque tanto `cut` como `awk` permiten trocear un texto por un delimitador, el resultado que imprimen es distinto: `cut` **reconstruye la salida con el mismo delimitador** que usó para separar, mientras que `awk` deja en manos de quien escribe el `print` cómo unir los campos.

La diferencia no está en que `awk` "elimine" nada, sino en cómo se escribe la instrucción `print`, y merece la pena entenderlo porque es la fuente de confusión más habitual al empezar:

| Instrucción | Resultado | Motivo |
|---|---|---|
| `print $1 $6` | `colord/var/lib/colord` | Dos campos escritos uno detrás de otro **sin coma** se concatenan directamente, sin nada en medio. |
| `print $1, $6` | `colord /var/lib/colord` | La **coma** indica a `awk` que intercale el separador de salida `OFS`, que por defecto es un espacio. |
| `print $1 ":" $6` | `colord:/var/lib/colord` | Se intercala expresamente la cadena literal deseada. |

De modo que para reproducir exactamente la salida de `cut` basta con fijar el separador de salida:

```bash
usuario@debian:~$ tail -3 /etc/passwd | awk -F ':' -v OFS=':' '{print $1, $6, $7}'
vboxadd:/var/run/vboxadd:/bin/false
sshd:/run/sshd:/usr/sbin/nologin
mysql:/nonexistent:/bin/false
```

> **Nota:** El camino inverso también existe: `cut` admite `--output-delimiter` para cambiar con qué carácter une los campos de salida. Por ejemplo, `cut -d: -f1,6 --output-delimiter=' -> ' /etc/passwd`.

A continuación demostramos esta diferencia de comportamiento con el ejemplo original:


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
| `FS`     | Separador de campos de **entrada** | Equivale a la opción `-F`. Se fija con `-v FS=':'` o dentro de un bloque `BEGIN`. |
| `OFS`    | Separador de campos de **salida** | Lo que `print` intercala donde haya una coma. Por defecto, un espacio. |
| `RS` / `ORS` | Separador de registros de entrada y de salida | Por defecto el salto de línea. Cambiar `RS` permite procesar párrafos o registros multilínea. |
| `FILENAME` | Nombre del fichero que se está procesando | Útil al pasarle varios ficheros a la vez. |

> **Advertencia:** No deben confundirse `$NF` y `NF`. `NF` es **el número** de campos de la línea (por ejemplo, 7); `$NF` es **el contenido** del último campo. Del mismo modo, `$(NF-1)` devuelve el penúltimo campo, mientras que `$NF-1` restaría uno al valor del último campo, que es algo muy distinto.

---

## 5. Patrones y bloques BEGIN y END

Además de procesar línea a línea, `awk` admite dos patrones especiales que se ejecutan una única vez: `BEGIN`, antes de leer nada, y `END`, tras procesar la última línea. Son los que convierten a `awk` en una herramienta de cálculo y no solo de recorte.

```bash
usuario@debian:~$ awk -F ':' 'BEGIN { print "USUARIO\tSHELL" } { print $1 "\t" $7 } END { print "Total: " NR " cuentas" }' /etc/passwd
USUARIO	SHELL
root	/bin/bash
daemon	/usr/sbin/nologin
...
Total: 25 cuentas
```

Filtrado por condición, que es donde `awk` supera con claridad a `cut`:

```bash
usuario@debian:~$ awk -F ':' '$3 >= 1000 { print $1, $3 }' /etc/passwd
nobody 65534
usuario 1000
usuario@debian:~$ awk -F ':' '$7 == "/bin/bash" { print $1 }' /etc/passwd
root
usuario
usuario@debian:~$ awk 'NR >= 3 && NR <= 6' /etc/passwd
```

> **Recuerda:** `cut` no sabe comparar: solo puede recortar posiciones fijas. En cuanto la tarea consista en *seleccionar filas según el valor de una columna*, o en *sumar, contar o promediar*, la herramienta adecuada es `awk`.

Suma y promedio de una columna, el uso que justifica por sí solo aprender `awk`:

```bash
usuario@debian:~$ ls -l | awk '{ suma += $5 } END { print "Bytes en total:", suma }'
Bytes en total: 24576
usuario@debian:~$ df -h | awk 'NR > 1 { print $6, $5 }'
/dev 0%
/run 1%
/ 12%
```

> **Nota:** El separador de campos también puede fijarse dentro de un bloque `BEGIN`, lo que resulta más legible en guiones largos: `awk 'BEGIN { FS=":"; OFS=" -> " } { print $1, $7 }' /etc/passwd`.
