# Particionado en Linux con fdisk

## fdisk

`fdisk` es la herramienta de administración de discos y particiones
tradicional del shell de Linux.

`fdisk -l`: Tabla de particiones de todos los discos.
`fdisk -l /dev/sdb`: Tabla de particiones de `/dev/sdb`.
`fdisk /dev/sdb`: Modo de edición del disco `/dev/sdb`.
Opciones de `fdisk`

- `w`: Guardar.
- `q`: Salir.
- `n`: Crear partición.
- `p`: Permite crear una partición primaria.
- `e`: Permite crear una partición extendida.
- `m`: Ayuda.
- `d`: Eliminar una partición.
- `g`: Cambiamos la etiqueta DOS(MBR) a GPT. Eliminaría la tabla de particiones.
- `o`: Cambiamos la etiqueta GPT a MBR(DOS). Eliminaría la tabla de particiones.

A continuación creamos una partición primaria en el disco `/dev/sdb` de 10G.

```bash
root@si-VirtualBox:~# fdisk /dev/sdb

Welcome to fdisk (util-linux 2.37.2).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1):
First sector (2048-52428799, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-52428799, default 52428799): +10G

Created a new partition 1 of type 'Linux' and of size 10 GiB.

Command (m for help): p
Disk /dev/sdb: 25 GiB, 26843545600 bytes, 52428800 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xceaf73bb

Device     Boot Start      End  Sectors Size Id Type
/dev/sdb1        2048 20973567 20971520  10G 83 Linux
```

Una vez creada la partición vamos a partición extendida de 15G.

```bash
Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): e
Partition number (2-4, default 2):
First sector (20973568-52428799, default 20973568):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (20973568-52428799, default 52428799):

Created a new partition 2 of type 'Extended' and of size 15 GiB.

Command (m for help): p
Disk /dev/sdb: 25 GiB, 26843545600 bytes, 52428800 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xceaf73bb

Device     Boot    Start      End  Sectors Size Id Type
/dev/sdb1           2048 20973567 20971520  10G 83 Linux
/dev/sdb2       20973568 52428799 31455232  15G  5 Extended
```

Añadimos ahora una partición lógica de 5G y guardamos la configuración.

```bash
Command (m for help): n
All space for primary partitions is in use.
Adding logical partition 5
First sector (20975616-52428799, default 20975616):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (20975616-52428799, default 52428799): +5G

Created a new partition 5 of type 'Linux' and of size 5 GiB.

Command (m for help): p
Disk /dev/sdb: 25 GiB, 26843545600 bytes, 52428800 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xceaf73bb

Device     Boot    Start      End  Sectors Size Id Type
/dev/sdb1           2048 20973567 20971520  10G 83 Linux
/dev/sdb2       20973568 52428799 31455232  15G  5 Extended
/dev/sdb5       20975616 31461375 10485760   5G 83 Linux

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

root@si-VirtualBox:~#
```

Veamos ahora el resultado final.

```bash
root@si-VirtualBox:~# fdisk -l /dev/sdb
Disk /dev/sdb: 25 GiB, 26843545600 bytes, 52428800 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xceaf73bb

Device     Boot    Start      End  Sectors Size Id Type
/dev/sdb1           2048 20973567 20971520  10G 83 Linux
/dev/sdb2       20973568 52428799 31455232  15G  5 Extended
/dev/sdb5       20975616 31461375 10485760   5G 83 Linux
```

Si quisiéramos borrar una tabla de particiones en fdisk nos bastaría con cambiar la etiqueta, por ejemplo de DOS (MBR) a GPT con la opción `g`, o a la inversa con la opción `o`. Si nos fijamos, la etiqueta de la tabla de particiones se va a modificar.

```bash
root@si-VirtualBox:~# fdisk -l /dev/sdb
Disk /dev/sdb: 25 GiB, 26843545600 bytes, 52428800 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xceaf73bb

Device     Boot    Start      End  Sectors Size Id Type
/dev/sdb1           2048 20973567 20971520  10G 83 Linux
/dev/sdb2       20973568 52428799 31455232  15G  5 Extended
/dev/sdb5       20975616 31461375 10485760   5G 83 Linux
root@si-VirtualBox:~# fdisk /dev/sdb

Welcome to fdisk (util-linux 2.37.2).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): g
Created a new GPT disklabel (GUID: 9D46AE3B-2D99-F94C-8C2F-3A58DB60DC6F).
The device contains 'dos' signature and it will be removed by a write command. See fdisk(8) man page and --wipe option for more details.

Command (m for help): p

Disk /dev/sdb: 25 GiB, 26843545600 bytes, 52428800 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 9D46AE3B-2D99-F94C-8C2F-3A58DB60DC6F
```

### blkid

`blkid`: Permite consultar el identificador único de cada disco. Como no tienen un sistema de ficheros asignado el identificador va a tener el tamaño que se muestra a continuación.

```bash
root@si-VirtualBox:~# blkid | grep sdb
/dev/sdb5: PARTUUID="20eab2f1-05"
/dev/sdb1: PARTUUID="20eab2f1-01"
```

### mkfs

`mkfs` Permite aplicar un formato de sistema de ficheros a una partición.

`mkfs.ext4 /dev/sdb1` Formatea la partición 1 del disco /dev/sdb con formato ext4.
`mkfs -t ext4 /dev/sdb5` Igual al anterior.

```bash
root@si-VirtualBox:~# mkfs.ext4 /dev/sdb1
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 2621440 4k blocks and 655360 inodes
Filesystem UUID: c5e35664-cef9-4345-afbb-82a6723b2659
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

root@si-VirtualBox:~# mkfs -t ext4 /dev/sdb5
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 1310720 4k blocks and 327680 inodes
Filesystem UUID: 054a4742-ad44-4132-bfb9-ce927f9bfdc3
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```

A continuación vamos a ver el identificador que se ha asociado a las particiones con un sistema de ficheros asignado.

```bash
root@si-VirtualBox:~# blkid | grep sdb
/dev/sdb1: UUID="c5e35664-cef9-4345-afbb-82a6723b2659" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="20eab2f1-01"
/dev/sdb5: UUID="054a4742-ad44-4132-bfb9-ce927f9bfdc3" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="20eab2f1-05"
```

### mount y umount

El paso final para poder leer y escribir de particiones es montarlas en
una ruta del sistema de archivos para lo cual utilizaremos el comando
mount:

`mount /dev/sdb1 /media/datos1` Monta la partición 1 del disco /dev/sdb en
la ruta /media/datos1.

`umount /dev/sdb1` Desmonta la partición 1 del disco /dev/sdb de donde esté
montada.

Vamos a montar la partición en la ruta `/media/datos1`. Una vez montada podremos crear contenido en su interior que se guardará en el dispositivo `/dev/sdb1`.

```bash
root@si-VirtualBox:~# mkdir /media/datos1 && mount /dev/sdb1 /media/datos1
root@si-VirtualBox:~# mount | grep /dev/sdb1
/dev/sdb1 on /media/datos1 type ext4 (rw,relatime)
root@si-VirtualBox:~# df -Th
Filesystem     Type   Size  Used Avail Use% Mounted on
tmpfs          tmpfs  391M  1,5M  390M   1% /run
/dev/sda3      ext4    49G   16G   30G  35% /
tmpfs          tmpfs  2,0G     0  2,0G   0% /dev/shm
tmpfs          tmpfs  5,0M  4,0K  5,0M   1% /run/lock
/dev/sda2      vfat   512M  6,1M  506M   2% /boot/efi
tmpfs          tmpfs  391M   80K  391M   1% /run/user/128
tmpfs          tmpfs  391M   68K  391M   1% /run/user/1000
/dev/sdb1      ext4   9,8G  8,0K  9,3G   1% /media/datos1

root@si-VirtualBox:~# for i in $(seq 1 10); do echo "Fichero ${i}" > /media/datos1/fichero${i}.txt; done
root@si-VirtualBox:~# ls /media/datos1/
fichero10.txt  fichero2.txt  fichero4.txt  fichero6.txt  fichero8.txt  fichero.txt
fichero1.txt   fichero3.txt  fichero5.txt  fichero7.txt  fichero9.txt
```

### fstab

Para que el montaje de la partición `/dev/sdb1` sea persistente y no tener que volver a realizar este proceso cuando encendamos de nuevo el ordenador tenemos que añadir la configuración correspondiente en el fichero `/etc/fstab`. Tenemos que tener cuidado con las modificaciones realizadas en este fichero ya que si los datos introducidos son incorrectos podría no iniciarse el ordenador. Para ello vamos a hacer un `cp -pv /etc/fstab /etc/fstab_VIEJO` y ejecutar el comando `mount -a` para ver si tenemos algún error antes de reiniciar la máquina.

```bash
root@si-VirtualBox:~# cp -pv /etc/fstab /etc/fstab_VIEJO
'/etc/fstab' -> '/etc/fstab_VIEJO'
```

Neceitamos añadir en una nueva entrada del `/etc/fstab` el identificador de la partición. Dentro del `/etc/fstab` la entrada va a tener 6 columnas de datos:

- El UUID o nombre de partición, el punto de montaje y el tipo de sistema de archivos.
- Opciones de montaje. Si dejamos `defaults` se aplicarán opciones por defecto según el sistema de archivos, pero hay múltiples opciones que nos permite configurar: si queremos o no montaje automático, modo de sólo lectura o lectura/escritura, permitir o bloquear el uso de los bits suid y sgid, limitar los usuarios que pueden montar la partición, ...
- Opción dump: Número de veces que se aplicará un backup al sistema de ficheros por el programa dump (0 indica que no se aplica).
- Opción pass: Orden en el que se comprobará el sistema de archivos en el arranque. El 1 se reservar para el sistema raíz (/). Si ponemos un 0 no se comprueba en el arranque.

```bash
root@si-VirtualBox:~# blkid | grep sdb1
/dev/sdb1: UUID="c5e35664-cef9-4345-afbb-82a6723b2659" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="20eab2f1-01"
```

```bash
root@si-VirtualBox:~# nano /etc/fstab
```

```bash
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/sda3 during installation
UUID=887fddd5-c130-4d0e-a814-03c02bdd0050 /               ext4    errors=remount-ro 0       1
# /boot/efi was on /dev/sda2 during installation
UUID=683C-B0C4  /boot/efi       vfat    umask=0077      0       1
/swapfile                                 none            swap    sw              0       0
UUID="c5e35664-cef9-4345-afbb-82a6723b2659"     /media/datos1   ext4    defaults        0       2
```

Si tuvieramos algún error en la configuración del `/etc/fstab` debería notificarmelo por pantalla. Como no exite ningún error reiniciamos la máquina.

```bash
root@si-VirtualBox:~# mount -a
```
