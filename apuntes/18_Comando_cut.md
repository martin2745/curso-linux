# Comando cut

## Índice

1. [Opciones principales](#1-opciones-principales)
2. [Ejemplos de uso](#2-ejemplos-de-uso)

---

El comando `cut` se utiliza para cortar secciones específicas de cada línea de un archivo de texto. Su sintaxis básica es:

```bash
cut [opciones] archivo
```

> **Recuerda:** `cut` es especialmente útil cuando se procesan archivos estructurados como CSVs o `/etc/passwd`, donde la información está tabulada o separada por un carácter delimitador constante.

---

## 1. Opciones principales

| Parámetro | Descripción |
|-----------|-------------|
| `-c`      | Selecciona caracteres específicos de cada línea en lugar de campos delimitados. Los números pueden ir separados por comas (posiciones exactas) o por guion (rangos). |
| `-d`      | Especifica el delimitador a utilizar para separar los campos en cada línea. Solo admite un carácter. Por defecto, `cut` utiliza el tabulador (`\t`). |
| `-f`      | Permite elegir las columnas (fields) que queremos que se muestren. Se selecciona igual que con la opción `-c` (comas o rangos). |

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
