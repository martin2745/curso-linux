# RAID con mdadm

## Índice

1. [Introducción a mdadm](#1-introduccion-a-mdadm)
2. [Práctica: Creación de un RAID 5](#2-practica-creacion-de-un-raid-5)
   1. [Preparación de discos y particiones](#21-preparacion-de-discos-y-particiones)
   2. [Instalación de mdadm y creación del RAID](#22-instalacion-de-mdadm-y-creacion-del-raid)
   3. [Persistencia del RAID entre reinicios](#23-persistencia-del-raid-entre-reinicios)
   4. [Formateo y montaje](#24-formateo-y-montaje)
   5. [Persistencia del montaje en fstab](#25-persistencia-del-montaje-en-fstab)
3. [Simulación de fallo y sustitución de disco](#3-simulacion-de-fallo-y-sustitucion-de-disco)
4. [Disco de repuesto (spare)](#4-disco-de-repuesto-spare)

---

## 1. Introducción a mdadm

`mdadm` es una herramienta de administración de RAID (Redundant Array of Independent Disks) en sistemas operativos basados en Linux. Se utiliza para configurar y administrar matrices de discos para mejorar la redundancia y/o el rendimiento del almacenamiento de datos.

| Comando | Descripción |
|---------|-------------|
| `mdadm --zero-superblock /dev/sdb /dev/sdc /dev/sdd` | Elimina el superbloque (sector de metadatos RAID) de los discos especificados. Útil antes de reutilizar discos previamente usados en otro RAID. |
| `mdadm -C /dev/md0 -l raid5 -n 3 /dev/sdb1 /dev/sdc1 /dev/sdd1` | Crea el RAID indicando su nombre (`/dev/md0`), el tipo de RAID (`raid5`) e indica las particiones que lo conforman. |
| `mdadm --create /dev/md0 --level=5 --raid-device=3 /dev/sdb1 /dev/sdc1 /dev/sdd1` | Equivalente al comando anterior (forma larga). |
| `mdadm --detail /dev/md0` | Muestra los detalles del RAID: estado, dispositivos, sincronización. |
| `mdadm --manage /dev/md0 --add /dev/sde1` | Añade un disco al RAID (como activo o spare). |
| `mdadm --manage /dev/md0 --fail /dev/sdd1` | Marca un disco del RAID como fallido (simula un fallo). |
| `mdadm --manage /dev/md0 --remove /dev/sdd1` | Elimina un disco del RAID (debe estar marcado como fallido antes). |
| `mdadm --stop /dev/md0` | Detiene el RAID. |
| `mdadm --remove /dev/md0` | Elimina el RAID (debe estar detenido primero). |
| `mdadm --grow /dev/md0 --raid-device=6` | Amplía el número de discos activos del RAID a 6, tomando los discos en espera. |

> **Nota:** Para hacer el montaje de un RAID 5 necesitamos un mínimo de 3 discos. Con 3 discos de 10 GB obtendremos 20 GB de espacio útil, ya que 10 GB se utilizan para el cálculo de paridad (tolerancia a fallo de 1 disco).

---

## 2. Práctica: Creación de un RAID 5

### 2.1. Preparación de discos y particiones

Una vez arrancada la máquina, comprobamos que existen los discos con `lsblk`:

```bash
root@debian:~# lsblk -e7
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda      8:0    0   50G  0 disk
├─sda1   8:1    0    1M  0 part
├─sda2   8:2    0  513M  0 part /boot/efi
└─sda3   8:3    0 49,5G  0 part /
sdb      8:16   0   10G  0 disk
sdc      8:32   0   10G  0 disk
sdd      8:48   0   10G  0 disk
```

> **Importante:** Antes de usar discos que hayan pertenecido a un RAID anterior, es recomendable limpiar su superbloque para evitar conflictos:

```bash
root@debian:~# mdadm --zero-superblock /dev/sdb /dev/sdc /dev/sdd
```

A continuación, creamos las particiones en formato **GPT** en cada disco. El proceso que se muestra a continuación debe repetirse para `/dev/sdc` y `/dev/sdd`:

```bash
root@debian:~# parted -s /dev/sdb mklabel gpt
root@debian:~# parted -s /dev/sdb mkpart primary 0% 100%
root@debian:~# parted -s /dev/sdb print
Model: ATA VBOX HARDDISK (scsi)
Disk /dev/sdb: 10,7GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name     Flags
 1      1049kB  10,7GB  10,7GB               primary
```

Verificamos el resultado final con `lsblk`:

```bash
root@debian:~# lsblk -e7
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda      8:0    0   50G  0 disk
├─sda1   8:1    0    1M  0 part
├─sda2   8:2    0  513M  0 part /boot/efi
└─sda3   8:3    0 49,5G  0 part /
sdb      8:16   0   10G  0 disk
└─sdb1   8:17   0   10G  0 part
sdc      8:32   0   10G  0 disk
└─sdc1   8:33   0   10G  0 part
sdd      8:48   0   10G  0 disk
└─sdd1   8:49   0   10G  0 part
sr0     11:0    1 1024M  0 rom
```

> **Nota:** Es igualmente válido usar `fdisk` en lugar de `parted` para crear las particiones.

---

### 2.2. Instalación de mdadm y creación del RAID

Instalamos la herramienta `mdadm`:

```bash
root@debian:~# apt update
...
root@debian:~# apt install -y mdadm
...
```

Creamos el RAID 5 con el siguiente comando:

```bash
root@debian:~# mdadm -C /dev/md0 -l raid5 -n 3 /dev/sdb1 /dev/sdc1 /dev/sdd1
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
```

Los parámetros utilizados son:

| Parámetro | Descripción |
|-----------|-------------|
| `-C /dev/md0` | Nombre del dispositivo RAID a crear. El prefijo `/dev/md` es el estándar para dispositivos RAID en Linux. |
| `-l raid5` | Nivel de RAID. En este caso, RAID 5 (paridad distribuida). |
| `-n 3` | Número de dispositivos que formarán la matriz. |
| `/dev/sdb1 /dev/sdc1 /dev/sdd1` | Particiones que se integran en el RAID. |

Para monitorizar el progreso de la sincronización en tiempo real, abrimos otra terminal y ejecutamos:

```bash
root@debian:~# watch -n 1 mdadm --detail /dev/md0
```

La salida mostrará el estado de cada disco y el progreso de la sincronización:

```bash
Every 1,0s: mdadm --detail /dev/md0                            debian: Thu May 16 12:45:08 2024

/dev/md0:
           Version : 1.2
     Creation Time : Thu May 16 12:40:41 2024
        Raid Level : raid5
        Array Size : 20948992 (19.98 GiB 21.45 GB)
     Used Dev Size : 10474496 (9.99 GiB 10.73 GB)
      Raid Devices : 3
     Total Devices : 3
       Persistence : Superblock is persistent

       Update Time : Thu May 16 12:41:54 2024
             State : clean
    Active Devices : 3
   Working Devices : 3
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : debian:0  (local to host debian)
              UUID : 56175065:02460b89:83ee4102:738deb4b
            Events : 18

    Number   Major   Minor   RaidDevice State
       0       8       17        0      active sync   /dev/sdb1
       1       8       33        1      active sync   /dev/sdc1
       3       8       49        2      active sync   /dev/sdd1
```

---

### 2.3. Persistencia del RAID entre reinicios

Por defecto, la configuración del RAID no sobrevive a un reinicio con el mismo nombre de dispositivo (`/dev/md0`). Para hacerla persistente hay que seguir dos pasos.

**Paso 1:** Añadir la configuración del RAID al fichero `/etc/mdadm/mdadm.conf`:

```bash
root@debian:~# mdadm --detail --scan | grep md0 | tee -a /etc/mdadm/mdadm.conf
ARRAY /dev/md0 metadata=1.2 name=debian:0 UUID=56175065:02460b89:83ee4102:738deb4b
```

**Paso 2:** Actualizar el `initramfs` para que detecte el RAID durante el arranque:

```bash
root@debian:~# update-initramfs -u
update-initramfs: Generating /boot/initrd.img-6.5.0-35-generic
```

> **Nota:** El `initramfs` (Initial RAM Filesystem) es el sistema de archivos temporal que el kernel carga en memoria durante el arranque. Es el responsable de cargar los módulos necesarios (RAID, LVM, cifrado, etc.), encontrar y montar el sistema de archivos raíz (`/`) y pasar el control al proceso `init`.

En este punto, todas las particiones pertenecen al volumen RAID `md0`:

```bash
root@debian:~# lsblk -e7
NAME    MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
sda       8:0    0   50G  0 disk
├─sda1    8:1    0    1M  0 part
├─sda2    8:2    0  513M  0 part  /boot/efi
└─sda3    8:3    0 49,5G  0 part  /
sdb       8:16   0   10G  0 disk
└─sdb1    8:17   0   10G  0 part
  └─md0   9:0    0   20G  0 raid5
sdc       8:32   0   10G  0 disk
└─sdc1    8:33   0   10G  0 part
  └─md0   9:0    0   20G  0 raid5
sdd       8:48   0   10G  0 disk
└─sdd1    8:49   0   10G  0 part
  └─md0   9:0    0   20G  0 raid5
sr0      11:0    1 1024M  0 rom
```

---

### 2.4. Formateo y montaje

Para poder almacenar datos en el RAID, hay que darle un sistema de ficheros:

```bash
root@debian:~# mkfs.ext4 /dev/md0
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 5237248 4k blocks and 1310720 inodes
Filesystem UUID: ed1d30dc-5803-4ab5-a4f5-1d72840c9108
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000

Allocating group tables: done
Writing inode tables: done
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done
```

A continuación, montamos el RAID en el sistema en la ruta `/mnt/RAID5`:

```bash
root@debian:~# mkdir /mnt/RAID5
root@debian:~# mount /dev/md0 /mnt/RAID5/
root@debian:~# lsblk -e7
NAME    MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
sdb       8:16   0   10G  0 disk
└─sdb1    8:17   0   10G  0 part
  └─md0   9:0    0   20G  0 raid5 /mnt/RAID5
sdc       8:32   0   10G  0 disk
└─sdc1    8:33   0   10G  0 part
  └─md0   9:0    0   20G  0 raid5 /mnt/RAID5
sdd       8:48   0   10G  0 disk
└─sdd1    8:49   0   10G  0 part
  └─md0   9:0    0   20G  0 raid5 /mnt/RAID5
sr0      11:0    1 1024M  0 rom
```

---

### 2.5. Persistencia del montaje en fstab

Para que el montaje del RAID se realice automáticamente en cada arranque, añadimos la entrada correspondiente a `/etc/fstab`:

```bash
root@debian:~# cp -pv /etc/fstab /etc/fstab_VIEJO
'/etc/fstab' -> '/etc/fstab_VIEJO'
root@debian:~# echo "/dev/md0 /mnt/RAID5 ext4 defaults,nofail,discard 0 0" | tee -a /etc/fstab
root@debian:~# mount -a
```

> **Importante:** La opción `nofail` evita que el sistema no arranque si el dispositivo RAID no está disponible. Se recomienda siempre guardar una copia de `/etc/fstab` antes de modificarlo.

Comprobamos que el RAID funciona creando ficheros de prueba en su interior:

```bash
root@debian:~# mkdir /mnt/RAID5/prueba && for i in $(seq 1 100); do echo "Fichero ${i}" > /mnt/RAID5/prueba/fichero${i}.txt;done
```

```bash
root@debian:~# ls /mnt/RAID5/prueba/
fichero100.txt  fichero25.txt  fichero40.txt  fichero56.txt  fichero71.txt  fichero87.txt
... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...
fichero10.txt   fichero26.txt  fichero41.txt  fichero57.txt  fichero72.txt  fichero88.txt
```

---

## 3. Simulación de fallo y sustitución de disco

RAID 5 tolera el fallo de un disco sin pérdida de datos. Vamos a simularlo marcando `/dev/sdd1` como fallido:

```bash
root@debian:~# mdadm --manage /dev/md0 --fail /dev/sdd1
mdadm: set /dev/sdd1 faulty in /dev/md0
```

El RAID pasa a estado `degraded`, pero sigue operativo:

```bash
Every 1,0s: mdadm --detail /dev/md0                            debian: Thu May 16 13:25:42 2024

/dev/md0:
           Version : 1.2
     Creation Time : Thu May 16 12:40:41 2024
        Raid Level : raid5
        Array Size : 20948992 (19.98 GiB 21.45 GB)
     Used Dev Size : 10474496 (9.99 GiB 10.73 GB)
      Raid Devices : 3
     Total Devices : 3
       Persistence : Superblock is persistent

       Update Time : Thu May 16 13:25:30 2024
             State : clean, degraded
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 1
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : debian:0  (local to host debian)
              UUID : 56175065:02460b89:83ee4102:738deb4b
            Events : 20

    Number   Major   Minor   RaidDevice State
       0       8       17        0      active sync   /dev/sdb1
       1       8       33        1      active sync   /dev/sdc1
       -       0        0        2      removed

       3       8       49        -      faulty   /dev/sdd1
```

> **Advertencia:** En estado `degraded`, el RAID no tiene redundancia. Un segundo fallo de disco provocaría pérdida de datos. Se debe sustituir el disco fallido lo antes posible.

Los datos siguen accesibles durante el estado degradado:

```bash
root@debian:~# ls /mnt/RAID5/prueba/
fichero100.txt  fichero25.txt  fichero40.txt  fichero56.txt  fichero71.txt  fichero87.txt
... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...
fichero10.txt   fichero26.txt  fichero41.txt  fichero57.txt  fichero72.txt  fichero88.txt
```

Eliminamos el disco fallido del RAID y lo sustituimos por `/dev/sde`:

```bash
root@debian:~# mdadm --manage /dev/md0 --remove /dev/sdd1
mdadm: hot removed /dev/sdd1 from /dev/md0
```

El RAID queda con solo 2 dispositivos activos hasta añadir el nuevo:

```bash
Every 1,0s: mdadm --detail /dev/md0                            debian: Thu May 16 13:37:31 2024

/dev/md0:
             State : clean, degraded
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

    Number   Major   Minor   RaidDevice State
       0       8       17        0      active sync   /dev/sdb1
       1       8       33        1      active sync   /dev/sdc1
       -       0        0        2      removed
```

Creamos una partición en el disco de sustitución `/dev/sde` (en este caso un disco de 20 GB, por lo que la partición ocupa el 50%):

```bash
root@debian:~# parted -s /dev/sde mklabel gpt
root@debian:~# parted -s /dev/sde mkpart primary 0% 50%
```

Verificamos la partición creada:

```bash
root@debian:~# lsblk -e7
...
sde       8:64   0   20G  0 disk
└─sde1    8:65   0   10G  0 part
```

Añadimos el nuevo disco al RAID. Este comenzará automáticamente el proceso de reconstrucción:

```bash
root@debian:~# mdadm --manage /dev/md0 --add /dev/sde1
mdadm: added /dev/sde1
```

El estado `spare rebuilding` indica que el disco está siendo reconstruido:

```bash
Every 1,0s: mdadm --detail /dev/md0                            debian: Thu May 16 13:46:37 2024

/dev/md0:
             State : clean, degraded, recovering
    Active Devices : 2
   Working Devices : 3
    Failed Devices : 0
     Spare Devices : 1

    Rebuild Status : 4% complete

    Number   Major   Minor   RaidDevice State
       0       8       17        0      active sync   /dev/sdb1
       1       8       33        1      active sync   /dev/sdc1
       3       8       65        2      spare rebuilding   /dev/sde1
```

---

## 4. Disco de repuesto (spare)

`mdadm` permite mantener un **pool de discos en espera** (spares) que entran automáticamente en funcionamiento cuando un disco activo falla, sin intervención manual.

Identificamos un disco disponible y lo preparamos:

```bash
root@debian:~# lsblk -e7
...
sdf       8:80   0   10G  0 disk
...
```

```bash
root@debian:~# parted -s /dev/sdf mklabel gpt
root@debian:~# parted -s /dev/sdf mkpart primary 0% 100%
root@debian:~# mdadm --manage /dev/md0 --add /dev/sdf1
mdadm: added /dev/sdf1
```

Con `mdadm --detail` vemos que `/dev/sdf1` está como `spare`:

```bash
Every 1,0s: mdadm --detail /dev/md0                            debian: Thu May 16 13:53:48 2024
/dev/md0:
             State : clean
    Active Devices : 3
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 1

    Number   Major   Minor   RaidDevice State
       0       8       17        0      active sync   /dev/sdb1
       1       8       33        1      active sync   /dev/sdc1
       3       8       65        2      active sync   /dev/sde1

       4       8       81        -      spare   /dev/sdf1
```

Provocamos el fallo de un disco para verificar que el spare entra automáticamente:

```bash
root@debian:~# mdadm --manage /dev/md0 --fail /dev/sdb1
mdadm: set /dev/sdb1 faulty in /dev/md0
```

El spare `/dev/sdf1` entra automáticamente y el RAID vuelve a estado `clean`:

```bash
Every 1,0s: mdadm --detail /dev/md0                            debian: Thu May 16 13:58:31 2024
/dev/md0:
             State : clean
    Active Devices : 3
   Working Devices : 3
    Failed Devices : 1
     Spare Devices : 0

    Number   Major   Minor   RaidDevice State
       4       8       81        0      active sync   /dev/sdf1
       1       8       33        1      active sync   /dev/sdc1
       3       8       65        2      active sync   /dev/sde1

       0       8       17        -      faulty   /dev/sdb1
```

> **Nota:** El uso de discos spare es una buena práctica en entornos de producción para minimizar el tiempo en estado degradado y reducir el riesgo de pérdida de datos ante un segundo fallo.
