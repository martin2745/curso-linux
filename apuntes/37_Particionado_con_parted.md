# Particionado con parted

1. Asignamos el tipo de particionado.

**MBR**

```bash
root@si-VirtualBox:~# parted -s /dev/sdb mklabel msdos
```

**GPT**

```bash
root@si-VirtualBox:~# parted -s /dev/sdb mklabel gpt
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

_*Nota*_: A diferencia de MBR, en GPT no hay distinción entre particiones primarias, extendidas o lógicas. Todas las particiones son "primarias".

3. Tambien puedo eliminar particiones de la siguiente forma.

```bash
root@si-VirtualBox:~# parted -s /dev/sdb rm 1
```

4. Proceso de montado.
   Una vez realizado todo este proceso, lo siguiente sería realizar el montado de las particiones o realizar las modificaciones en el `/etc/fstab` para que se cargen en el inicio.

### Ejercicio

Crear un script bash llamado **`particionar.sh`** que realice las siguientes acciones:

1. Crear una tabla de particiones **GPT** en el disco **`/dev/sdb`**.
2. Crear tres particiones de tipo **ext4** con las siguientes distribuciones:
   - **Partición 1**: 0% a 50% del disco.
   - **Partición 2**: 50% a 75% del disco.
   - **Partición 3**: 75% a 100% del disco.
3. Formatear cada partición recién creada con el sistema de archivos **ext4**.
4. Mostrar la tabla de particiones del disco **`/dev/sdb`**.

Notas:

1. El script debe ejecutarse con permisos de administrador, ya que se manipula un disco.
2. Añadir comentarios explicativos para cada comando que se ejecute.
3. El script debe ser ejecutado con el siguiente comando: `sudo bash particionar.sh`

#### Solución:

```bash
#!/bin/bash
parted -s /dev/sdb mklabel gpt
parted -s /dev/sdb mkpart primary ext4 0% 50%
parted -s /dev/sdb mkpart primary ext4 50% 75%
parted -s /dev/sdb mkpart primary ext4 75% 100%
parted -s /dev/sdb print

# Formatear las particiones
mkfs.ext4 /dev/sdb1
mkfs.ext4 /dev/sdb2
mkfs.ext4 /dev/sdb3
```
