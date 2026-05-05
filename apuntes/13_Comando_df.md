# Comando df

## Índice

1. [Opciones comunes](#1-opciones-comunes)
2. [Ejemplos de uso](#2-ejemplos-de-uso)

---

El comando `df` (_disk free_) en sistemas Unix/Linux se utiliza para mostrar el espacio disponible y utilizado en los sistemas de archivos montados. Proporciona información sobre el uso del disco a nivel de sistema de archivos.

> **Recuerda:** A diferencia de `du`, que calcula el espacio recursivamente para directorios y archivos específicos, `df` informa de las estadísticas generales de cada sistema de archivos montado.

---

## 1. Opciones comunes

Aquí te muestro cómo se usa y algunas de sus opciones más comunes:

| Parámetro | Descripción |
|-----------|-------------|
| `-h`      | Muestra los tamaños en un formato legible para humanos (por ejemplo, KB, MB, GB). |
| `-T`      | Muestra el tipo de sistema de archivos (ej. `ext4`, `tmpfs`). |
| `-i`      | Muestra información sobre el número de inodos utilizados y disponibles en lugar del espacio de disco. |

> **Nota:** Un inodo (inode) es una estructura de datos en los sistemas de archivos Unix que almacena metadatos sobre un archivo o directorio. Quedarse sin inodos (aunque haya espacio en disco) impedirá crear nuevos archivos.

---

## 2. Ejemplos de uso

Salida predeterminada del comando (espacio en bloques de 1K):

```bash
usuario@debian:~$ df
S.ficheros     bloques de 1K  Usados Disponibles Uso% Montado en
udev                 1971332       0     1971332   0% /dev
tmpfs                 400876    1184      399692   1% /run
/dev/sda1           50303512 5476028    42239736  12% /
tmpfs                2004368       0     2004368   0% /dev/shm
tmpfs                   5120       8        5112   1% /run/lock
tmpfs                 400872      64      400808   1% /run/user/112
tmpfs                 400872      56      400816   1% /run/user/1000
```

Formato legible para humanos con `-h`:

```bash
usuario@debian:~$ df -h
S.ficheros     Tamaño Usados  Disp Uso% Montado en
udev             1,9G      0  1,9G   0% /dev
tmpfs            392M   1,2M  391M   1% /run
/dev/sda1         48G   5,3G   41G  12% /
tmpfs            2,0G      0  2,0G   0% /dev/shm
tmpfs            5,0M   8,0K  5,0M   1% /run/lock
tmpfs            392M    64K  392M   1% /run/user/112
tmpfs            392M    56K  392M   1% /run/user/1000
```

Mostrando también el tipo de sistema de archivos con `-Th`:

```bash
usuario@debian:~$ df -Th
S.ficheros     Tipo     Tamaño Usados  Disp Uso% Montado en
udev           devtmpfs   1,9G      0  1,9G   0% /dev
tmpfs          tmpfs      392M   1,2M  391M   1% /run
/dev/sda1      ext4        48G   5,3G   41G  12% /
tmpfs          tmpfs      2,0G      0  2,0G   0% /dev/shm
tmpfs          tmpfs      5,0M   8,0K  5,0M   1% /run/lock
tmpfs          tmpfs      392M    64K  392M   1% /run/user/112
tmpfs          tmpfs      392M    56K  392M   1% /run/user/1000
```

Consultando la disponibilidad de inodos legibles para humanos con `-Thi`:

```bash
usuario@debian:~$ df -Thi
S.ficheros     Tipo     Nodos-i NUsados NLibres NUso% Montado en
udev           devtmpfs    482K     422    481K    1% /dev
tmpfs          tmpfs       490K     708    489K    1% /run
/dev/sda1      ext4        3,1M    167K    3,0M    6% /
tmpfs          tmpfs       490K       1    490K    1% /dev/shm
tmpfs          tmpfs       490K       4    490K    1% /run/lock
tmpfs          tmpfs        98K      80     98K    1% /run/user/112
tmpfs          tmpfs        98K      72     98K    1% /run/user/1000
```
