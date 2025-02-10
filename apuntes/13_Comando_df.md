
# Comando df

El comando `df` en sistemas Unix/Linux se utiliza para mostrar el espacio disponible y utilizado en los sistemas de archivos montados. Proporciona información sobre el uso del disco a nivel de sistema de archivos. Aquí te muestro cómo se usa y algunas de sus opciones más comunes:

**Opciones comunes**:

- `-h` (human-readable): Esta opción muestra los tamaños en un formato legible para humanos (por ejemplo, KB, MB, GB).

- `-T` (print-type): Muestra el tipo de sistema de archivos.

- `-i` (inodes): Muestra información sobre el número de inodos utilizados y disponibles en lugar de la información sobre el espacio de disco.

```bash
si@si-VirtualBox:/tmp$ df
Filesystem     1K-blocks     Used Available Use% Mounted on
tmpfs             400104     1468    398636   1% /run
/dev/sda3       50770432 16547340  31611688  35% /
tmpfs            2000504        0   2000504   0% /dev/shm
tmpfs               5120        4      5116   1% /run/lock
/dev/sda2         524252     6220    518032   2% /boot/efi
tmpfs             400100       80    400020   1% /run/user/128
tmpfs             400100       68    400032   1% /run/user/1000

si@si-VirtualBox:/tmp$ df -h
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           391M  1,5M  390M   1% /run
/dev/sda3        49G   16G   31G  35% /
tmpfs           2,0G     0  2,0G   0% /dev/shm
tmpfs           5,0M  4,0K  5,0M   1% /run/lock
/dev/sda2       512M  6,1M  506M   2% /boot/efi
tmpfs           391M   80K  391M   1% /run/user/128
tmpfs           391M   68K  391M   1% /run/user/1000

si@si-VirtualBox:/tmp$ df -Th
Filesystem     Type   Size  Used Avail Use% Mounted on
tmpfs          tmpfs  391M  1,5M  390M   1% /run
/dev/sda3      ext4    49G   16G   31G  35% /
tmpfs          tmpfs  2,0G     0  2,0G   0% /dev/shm
tmpfs          tmpfs  5,0M  4,0K  5,0M   1% /run/lock
/dev/sda2      vfat   512M  6,1M  506M   2% /boot/efi
tmpfs          tmpfs  391M   80K  391M   1% /run/user/128
tmpfs          tmpfs  391M   68K  391M   1% /run/user/1000

si@si-VirtualBox:/tmp$ df -Tih
Filesystem     Type  Inodes IUsed IFree IUse% Mounted on
tmpfs          tmpfs   489K   999  488K    1% /run
/dev/sda3      ext4    3,1M  244K  2,9M    8% /
tmpfs          tmpfs   489K     1  489K    1% /dev/shm
tmpfs          tmpfs   489K     5  489K    1% /run/lock
/dev/sda2      vfat       0     0     0     - /boot/efi
tmpfs          tmpfs    98K    82   98K    1% /run/user/128
tmpfs          tmpfs    98K    74   98K    1% /run/user/1000
```