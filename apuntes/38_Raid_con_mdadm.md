# Raid con mdadm

`mdadm` es una herramienta de administración de RAID (Redundant Array of Independent Disks) en sistemas operativos basados en Linux. Se utiliza para configurar y administrar matrices de discos para mejorar la redundancia y/o el rendimiento del almacenamiento de datos. Como comandos podemos destacar los siguientes:

- mdadm --zero-superblock /dev/sdb /dev/sdc /dev/sdd: Elimina el sector cero donde estaría la tabla de particiones si hibieran sido utilizados los discos anteriormente.
- mdadm -C /dev/md0 -l raid5 -n 3 /dev/sdb1 /dev/sdc1 /dev/sdd1: Crea el RAID indicando su nombre (**/dev/md0**), el tipo de RAID (**raid5**) e indica las particiones que lo conforman (**/dev/sdb1 /dev/sdc1 /dev/sdd1**).
- mdadm --create /dev/md0 --level=5 --raid-device=3 /dev/sdb1 /dev/sdc1 /dev/sdd1: Equivalente al comando anterior.
- mdadm --detail /dev/md0: Muestra los detalles del RAID.
- mdadm --manage /dev/md0 --add /dev/sde1: Añade un disco al RAID.
- mdadm --manage /dev/md0 --fail /dev/sdd1: Proboca el fallo de un disco del RAID.
- mdadm --manage /dev/md0 --remove /dev/sdd1: Elimina un disco del RAID.
- mdadm --stop /dev/md0: Detiene el RAID.
- mdadm --remove /dev/md0: Elimina el RAID (para eliminarlo primero hay que detenerlo).
- mdadm --grow /dev/md0 --raid-device=6: Amplia el número de discos que forman parte del RAID a 6 cogiendo los que están en espera.

Para hacer el montaje de un RAID 5 necesitamos 3 discos de 10G cada uno para tener un RAID 5 de 20G, ya que 10G se utilizarán para el cálculo de la paridad.

Una vez arrancada la máquina comprobamos que existen los discos.

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

_**Nota**_: Previamente, aunque en esta práctica no es necesario ya que los discos no se han utilizado anteriormente, es recomendable realizar un borrado del sector cero.

```bash
root@debian:~# mdadm --zero-superblock /dev/sdb /dev/sdc /dev/sdd
```

1. Procedemos a crear las particiones en formato **GPT** de la siguiente forma. A continuación se realiza el proceso para `/dev/sdb`, esto tendrá que realizarse con `/dev/sdc` y `/dev/sdd`.

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

Como resultado tendremos lo siguiente.

```bash
root@debian:~# lsblk -e7
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda      8:0    0   50G  0 disk
├─sda1   8:1    0    1M  0 part
├─sda2   8:2    0  513M  0 part /boot/efi
└─sda3   8:3    0 49,5G  0 part /var/snap/firefox/common/host-hunspell
                                /
sdb      8:16   0   10G  0 disk
└─sdb1   8:17   0   10G  0 part
sdc      8:32   0   10G  0 disk
└─sdc1   8:33   0   10G  0 part
sdd      8:48   0   10G  0 disk
└─sdd1   8:49   0   10G  0 part
sr0     11:0    1 1024M  0 rom
```

_*Nota*_: Tan correcto es realizarlo haciendo uso del comando `parted` como de la herramienta `fdisk`.

2. Llegados a este punto tendremos que instalar la aplicación **mdadm** que permitirá gestionar nuestros RAID.

```bash
root@debian:~# apt update
...
root@debian:~# apt install -y mdadm
...
```

A continuación vamos a proceder a crear nuestro RAID 5 con el siguiente comando que procedemos a explicar.

```bash
root@debian:~# mdadm -C /dev/md0 -l raid5 -n 3 /dev/sdb1 /dev/sdc1 /dev/sdd1
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
```

- `mdadm`: Programa para administrar RAIDs en sistemas Linux.
- `-C /dev/md0`: Es el nombre que se le dará a la nueva matriz RAID. El prefijo "/dev/md" es comúnmente utilizado para dispositivos RAID en Linux, y el número al final puede variar según la configuración del sistema.

- `-l raid5`: Nivel de RAID que se va a utilizar. En este caso, se está creando una matriz RAID nivel 5.

- `-n 3`: Número de dispositivos que se utilizarán en la matriz RAID.

- `/dev/sdb1 /dev/sdc1 /dev/sdd1`: Estos son los dispositivos que se están agregando a la matriz RAID.

3. Es interesante tener otra terminal con la cual poder ver cada segundo la información en detalle de `/dev/md0`.

```bash
root@debian:~# watch -n 1 mdadm --detail /dev/md0
```

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

El comando `watch` nos permite ejecutar en bucle otro comando y le indicamos que tenga una frecuencia de actualización de 1 segundo con `-n 1`.

4. Llegados a este punto tenemos creado nuestro RAID. El problema es que las configuraciones que hemos realizado no son persistentes y en próximos arranques el nombre `/dev/md0` se modificará. Para evitar esto, tenemos que ejecutar los siguientes comandos:

El primer comando añadirá la información del RAID al fichero `/etc/mdadm/mdadm.conf` para hacer persistente la ruta `/dev/md0`.

```bash
root@debian:~# mdadm --detail --scan | grep md0 | tee -a /etc/mdadm/mdadm.conf
ARRAY /dev/md0 metadata=1.2 name=debian:0 UUID=56175065:02460b89:83ee4102:738deb4b
```

El siguiente comando actualiza el arranque para que mdadm se adelante al Sistema Operativo a la hora de inicializar las particiones. La salida del comando se guarda en la ruta `/boot`. El siguiente comando incluye esta configuración de `/dev/md0` en el initramfs, asegurando que el RAID sea detectado correctamente en el próximo reinicio.

```bash
root@debian:~# update-initramfs -u
update-initramfs: Generating /boot/initrd.img-6.5.0-35-generic
```

_*Nota*_: Initramfs es el encargado de:

- Cargar los **módulos y drivers necesarios** (RAID, LVM, cifrado, etc.).
- Encuentrar y montar el **sistema de archivos raíz (`/`)**.
- Una vez listo, **pasa el control al kernel**.

En este punto todas nuestras particiones pertenecen al volumen lógico **md0**.

```bash
root@debian:~# lsblk -e7
NAME    MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
sda       8:0    0   50G  0 disk
├─sda1    8:1    0    1M  0 part
├─sda2    8:2    0  513M  0 part  /boot/efi
└─sda3    8:3    0 49,5G  0 part  /var/snap/firefox/common/host-hunspell
                                  /
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

5. Para poder almacenar datos en nuestro RAID tendremos que darle un sistema de ficheros a las particiones que lo componen.

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

6. A continuación será necesario montar nuestro RAID en el sistema. Nuestro RAID se va a montar en la ruta `/mnt/RAID5`.

```bash
root@debian:~# mkdir /mnt/RAID5
root@debian:~# mount /dev/md0 /mnt/RAID5/
root@debian:~# lsblk -e7
NAME    MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
sda       8:0    0   50G  0 disk
├─sda1    8:1    0    1M  0 part
├─sda2    8:2    0  513M  0 part  /boot/efi
└─sda3    8:3    0 49,5G  0 part  /var/snap/firefox/common/host-hunspell
                                  /
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

7. Para que el montaje del RAID se realice en cada arranque de la máquina tenemos que editar el fichero `/etc/fstab` del siguiente modo.

```bash
root@debian:~# cp -pv /etc/fstab /etc/fstab_VIEJO
'/etc/fstab' -> '/etc/fstab_VIEJO'
root@debian:~# echo "/dev/md0 /mnt/RAID5 ext4 defaults,nofail,discard 0 0" | tee -a /etc/fstab
root@debian:~# mount -a
```

8. En este punto vamos a probar nuestro RAID creando información en su interior.

```bash
root@debian:~# mkdir /mnt/RAID5/prueba && for i in $(seq 1 100); do echo "Fichero ${i}" > /mnt/RAID5/prueba/fichero${i}.txt;done
```

```bash
root@debian:~# ls /mnt/RAID5/prueba/
fichero100.txt  fichero25.txt  fichero40.txt  fichero56.txt  fichero71.txt  fichero87.txt
... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...
fichero10.txt   fichero26.txt  fichero41.txt  fichero57.txt  fichero72.txt  fichero88.txt
```

9. Ya que RAID5 soporta la perdida de un disco vamos a proceder a marcar como fallo la partición `/dev/sdd1`. Esto hará que el RAID pase a degradado pero vamos a poder trabajar sin problemas ya que RAID5 soporta la perdida de un disco.

```bash
root@debian:~#
root@debian:~# mdadm --manage /dev/md0 --fail /dev/sdd1
mdadm: set /dev/sdd1 faulty in /dev/md0
```

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

```bash
root@debian:~# ls /mnt/RAID5/prueba/
fichero100.txt  fichero25.txt  fichero40.txt  fichero56.txt  fichero71.txt  fichero87.txt
... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...
fichero10.txt   fichero26.txt  fichero41.txt  fichero57.txt  fichero72.txt  fichero88.txt
```

10. A continuación vamos a proceder a eliminar el disco y añadir otro nuevo en sustitución de este que será `/dev/sde`.

```bash
root@debian:~# mdadm --manage /dev/md0 --remove /dev/sdd1
mdadm: hot removed /dev/sdd1 from /dev/md0
```

```bash
Every 1,0s: mdadm --detail /dev/md0                            debian: Thu May 16 13:37:31 2024

/dev/md0:
           Version : 1.2
     Creation Time : Thu May 16 12:40:41 2024
        Raid Level : raid5
        Array Size : 20948992 (19.98 GiB 21.45 GB)
     Used Dev Size : 10474496 (9.99 GiB 10.73 GB)
      Raid Devices : 3
     Total Devices : 2
       Persistence : Superblock is persistent

       Update Time : Thu May 16 13:36:56 2024
             State : clean, degraded
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : debian:0  (local to host debian)
              UUID : 56175065:02460b89:83ee4102:738deb4b
            Events : 21

    Number   Major   Minor   RaidDevice State
       0       8       17        0      active sync   /dev/sdb1
       1       8       33        1      active sync   /dev/sdc1
       -       0        0        2      removed
```

11. Tenemos crear una partición en `/dev/sde` de 10G y añadir el nuevo disco al RAID. En el siguiente caso vamos a usar un disco de 20G por lo que tenemos que hacer una partición que ocupe la mitad del disco.

```bash
root@debian:~# parted -s /dev/sde mklabel gpt
root@debian:~# parted -s /dev/sde mkpart primary 0% 50%
```

```bash
root@debian:~# lsblk -e7
...
sde       8:64   0   20G  0 disk
└─sde1    8:65   0   10G  0 part
```

```bash
root@debian:~#
root@debian:~# mdadm --manage /dev/md0 --add /dev/sde1
mdadm: added /dev/sde1
```

```bash
Every 1,0s: mdadm --detail /dev/md0                            debian: Thu May 16 13:46:37 2024

/dev/md0:
           Version : 1.2
     Creation Time : Thu May 16 12:40:41 2024
        Raid Level : raid5
        Array Size : 20948992 (19.98 GiB 21.45 GB)
     Used Dev Size : 10474496 (9.99 GiB 10.73 GB)
      Raid Devices : 3
     Total Devices : 3
       Persistence : Superblock is persistent

       Update Time : Thu May 16 13:46:31 2024
             State : clean, degraded, recovering
    Active Devices : 2
   Working Devices : 3
    Failed Devices : 0
     Spare Devices : 1

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

    Rebuild Status : 4% complete

              Name : debian:0  (local to host debian)
              UUID : 56175065:02460b89:83ee4102:738deb4b
            Events : 23

    Number   Major   Minor   RaidDevice State
       0       8       17        0      active sync   /dev/sdb1
       1       8       33        1      active sync   /dev/sdc1
       3       8       65        2      spare rebuilding   /dev/sde1
```

12. Por último, mdadm permite tener un pool de discos que puedan entrar en funcionamento tan pronto como uno de los discos en funcionamiento fallen. Para ello añadiremos otro disco diferente y ejecutaremos los siguientes comandos.

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

Vemos que en este punto tenemos un disco en espera en el área de recuperación que entrará en funcionamiento si uno de los discos en uso falla.

```bash
Every 1,0s: mdadm --detail /dev/md0                            debian: Thu May 16 13:53:48 2024
/dev/md0:s: mdadm --detail /dev/md0
           Version : 1.2
     Creation Time : Thu May 16 12:40:41 2024
        Raid Level : raid5
        Array Size : 20948992 (19.98 GiB 21.45 GB)
     Used Dev Size : 10474496 (9.99 GiB 10.73 GB)
      Raid Devices : 3
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Thu May 16 13:53:43 2024
             State : clean
    Active Devices : 3
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 1

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : debian:0  (local to host debian)
              UUID : 56175065:02460b89:83ee4102:738deb4b
            Events : 41

    Number   Major   Minor   RaidDevice State
       0       8       17        0      active sync   /dev/sdb1
       1       8       33        1      active sync   /dev/sdc1
       3       8       65        2      active sync   /dev/sde1

       4       8       81        -      spare   /dev/sdf1
```

Vamos a probocar el fallo de un disco y veremos como /dev/sdf1 va a entrar en funcionamiento y el RAID sigue en modo **clean**..

```bash
root@debian:~# mdadm --manage /dev/md0 --fail /dev/sdb1
mdadm: set /dev/sdb1 faulty in /dev/md0
```

```bash
Every 1,0s: mdadm --detail /dev/md0                            debian: Thu May 16 13:58:31 2024
/dev/md0:s: mdadm --detail /dev/md0
           Version : 1.2
     Creation Time : Thu May 16 12:40:41 2024
        Raid Level : raid5
        Array Size : 20948992 (19.98 GiB 21.45 GB)
     Used Dev Size : 10474496 (9.99 GiB 10.73 GB)
      Raid Devices : 3
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Thu May 16 13:56:58 2024
             State : clean
    Active Devices : 3
   Working Devices : 3
    Failed Devices : 1
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : debian:0  (local to host debian)
              UUID : 56175065:02460b89:83ee4102:738deb4b
            Events : 60

    Number   Major   Minor   RaidDevice State
       4       8       81        0      active sync   /dev/sdf1
       1       8       33        1      active sync   /dev/sdc1
       3       8       65        2      active sync   /dev/sde1

       0       8       17        -      faulty   /dev/sdb1
```
