# Comando atime, mtime, ctime y touch

- **atime (Access Time)**: Indica la última vez que se accedió al contenido del archivo.
- **mtime (Modified Time)**: Representa la última vez que el contenido del archivo fue modificado.
- **ctime (Change Time)**: Refleja el tiempo en que se cambiaron los metadatos del archivo, es decir, a nivel de permisos, propietario. Podemos verlo como cambios a nivel de inodo.

_*Nota: El inodo en Linux es una estructura de datos que almacena información importante sobre archivos y directorios en un sistema de archivos. Cada archivo y directorio en un sistema de archivos Linux está asociado con un inodo único. El inodo contiene metadatos sobre el archivo o directorio, como permisos, tamaño, propietario, tipo de archivo, fechas de acceso, modificación y cambio, y punteros a bloques de datos que contienen el contenido real del archivo o la lista de nombres de archivos en un directorio. Los inodos son cruciales para la gestión y organización de los archivos en el sistema de archivos, permitiendo al sistema operativo acceder eficientemente a la información y los datos de los archivos.*_

```bash
martin@debian12:/tmp/temporal$ stat fichero1.txt
  Fichero: fichero1.txt
  Tamaño: 5             Bloques: 8          Bloque E/S: 4096   fichero regular
Device: 8,1     Inode: 1700631     Links: 1
Acceso: (0644/-rw-r--r--)  Uid: ( 1000/  martin)   Gid: ( 1000/  martin)
      Acceso: 2024-04-13 09:23:48.618999425 +0200
Modificación: 2024-04-13 08:52:06.000000000 +0200
      Cambio: 2024-04-13 09:23:48.618999425 +0200
    Creación: 2024-04-13 09:23:48.618999425 +0200

martin@debian12:/tmp/temporal$ cat fichero1.txt
Hola
martin@debian12:/tmp/temporal$ stat fichero1.txt
  Fichero: fichero1.txt
  Tamaño: 5             Bloques: 8          Bloque E/S: 4096   fichero regular
Device: 8,1     Inode: 1700631     Links: 1
Acceso: (0644/-rw-r--r--)  Uid: ( 1000/  martin)   Gid: ( 1000/  martin)
      Acceso: 2024-04-13 10:12:22.169098495 +0200
Modificación: 2024-04-13 08:52:06.000000000 +0200
      Cambio: 2024-04-13 09:23:48.618999425 +0200
    Creación: 2024-04-13 09:23:48.618999425 +0200

martin@debian12:/tmp/temporal$ echo "Adios" >> fichero1.txt
martin@debian12:/tmp/temporal$ stat fichero1.txt
  Fichero: fichero1.txt
  Tamaño: 11            Bloques: 8          Bloque E/S: 4096   fichero regular
Device: 8,1     Inode: 1700631     Links: 1
Acceso: (0644/-rw-r--r--)  Uid: ( 1000/  martin)   Gid: ( 1000/  martin)
      Acceso: 2024-04-13 10:12:22.169098495 +0200
Modificación: 2024-04-13 10:12:36.010174997 +0200
      Cambio: 2024-04-13 10:12:36.010174997 +0200
    Creación: 2024-04-13 09:23:48.618999425 +0200

martin@debian12:/tmp/temporal$ chmod 777 fichero1.txt
martin@debian12:/tmp/temporal$ stat fichero1.txt
  Fichero: fichero1.txt
  Tamaño: 11            Bloques: 8          Bloque E/S: 4096   fichero regular
Device: 8,1     Inode: 1700631     Links: 1
Acceso: (0777/-rwxrwxrwx)  Uid: ( 1000/  martin)   Gid: ( 1000/  martin)
      Acceso: 2024-04-13 10:12:22.169098495 +0200
Modificación: 2024-04-13 10:12:36.010174997 +0200
      Cambio: 2024-04-13 10:12:59.494427849 +0200
    Creación: 2024-04-13 09:23:48.618999425 +0200
```

Para ver por separado con stat cada parametro tenemos las opciones:

- **x**: atime
- **y**: mtime
- **z**: ctime

```bash
martin@debian12:/tmp/temporal$ stat fichero1.txt
  Fichero: fichero1.txt
  Tamaño: 11            Bloques: 8          Bloque E/S: 4096   fichero regular
Device: 8,1     Inode: 1700631     Links: 1
Acceso: (0777/-rwxrwxrwx)  Uid: ( 1000/  martin)   Gid: ( 1000/  martin)
      Acceso: 2024-04-13 10:12:22.169098495 +0200
Modificación: 2024-04-13 10:12:36.010174997 +0200
      Cambio: 2024-04-13 10:12:59.494427849 +0200
    Creación: 2024-04-13 09:23:48.618999425 +0200

martin@debian12:/tmp/temporal$ stat -c '%x' fichero1.txt
2024-04-13 10:12:22.169098495 +0200

martin@debian12:/tmp/temporal$ stat -c '%y' fichero1.txt
2024-04-13 10:12:36.010174997 +0200

martin@debian12:/tmp/temporal$ stat -c '%z' fichero1.txt
2024-04-13 10:12:59.494427849 +0200

martin@debian12:/tmp/temporal$ stat -c '%z, %n' fichero1.txt
2024-04-13 10:12:59.494427849 +0200, fichero1.txt
```

Tambien se puede ordenar por tiempo con ls. `ls --time=ctime`

```bash
martin@debian12:/tmp/temporal$ ls --time=atime
martin@debian12:/tmp/temporal$ ls -u

martin@debian12:/tmp/temporal$ ls --time=mtime
martin@debian12:/tmp/temporal$ ls -t

martin@debian12:/tmp/temporal$ ls --time=ctime
martin@debian12:/tmp/temporal$ ls -c
```

`touch` en Linux es un comando que se utiliza para crear archivos vacíos o actualizar las marcas de tiempo de archivos existentes. Se usa principalmente para crear archivos nuevos o actualizar las fechas de acceso y modificación de archivos existentes sin cambiar su contenido.
-a Cambia la fecha de acceso del archivo
-m Cambia la fecha de modificación
-r archivo Toma la fecha del archivo como referencia
-t time Valor de la fecha en decimal. Formato: *aaaaMMddHHmm.ss*

```bash
martin@debian12:/tmp/temporal$ touch fichero.txt
martin@debian12:/tmp/temporal$ ls -l fichero.txt
-rw-r--r-- 1 martin martin 0 abr 13 11:01 fichero.txt
martin@debian12:/tmp/temporal$ stat fichero.txt
  Fichero: fichero.txt
  Tamaño: 0             Bloques: 0          Bloque E/S: 4096   fichero regular vacío
Device: 8,1     Inode: 1700631     Links: 1
Acceso: (0644/-rw-r--r--)  Uid: ( 1000/  martin)   Gid: ( 1000/  martin)
      Acceso: 2024-04-13 11:01:20.991071163 +0200
Modificación: 2024-04-13 11:01:20.991071163 +0200
      Cambio: 2024-04-13 11:01:20.991071163 +0200
    Creación: 2024-04-13 11:01:20.987073163 +0200

martin@debian12:/tmp/temporal$ touch --date='2022-03-29 17:53:03' fichero.txt
martin@debian12:/tmp/temporal$ ls -l fichero.txt
-rw-r--r-- 1 martin martin 0 mar 29  2022 fichero.txt
martin@debian12:/tmp/temporal$ stat fichero.txt
  Fichero: fichero.txt
  Tamaño: 0             Bloques: 0          Bloque E/S: 4096   fichero regular vacío
Device: 8,1     Inode: 1700631     Links: 1
Acceso: (0644/-rw-r--r--)  Uid: ( 1000/  martin)   Gid: ( 1000/  martin)
      Acceso: 2022-03-29 17:53:03.000000000 +0200
Modificación: 2022-03-29 17:53:03.000000000 +0200
      Cambio: 2024-04-13 11:01:36.831147160 +0200
    Creación: 2024-04-13 11:01:20.987073163 +0200

martin@debian12:/tmp/temporal$ touch -a --date='2023-04-29 17:53:03' fichero.txt
martin@debian12:/tmp/temporal$ stat fichero.txt
  Fichero: fichero.txt
  Tamaño: 0             Bloques: 0          Bloque E/S: 4096   fichero regular vacío
Device: 8,1     Inode: 1700631     Links: 1
Acceso: (0644/-rw-r--r--)  Uid: ( 1000/  martin)   Gid: ( 1000/  martin)
      Acceso: 2023-04-29 17:53:03.000000000 +0200
Modificación: 2022-03-29 17:53:03.000000000 +0200
      Cambio: 2024-04-13 11:02:06.188461159 +0200
    Creación: 2024-04-13 11:01:20.987073163 +0200

martin@debian12:/tmp/temporal$ touch -m --date='2023-04-29 17:53:03' fichero.txt
martin@debian12:/tmp/temporal$ stat fichero.txt
  Fichero: fichero.txt
  Tamaño: 0             Bloques: 0          Bloque E/S: 4096   fichero regular vacío
Device: 8,1     Inode: 1700631     Links: 1
Acceso: (0644/-rw-r--r--)  Uid: ( 1000/  martin)   Gid: ( 1000/  martin)
      Acceso: 2023-04-29 17:53:03.000000000 +0200
Modificación: 2023-04-29 17:53:03.000000000 +0200
      Cambio: 2024-04-13 11:02:33.170963160 +0200
    Creación: 2024-04-13 11:01:20.987073163 +0200
```
