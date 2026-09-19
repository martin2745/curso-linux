# Comando df

## Índice

1. [Opciones comunes](#1-opciones-comunes)
2. [Ejemplos de uso](#2-ejemplos-de-uso)
3. [Cuando df y du no coinciden](#3-cuando-df-y-du-no-coinciden)

---

## 1. Opciones comunes

Aquí te muestro cómo se usa y algunas de sus opciones más comunes:

| Parámetro | Descripción |
|-----------|-------------|
| `-h`      | Muestra los tamaños en un formato legible para humanos (por ejemplo, KB, MB, GB). |
| `-T`      | Muestra el tipo de sistema de archivos (ej. `ext4`, `tmpfs`). |
| `-i`      | Muestra información sobre el número de inodos utilizados y disponibles en lugar del espacio de disco. |
| `-a`      | Incluye también los sistemas de ficheros seudo, duplicados e inaccesibles, que por defecto se ocultan. |
| `-x TIPO` | Excluye del listado los sistemas de ficheros del tipo indicado. `df -x tmpfs -x devtmpfs` deja a la vista solo el almacenamiento real. |
| `-t TIPO` | Lo contrario: muestra únicamente los sistemas de ficheros del tipo indicado, por ejemplo `df -t ext4`. |
| `--total` | Añade una fila final con la suma de todas las columnas. |
| `-H`      | Como `-h`, pero calculando en potencias de 1000 (1 MB = 1.000.000 bytes) en lugar de 1024. Es el criterio que emplean los fabricantes de discos. |
| `-P`      | Formato POSIX: fuerza una línea por sistema de ficheros aunque el nombre del dispositivo sea largo. Imprescindible al procesar la salida con `awk` o `cut`. |

> **Nota:** Un inodo (*inode*) es una estructura de datos en los sistemas de archivos Unix que almacena los metadatos de un archivo o directorio: permisos, propietario, fechas y punteros a los bloques de datos. Lo que **no** guarda es el nombre, que vive en el directorio que lo contiene.

> **Advertencia:** El número de inodos de un sistema de ficheros `ext4` se fija al formatearlo y no puede ampliarse después. Es perfectamente posible agotarlos aun teniendo gigabytes libres, y entonces cualquier intento de crear un fichero falla con `No space left on device` pese a que `df -h` muestre espacio de sobra. Ocurre en servidores de correo o de caché, que acumulan millones de ficheros diminutos. Ante ese error, el primer comando que hay que ejecutar es `df -i`.

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

> **Importante:** Conviene fijarse en que las columnas **no cuadran**. En la partición raíz hay 50.303.512 bloques en total y 5.476.028 usados, lo que dejaría 44.827.484 libres, pero `df` solo declara 42.239.736 disponibles. Faltan unos 2,5 GB.
>
> No es un error: los sistemas de ficheros de la familia `ext` **reservan por defecto el 5 % del espacio para el usuario `root`**. Esa reserva persigue dos fines: que el administrador siga pudiendo entrar y maniobrar en un disco lleno, y que el sistema de ficheros disponga de margen para no fragmentarse en exceso. El 5 % de 50.303.512 son 2.515.175 bloques, que es justo la diferencia observada.
>
> El porcentaje puede consultarse y modificarse con `tune2fs`:
>
> ```bash
> root@debian:~# tune2fs -l /dev/sda1 | grep -i "reserved block"
> Reserved block count:     2515175
> Reserved GDT blocks:      1024
> root@debian:~# tune2fs -m 1 /dev/sda1
> ```
>
> En una partición de datos que no aloje el sistema operativo, reservar el 5 % de un disco de 4 TB significa desperdiciar 200 GB, de modo que bajarlo al 1 % o al 0 % es una práctica habitual. En la partición raíz, en cambio, conviene mantener la reserva.

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

---

## 3. Cuando df y du no coinciden

Es habitual encontrarse con que `df` declara un sistema de ficheros lleno mientras `du` no logra localizar ese espacio. La causa más frecuente son los **ficheros borrados que algún proceso mantiene abiertos**.

En Unix, borrar un fichero solo elimina su nombre del directorio. Los bloques no se liberan hasta que se cierra el último descriptor que lo tuviera abierto. Si se borra un registro de 10 GB sin reiniciar el servicio que lo estaba escribiendo, el fichero desaparece del árbol de directorios (y por tanto `du` ya no lo ve) pero sigue ocupando el disco (y `df` sí lo cuenta).

Para localizar esos ficheros fantasma:

```bash
root@debian:~# lsof +L1
COMMAND   PID  USER   FD   TYPE DEVICE  SIZE/OFF NLINK    NODE NAME
apache2  681  root    2w   REG    8,1 104857600     0  264213 /var/log/apache2/error.log (deleted)
```

La columna `NLINK` a cero confirma que el fichero ya no tiene ningún nombre asociado. El espacio se recupera reiniciando el proceso o, sin llegar a eso, vaciando el fichero a través de su descriptor:

```bash
root@debian:~# : > /proc/681/fd/2
```

> **Recuerda:** Esta es también la razón por la que nunca debe borrarse un fichero de registro activo con `rm`. La forma correcta de vaciarlo sin interrumpir el servicio es truncarlo con `truncate -s 0 fichero.log` o con `: > fichero.log`, que conserva el inodo y el descriptor abierto. El documento 40 explica cómo `logrotate` automatiza este proceso.

> **Nota:** Otras dos causas de discrepancia son los puntos de montaje ocultos, cuando un sistema de ficheros se monta sobre un directorio que ya tenía contenido y ese contenido queda inaccesible pero sigue ocupando espacio, y el propio 5 % reservado que se explicaba más arriba.
