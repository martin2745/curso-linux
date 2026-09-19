# Comando mount y umount

## Índice

1. [Comando mount](#1-comando-mount)
2. [Comando umount](#2-comando-umount)
3. [Opciones comunes](#3-opciones-comunes)
   1. [Consultar lo que está montado](#31-consultar-lo-que-está-montado)
   2. [El problema de desmontar: "target is busy"](#32-el-problema-de-desmontar-target-is-busy)
4. [Ejemplos prácticos](#4-ejemplos-prácticos)

---

## 1. Comando mount

El comando `mount` se utiliza para montar (conectar) un sistema de archivos en una ubicación específica dentro del árbol de directorios del sistema. Esto permite que el contenido del sistema de archivos sea accesible en esa ubicación. 

Su sintaxis básica es:

```bash
mount [opciones] dispositivo punto_de_montaje
```

- `dispositivo` es la partición o dispositivo que contiene el sistema de archivos que deseas montar.
- `punto_de_montaje` es el directorio en el que deseas montar el sistema de archivos.

> **Advertencia:** El punto de montaje **no tiene por qué estar vacío**, pero conviene que lo esté. Si el directorio ya contenía ficheros, estos no se borran: quedan **ocultos** debajo del nuevo sistema de ficheros y dejan de ser accesibles mientras dure el montaje, aunque siguen ocupando espacio en el disco original. Es una de las causas de que `df` y `du` no coincidan, tal como se explicaba en el documento 13. Al desmontar, el contenido original reaparece.

> **Importante:** Montar y desmontar son operaciones reservadas a `root`. Un usuario sin privilegios solo puede montar aquellos dispositivos que tengan la opción `user` o `users` declarada en `/etc/fstab`, o los que gestione automáticamente el entorno de escritorio.

> **Recuerda:** Un montaje hecho con `mount` desde la línea de órdenes **se pierde al reiniciar**. Para que sea permanente hay que declararlo en el fichero `/etc/fstab`, que se trata en detalle en el documento 37.

Por ejemplo, si tienes una partición `/dev/sdb1` que quieres montar en `/mnt/nueva_particion`, puedes hacerlo así:

```bash
mount /dev/sdb1 /mnt/nueva_particion
```

> **Nota:** Además de montar dispositivos físicos (discos, USBs), `mount` también puede montar sistemas de archivos de red, como NFS (Network File System) o Samba (SMB/CIFS).

---

## 2. Comando umount

El comando `umount` se utiliza para desmontar (desconectar) un sistema de archivos previamente montado de una ubicación específica.

Su sintaxis básica es:

```bash
umount [opciones] punto_de_montaje
```

- `punto_de_montaje` es el directorio donde se montó el sistema de archivos y que deseas desmontar. (También se puede usar el nombre del dispositivo, por ejemplo `umount /dev/sdb1`).

Por ejemplo, si deseas desmontar la partición que acabamos de montar en `/mnt/nueva_particion`, puedes hacerlo así:

```bash
umount /mnt/nueva_particion
```

> **Advertencia:** No podrás desmontar un sistema de archivos si hay algún proceso usándolo o si algún usuario tiene una terminal abierta dentro de ese directorio. Si necesitas forzarlo o ver quién lo bloquea, puedes usar comandos como `lsof` o `fuser`.

---

## 3. Opciones comunes

| Parámetro | Descripción |
|-----------|-------------|
| `-o` | (`options`) Permite especificar opciones adicionales para el montaje, separadas por comas (ej. `rw`, `ro`, `remount`). |
| `-t` | (`type`) Permite especificar el tipo de sistema de archivos (ej. `ext4`, `ntfs`, `nfs`). Si se omite, `mount` intenta deducirlo leyendo la cabecera del dispositivo. |
| `-a` | (*All*) Monta todo lo declarado en `/etc/fstab` que no lo esté ya. Es lo que ejecuta el sistema durante el arranque. |
| `-r` / `-w` | Monta en modo solo lectura o en lectura y escritura. Equivalen a `-o ro` y `-o rw`. |
| `--bind` | Vuelve a montar una parte del árbol de directorios en otro punto, de modo que el mismo contenido resulta accesible desde dos rutas distintas. |
| `-o loop` | Monta el contenido de un **fichero** como si fuera un dispositivo. Es la forma de abrir una imagen ISO sin grabarla. |
| `-v` | Muestra detalladamente lo que va haciendo. Útil para depurar montajes que fallan. |

Las opciones que se pasan con `-o` son las que determinan el comportamiento real del sistema de ficheros montado:

| Opción | Descripción |
|---|---|
| `ro` / `rw` | Solo lectura o lectura y escritura. |
| `remount` | Cambia las opciones de un sistema ya montado sin desmontarlo. Se combina con las demás: `mount -o remount,ro /`. |
| `noexec` | Impide ejecutar binarios desde ese sistema de ficheros. |
| `nosuid` | Ignora los bits SUID y SGID de los ficheros que contenga. |
| `nodev` | Ignora los ficheros de dispositivo que pudiera haber dentro. |
| `noatime` / `relatime` | Controlan la actualización de la fecha de último acceso, tal como se explicaba en el documento 24. |
| `defaults` | Atajo equivalente a `rw,suid,dev,exec,auto,nouser,async`. Es lo que suele figurar en `/etc/fstab`. |

> **Recuerda:** La combinación `noexec,nosuid,nodev` es la receta habitual para montar particiones que solo deben contener datos, como `/tmp`, `/home` o una memoria USB. Impide que alguien ejecute un programa desde ahí o que se aproveche de un binario con SUID colocado a propósito, que son dos vías clásicas de escalada de privilegios.

### 3.1 Consultar lo que está montado

Ejecutando `mount` sin argumento alguno se obtiene la lista completa de sistemas de ficheros montados, aunque la salida resulta larga y poco legible porque incluye decenas de pseudo-sistemas del núcleo. Hay tres formas de consultarla:

```bash
usuario@debian:~$ mount | grep ^/dev
/dev/sda1 on / type ext4 (rw,relatime,errors=remount-ro)
usuario@debian:~$ cat /proc/mounts | grep ^/dev
/dev/sda1 / ext4 rw,relatime,errors=remount-ro 0 0
usuario@debian:~$ findmnt /
TARGET SOURCE    FSTYPE OPTIONS
/      /dev/sda1 ext4   rw,relatime,errors=remount-ro
```

> **Nota:** La fuente de verdad es `/proc/mounts`, que mantiene el propio núcleo. El antiguo `/etc/mtab`, que actualizaba `mount` por su cuenta, es hoy un enlace simbólico a `/proc/self/mounts` precisamente para que ambos no puedan discrepar. De las tres órdenes, `findmnt` es la más cómoda: presenta la información en forma de árbol y admite filtros como `findmnt -t ext4`.

### 3.2 El problema de desmontar: "target is busy"

Al intentar desmontar un sistema de ficheros en uso, `umount` se niega:

```bash
root@debian:~# umount /mnt/usb
umount: /mnt/usb: target is busy.
```

Para averiguar quién lo está bloqueando:

```bash
root@debian:~# lsof +D /mnt/usb
COMMAND  PID    USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
bash    2708 usuario  cwd    DIR   8,17     4096    2 /mnt/usb
root@debian:~# fuser -vm /mnt/usb
                     USUARIO    PID ACCESO COMANDO
/mnt/usb:            usuario   2708 ..c.. bash
```

> **Advertencia:** La causa más frecuente, y la más tonta, es tener una terminal cuyo directorio de trabajo está dentro del punto de montaje. Basta con hacer `cd` fuera para que el desmontaje funcione. La letra `c` de la salida de `fuser` indica precisamente eso: *current directory*.

| Opción de `umount` | Descripción |
|---|---|
| `-l` | (*Lazy*) Desmonta el sistema del árbol de directorios de inmediato, pero retrasa la liberación real hasta que ningún proceso lo use. Es la salida segura cuando no se puede detener el proceso que bloquea. |
| `-f` | (*Force*) Fuerza el desmontaje. Pensado para sistemas de red (NFS) cuyo servidor ha dejado de responder. |
| `-a` | Desmonta todo lo que figure en `/etc/fstab`. |
| `-R` | Desmonta de forma recursiva el punto indicado y todo lo montado por debajo. |

> **Advertencia:** `umount -f` sobre un sistema de ficheros local puede provocar pérdida de datos, ya que interrumpe escrituras a medias. Antes de recurrir a él conviene probar con `-l`, o directamente cerrar los procesos implicados. `fuser -km /punto` los mata a todos, pero es una medida drástica que conviene reservar para el último lugar.

---

## 4. Ejemplos prácticos

Montar una unidad USB en `/mnt/usb`:

```bash
mount /dev/sdb1 /mnt/usb
```

Desmontar la unidad USB de `/mnt/usb`:

```bash
umount /mnt/usb
```

Desmontar una carpeta compartida de red NFS:

```bash
umount /mnt/nfs
```

Montar una imagen ISO para inspeccionar su contenido sin grabarla:

```bash
root@debian:~# mkdir -p /mnt/iso
root@debian:~# mount -o loop,ro debian-13.iso /mnt/iso
root@debian:~# ls /mnt/iso
boot  dists  doc  EFI  install.amd  isolinux  pool  README.txt
```

Montar una partición por su **UUID** en lugar de por su nombre de dispositivo:

```bash
root@debian:~# blkid /dev/sdb1
/dev/sdb1: UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" TYPE="ext4"
root@debian:~# mount UUID=a1b2c3d4-e5f6-7890-abcd-ef1234567890 /mnt/datos
```

> **Importante:** Los nombres `/dev/sdX` **no son estables**: dependen del orden en que el núcleo detecta los discos durante el arranque, de modo que conectar una memoria USB o cambiar un cable puede convertir el `/dev/sdb` de ayer en el `/dev/sdc` de hoy. Por eso `/etc/fstab` identifica hoy las particiones por su `UUID` o por su etiqueta (`LABEL`), que viajan dentro del propio sistema de ficheros y no cambian.

Reparar un sistema de ficheros raíz que arrancó en modo solo lectura tras un fallo:

```bash
root@debian:~# mount -o remount,rw /
```

Hacer accesible un directorio desde una segunda ruta con `--bind`:

```bash
root@debian:~# mount --bind /var/www/html /srv/publico
```
