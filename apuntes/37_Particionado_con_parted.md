# Particionado con parted

1. Asignamos el tipo de partición.

```bash
root@si-VirtualBox:~# parted -s /dev/sdb mklabel msdos
```

2. Creamos particiones primarias, extendidas y lógicas.

```bash
root@si-VirtualBox:~# parted -s /dev/sdb mkpart primary 0% 5G
root@si-VirtualBox:~# parted -s /dev/sdb mkpart primary 5G 5G
root@si-VirtualBox:~# parted -s /dev/sdb mkpart extended 10G 100%
root@si-VirtualBox:~# parted -s /dev/sdb mkpart logical 10G 13G
root@si-VirtualBox:~# parted -s /dev/sdb print
Model: ATA VBOX HARDDISK (scsi)
Disk /dev/sdb: 26,8GB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start   End     Size    Type      File system  Flags
 1      1049kB  5000MB  4999MB  primary
 2      5000MB  5001MB  1049kB  primary
 3      10,0GB  26,8GB  16,8GB  extended               lba
 5      10,0GB  13,0GB  2999MB  logical
```

3. Tambien puedo eliminar particiones de la siguiente forma.

```bash
root@si-VirtualBox:~# parted -s /dev/sdb rm 1
```
