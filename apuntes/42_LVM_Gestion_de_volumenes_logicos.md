# LVM: gestión de volúmenes lógicos

## Índice

1. [Conceptos: PV, VG y LV](#1-conceptos-pv-vg-y-lv)
2. [Instalación y estado de partida](#2-instalación-y-estado-de-partida)
3. [Creación de la pila LVM](#3-creación-de-la-pila-lvm)
   1. [Crear los volúmenes físicos (PV)](#31-crear-los-volúmenes-físicos-pv)
   2. [Crear el grupo de volúmenes (VG)](#32-crear-el-grupo-de-volúmenes-vg)
   3. [Crear los volúmenes lógicos (LV)](#33-crear-los-volúmenes-lógicos-lv)
4. [Formatear y montar un volumen lógico](#4-formatear-y-montar-un-volumen-lógico)
5. [Ampliar un volumen en caliente](#5-ampliar-un-volumen-en-caliente)
   1. [Cuando el grupo de volúmenes también está lleno](#51-cuando-el-grupo-de-volúmenes-también-está-lleno)
6. [Reducir un volumen](#6-reducir-un-volumen)
7. [Instantáneas (snapshots)](#7-instantáneas-snapshots)
8. [Consulta y eliminación](#8-consulta-y-eliminación)
9. [Resumen de comandos](#9-resumen-de-comandos)

---

## 1. Conceptos: PV, VG y LV

LVM se organiza en tres capas superpuestas. Entenderlas es la mitad del trabajo, porque todos los comandos llevan el prefijo de la capa sobre la que actúan: `pv*`, `vg*` o `lv*`.

| Capa | Nombre | Qué es |
|---|---|---|
| **PV** | *Physical Volume* (volumen físico) | Un disco entero (`/dev/sdb`) o una partición (`/dev/sdb1`) que se entrega a LVM para que lo gestione. |
| **VG** | *Volume Group* (grupo de volúmenes) | La reserva común de espacio. Se forma sumando uno o más PV. Es el "disco virtual" del que se reparte todo. |
| **LV** | *Logical Volume* (volumen lógico) | La "partición virtual" que se saca de un VG. Es lo que se formatea y se monta, como si fuera una partición normal. |

El flujo de trabajo siempre sigue el mismo orden, de abajo arriba:

```text
Discos físicos    ->  PV  ->      VG          ->   LV        ->  Sistema de ficheros
/dev/sdb /dev/sdc     (pvcreate)  (vgcreate)       (lvcreate)    (mkfs) y montaje
```

> **Nota:** Internamente, el VG divide todo su espacio en trozos iguales llamados **extents** (por defecto de 4 MiB). Un LV no es más que un conjunto de extents del VG. Esta granularidad es la que permite que LVM reparta un mismo volumen entre varios discos físicos sin que el usuario lo note.

> **Recuerda:** LVM y RAID son complementarios, no alternativos. En un servidor serio se combinan por capas: primero se crea el RAID con `mdadm` (documento 38) para tener tolerancia a fallos, y el dispositivo resultante (`/dev/md0`) se entrega a LVM como PV. Así se obtiene a la vez redundancia (RAID) y flexibilidad (LVM).

---

## 2. Instalación y estado de partida

Las herramientas de LVM vienen en el paquete `lvm2`:

```bash
root@debian:~# apt install lvm2
```

Partimos de una máquina con el disco del sistema (`/dev/sda`) y dos discos nuevos y vacíos de 10 GB, `/dev/sdb` y `/dev/sdc`, que vamos a dedicar a LVM:

```bash
root@debian:~# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda      8:0    0   50G  0 disk
├─sda1   8:1    0  512M  0 part /boot/efi
└─sda2   8:2    0 49,5G  0 part /
sdb      8:16   0   10G  0 disk
sdc      8:32   0   10G  0 disk
```

> **Nota:** LVM puede usar tanto discos enteros (`/dev/sdb`) como particiones (`/dev/sdb1`). Usar el disco entero es más sencillo y es lo habitual cuando el disco se dedica por completo a LVM. Si se prefiere particionar primero, conviene marcar la partición con el tipo `Linux LVM` (código `8e` en MBR o `lvm` en GPT), aunque no es imprescindible para que funcione.

---

## 3. Creación de la pila LVM

### 3.1 Crear los volúmenes físicos (PV)

Se marca cada disco como volumen físico con `pvcreate`. Esto escribe una pequeña cabecera de metadatos LVM al principio del disco:

```bash
root@debian:~# pvcreate /dev/sdb /dev/sdc
  Physical volume "/dev/sdb" successfully created.
  Physical volume "/dev/sdc" successfully created.
```

### 3.2 Crear el grupo de volúmenes (VG)

Se agrupan los dos PV en un único VG, al que damos un nombre descriptivo (`datos`):

```bash
root@debian:~# vgcreate datos /dev/sdb /dev/sdc
  Volume group "datos" successfully created
```

En este punto ya tenemos una reserva de 20 GB (los dos discos sumados), de la que iremos repartiendo volúmenes:

```bash
root@debian:~# vgs
  VG    #PV #LV #SN Attr   VSize   VFree
  datos   2   0   0 wz--n- 19,99g 19,99g
```

### 3.3 Crear los volúmenes lógicos (LV)

Del VG `datos` sacamos los volúmenes que necesitemos. El tamaño se indica con `-L` (tamaño absoluto) y el nombre con `-n`:

```bash
root@debian:~# lvcreate -L 8G -n web datos
  Logical volume "web" created.
root@debian:~# lvcreate -L 4G -n bd datos
  Logical volume "bd" created.
```

| Opción | Descripción |
|---|---|
| `-L TAM` | Tamaño **absoluto** del volumen, con sufijo: `-L 8G`, `-L 500M`. |
| `-l NÚM` | Tamaño en **extents** o como porcentaje: `-l 100%FREE` usa todo el espacio libre del VG. |
| `-n NOMBRE` | Nombre del volumen lógico. |
| `-s` | Crea una instantánea (*snapshot*) de otro LV. Se trata en el apartado 7. |

> **Importante:** No conviene consumir de golpe todo el espacio del VG. Una de las grandes ventajas de LVM es poder ampliar los volúmenes según haga falta, así que lo prudente es crear cada LV con el tamaño que necesita **ahora** y dejar espacio libre en el VG como colchón para el que más crezca.

Cada LV aparece en el sistema con dos rutas equivalentes que apuntan al mismo dispositivo:

```bash
root@debian:~# lvs
  LV   VG    Attr       LSize
  bd   datos -wi-a----- 4,00g
  web  datos -wi-a----- 8,00g
root@debian:~# ls -l /dev/datos/web /dev/mapper/datos-web
lrwxrwxrwx 1 root root 7 sep 18 10:22 /dev/datos/web -> ../dm-0
lrwxrwxrwx 1 root root 7 sep 18 10:22 /dev/mapper/datos-web -> ../dm-0
```

---

## 4. Formatear y montar un volumen lógico

Un LV se comporta exactamente igual que una partición: se formatea con `mkfs` y se monta con `mount` (documentos 25 y 37).

```bash
root@debian:~# mkfs.ext4 /dev/datos/web
root@debian:~# mkdir -p /srv/web
root@debian:~# mount /dev/datos/web /srv/web
```

Para que el montaje sea permanente se añade la entrada correspondiente a `/etc/fstab`. Con LVM se usa directamente la ruta del volumen, ya que es estable y no depende del orden de detección de los discos:

```bash
/dev/datos/web   /srv/web   ext4   defaults   0   2
```

> **Recuerda:** Los nombres `/dev/datos/web` de LVM son estables por diseño, a diferencia de los `/dev/sdX` de los discos físicos. Por eso, cuando se usa LVM, en `/etc/fstab` no hace falta recurrir al `UUID`: la propia ruta del volumen lógico cumple esa función.

---

## 5. Ampliar un volumen en caliente

Este es el motivo por el que existe LVM y lo que hay que dominar. Supongamos que `/srv/web` se está quedando sin espacio. Ampliarlo es un proceso de **dos pasos**: primero se agranda el volumen lógico y después el sistema de ficheros que contiene.

Si todavía queda espacio libre en el VG, basta con el segundo. Vamos a añadir 4 GB al volumen `web`:

```bash
root@debian:~# lvextend -L +4G /dev/datos/web
  Size of logical volume datos/web changed from 8,00 GiB to 12,00 GiB.
root@debian:~# resize2fs /dev/datos/web
  The filesystem on /dev/datos/web is now 3145728 (4k) blocks long.
```

El sistema de ficheros se ha ampliado **sin desmontar `/srv/web`** y sin interrumpir el servicio.

> **Importante:** Son dos operaciones distintas y las dos son necesarias. `lvextend` agranda el "contenedor" (el volumen lógico), pero el sistema de ficheros de dentro sigue creyendo que mide lo de antes; hasta que no se ejecuta `resize2fs`, el espacio nuevo no está disponible. Olvidar el segundo paso es el error más frecuente al empezar con LVM.

Para no tener que acordarse de los dos pasos, `lvextend` admite la opción `-r` (`--resizefs`), que redimensiona el sistema de ficheros automáticamente detrás:

```bash
root@debian:~# lvextend -r -L +4G /dev/datos/web
```

> **Nota:** El comando para redimensionar depende del sistema de ficheros. Para la familia `ext` es `resize2fs`; para **XFS** es `xfs_growfs` y se le pasa el **punto de montaje**, no el dispositivo: `xfs_growfs /srv/web`. La opción `-r` de `lvextend` elige la herramienta correcta por sí sola, lo que es una razón más para usarla siempre.

### 5.1 Cuando el grupo de volúmenes también está lleno

Si el VG no tiene espacio libre, primero hay que ampliarlo añadiéndole un disco nuevo como PV. Conectamos un tercer disco `/dev/sdd` y lo incorporamos:

```bash
root@debian:~# pvcreate /dev/sdd
root@debian:~# vgextend datos /dev/sdd
  Volume group "datos" successfully extended
```

A partir de ahí el VG tiene espacio otra vez y podemos ampliar el volumen que necesitemos. Para usar todo el espacio libre disponible sin calcularlo a mano se emplea `-l +100%FREE`:

```bash
root@debian:~# lvextend -r -l +100%FREE /dev/datos/web
```

> **Recuerda:** Esta es la secuencia completa de la ampliación de almacenamiento en un servidor LVM, y conviene tenerla memorizada: **conectar disco → `pvcreate` → `vgextend` → `lvextend -r`**. Todo ello sin reiniciar y, en la mayoría de los casos, sin parar el servicio.

---

## 6. Reducir un volumen

Reducir es la operación inversa a ampliar y es **mucho más delicada**, porque los pasos van en orden contrario: primero hay que encoger el sistema de ficheros y solo después el volumen lógico. Si se hace al revés, se recorta el volumen por debajo del tamaño de sus datos y se destruyen.

```bash
root@debian:~# umount /srv/web
root@debian:~# e2fsck -f /dev/datos/web
root@debian:~# resize2fs /dev/datos/web 6G
root@debian:~# lvreduce -L 6G /dev/datos/web
root@debian:~# mount /dev/datos/web /srv/web
```

> **Advertencia:** La reducción **exige desmontar** el volumen (no se puede hacer en caliente) y conlleva un riesgo real de pérdida de datos si el tamaño nuevo se calcula mal. Antes de reducir hay que tener una copia de seguridad, sin excepciones.

> **Advertencia:** Los sistemas de ficheros **XFS y Btrfs no se pueden reducir**. Solo admiten crecer. Si se prevé la posibilidad de tener que encoger un volumen en el futuro, esa es una razón para elegir `ext4`, que sí lo permite.

---

## 7. Instantáneas (snapshots)

Una instantánea es una "foto" congelada de un volumen lógico en un instante concreto. Su uso principal es hacer copias de seguridad **consistentes**: se congela el estado del volumen, se copia con calma desde la instantánea mientras el sistema sigue trabajando sobre el volumen original, y al terminar se descarta la instantánea.

```bash
root@debian:~# lvcreate -L 2G -s -n web_snap /dev/datos/web
  Logical volume "web_snap" created.
```

La instantánea (`web_snap`) se puede montar y leer como cualquier otro volumen, y contiene los datos tal y como estaban en el momento de crearla, aunque el original haya cambiado desde entonces:

```bash
root@debian:~# mkdir -p /mnt/snap
root@debian:~# mount -o ro /dev/datos/web_snap /mnt/snap
root@debian:~# tar czf /backup/web-$(date +%F).tar.gz -C /mnt/snap .
root@debian:~# umount /mnt/snap
root@debian:~# lvremove /dev/datos/web_snap
```

> **Importante:** Una instantánea **no es una copia**: solo guarda los bloques del original que van cambiando desde que se creó (mecanismo *copy-on-write*). Por eso ocupa poco al principio, pero va creciendo a medida que el volumen original se modifica. El tamaño que se le asigna con `-L` es su capacidad máxima para almacenar esos cambios.

> **Advertencia:** Si una instantánea se llena porque el original ha cambiado más de lo previsto, **se invalida y se pierde**. Por eso las instantáneas están pensadas para vivir poco tiempo (el que dure una copia de seguridad), no como respaldo permanente. Su estado se vigila con `lvs`, en la columna `Data%`.

---

## 8. Consulta y eliminación

Cada capa tiene su pareja de comandos: uno breve (`pvs`, `vgs`, `lvs`) para una vista rápida en forma de tabla, y otro detallado (`pvdisplay`, `vgdisplay`, `lvdisplay`) para toda la información.

| Comando | Muestra |
|---|---|
| `pvs` / `pvdisplay` | Volúmenes físicos: a qué VG pertenecen y cuánto espacio les queda. |
| `vgs` / `vgdisplay` | Grupos de volúmenes: tamaño total, espacio libre y número de PV y LV. |
| `lvs` / `lvdisplay` | Volúmenes lógicos: tamaño, VG al que pertenecen y, en las instantáneas, su porcentaje de ocupación. |

La eliminación se hace en orden inverso a la creación (de arriba abajo), y cada paso pide confirmación porque destruye datos:

```bash
root@debian:~# umount /srv/web
root@debian:~# lvremove /dev/datos/web       # elimina el volumen logico
root@debian:~# vgremove datos                # elimina el grupo de volumenes
root@debian:~# pvremove /dev/sdb /dev/sdc     # libera los discos fisicos
```

> **Advertencia:** Antes de eliminar un volumen lógico hay que **desmontarlo** y comentar o borrar su entrada en `/etc/fstab`. Si no, el siguiente arranque se detendrá en modo de emergencia al no encontrar un dispositivo que ya no existe, tal como se explicaba en el documento 37.

---

## 9. Resumen de comandos

| Operación | Comando |
|---|---|
| Marcar disco como PV | `pvcreate /dev/sdX` |
| Crear grupo de volúmenes | `vgcreate NOMBRE /dev/sdX ...` |
| Añadir un disco a un VG | `vgextend NOMBRE /dev/sdY` |
| Crear volumen lógico | `lvcreate -L TAM -n NOMBRE VG` |
| Ampliar volumen y su FS | `lvextend -r -L +TAM /dev/VG/LV` |
| Usar todo el espacio libre | `lvextend -r -l +100%FREE /dev/VG/LV` |
| Reducir volumen (desmontado) | `resize2fs ... TAM` y luego `lvreduce -L TAM ...` |
| Crear instantánea | `lvcreate -L TAM -s -n SNAP /dev/VG/LV` |
| Ver estado | `pvs`, `vgs`, `lvs` |
| Eliminar (de arriba abajo) | `lvremove` → `vgremove` → `pvremove` |
