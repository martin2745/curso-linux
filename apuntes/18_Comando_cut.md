# Comando cut

## Índice

1. [Opciones principales](#1-opciones-principales)
2. [Ejemplos de uso](#2-ejemplos-de-uso)

---

## 1. Opciones principales

| Parámetro | Descripción |
|-----------|-------------|
| `-c`      | Selecciona caracteres específicos de cada línea en lugar de campos delimitados. Los números pueden ir separados por comas (posiciones exactas) o por guion (rangos). |
| `-d`      | Especifica el delimitador a utilizar para separar los campos en cada línea. Solo admite un carácter. Por defecto, `cut` utiliza el tabulador (`\t`). |
| `-f`      | Permite elegir las columnas (*fields*) que queremos que se muestren. Se selecciona igual que con la opción `-c` (comas o rangos). |
| `-b`      | Selecciona por posición de **byte**. Coincide con `-c` mientras el texto sea ASCII, pero difiere en cuanto hay caracteres acentuados, que en UTF-8 ocupan más de un byte. |
| `--complement` | Invierte la selección: muestra todo **salvo** los campos indicados. |
| `--output-delimiter=CAD` | Cambia el separador con el que se unen los campos en la salida, que por defecto es el mismo de entrada. |
| `-s`      | (*Only-delimited*) Descarta las líneas que no contengan el delimitador. Sin esta opción, `cut` las imprime íntegras. |

Ejemplos de estas tres últimas opciones:

```bash
usuario@debian:~$ cut -d ':' -f 1,7 --complement /etc/passwd | tail -1
x:1001:1001::/home/usuario
usuario@debian:~$ cut -d ':' -f 1,7 --output-delimiter=' usa ' /etc/passwd | tail -1
usuario usa /bin/bash
```

> **Advertencia:** La limitación más seria de `cut` es que su delimitador es **un único carácter** y no admite repeticiones. Con ficheros alineados mediante varios espacios, como la salida de `ls -l`, `df` o `ps`, cada espacio de más cuenta como un separador y genera campos vacíos, de modo que las columnas se descuadran:
>
> ```bash
> usuario@debian:~$ ls -l | cut -d ' ' -f 3
>
> usuario
> ```
>
> Para esos casos hay que recurrir a `awk`, cuyo separador por defecto es "cualquier secuencia de espacios o tabuladores" y resuelve el problema sin configuración alguna:
>
> ```bash
> usuario@debian:~$ ls -l | awk '{print $3}'
> usuario
> usuario
> ```
>
> Como regla práctica: `cut` para ficheros con un separador constante y explícito (`/etc/passwd`, CSV), y `awk` para salidas de comandos alineadas con espacios. El documento 19 desarrolla `awk` en detalle.

> **Nota:** `cut` no sabe reordenar los campos. Por mucho que se escriba `cut -d: -f7,1`, la salida respeta siempre el orden del fichero original y devuelve el campo 1 antes que el 7. Si hace falta invertir el orden, de nuevo la herramienta es `awk`: `awk -F: '{print $7, $1}'`.

---

## 2. Ejemplos de uso

Cortando por posición de caracteres (`-c`):

```bash
root@debian:~# cut -c 1-5,10- /etc/passwd | tail -1
usuar:1001:1001::/home/usuario:/bin/bash
root@debian:~# cat /etc/passwd | tail -1
usuario:x:1001:1001::/home/usuario:/bin/bash
```

Cortando por delimitador (`-d`) y campos específicos (`-f`):

```bash
root@debian:~# cut -d ':' -f 1,7 /etc/passwd | tail -1
usuario:/bin/bash

root@debian:~# cut -d ':' -f 1-3 /etc/passwd | tail -1
usuario:x:1001
```

Combinando `cut` con otras herramientas como `grep` y `wc`:

```bash
root@debian:~# cat /etc/passwd | cut -d: -f1,7 | grep -w /bin/bash | wc -l
3
root@debian:~# cat /etc/passwd | cut -d ":" -f1,7 | grep -w /bin/bash | cat -n
     1  root:/bin/bash
     2  vagrant:/bin/bash
     3  usuario:/bin/bash
```
