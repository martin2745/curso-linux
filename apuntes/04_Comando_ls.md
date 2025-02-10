# Comando ls

El comando ls lista archivos y directorios en un directorio especificado.

```bash
martin@debian12:~$ ls -l
total 36
drwxr-xr-x 2 martin martin 4096 mar  4 09:58 d1
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Descargas
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Documentos
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Escritorio
-rw-r--r-- 1 martin martin    0 abr 12 16:29 fichero.txt
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Imágenes
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Música
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Plantillas
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Público
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Vídeos
```

_*Nota: Se refiere el campo de fecha a la hora en la que se hizo la última modificación de contenido del fichero o directorio (creacción o eliminación de contenido en su interior).*_

Parámetros bien conocidos:

- -l: Información extendida.
- -h: Tamaño del archivo en formato humano.
- -i: Número de inodo.
- -a: Archivos ocultos.
- -r: Inverso.
- -v: Ordena la salida.
- --sort: Para ordenar.
- --size: En función del tamaño.
- --format: Para dar un formato a la salida.
- --time: Para mostrar por atime, mtime, o ctime.
- -1: Muestra en vertical la salida.

1. -t: Lista los ficheros o directorios más nuevos al principio.

```bash
martin@debian12:~$ ls -l -t
martin@debian12:~$ ls -l --sort=time
```

```bash
martin@debian12:~$ ls -l -t
total 36
-rw-r--r-- 1 martin martin    0 abr 12 16:29 fichero.txt
drwxr-xr-x 2 martin martin 4096 mar  4 09:58 d1
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Descargas
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Documentos
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Escritorio
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Imágenes
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Música
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Plantillas
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Público
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Vídeos
```

2. -S: Lista por tamaño de mayor a menor.

```bash
martin@debian12:~$ ls -l -S
martin@debian12:~$ ls -l --sort=size
```

```bash
martin@debian12:~$ ls -l -S
total 36
drwxr-xr-x 2 martin martin 4096 mar  4 09:58 d1
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Descargas
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Documentos
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Escritorio
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Imágenes
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Música
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Plantillas
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Público
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Vídeos
-rw-r--r-- 1 martin martin    0 abr 12 16:29 fichero.txt
```

3. -m: Listado de elementos separados por comas.

```bash
martin@debian12:~$ ls -m
martin@debian12:~$ ls -l --format=commas
```

```bash
martin@debian12:~$ ls -m
d1, Descargas, Documentos, Escritorio, fichero.txt, Imágenes, Música, Plantillas,
Público, Vídeos
```

4. Vertical, Horizontal y una columna: El listado se realiza por linea y no por columa.

```bash
martin@debian12:~$ ls -x
martin@debian12:~$ ls -l --format=horizontal
```

```bash
martin@debian12:~$ ls
d1         Documentos  fichero.txt  Música      Público
Descargas  Escritorio  Imágenes     Plantillas  Vídeos

martin@debian12:~$ ls --format=vertical
d1         Documentos  fichero.txt  Música      Público
Descargas  Escritorio  Imágenes     Plantillas  Vídeos

martin@debian12:~$ ls -x
d1       Descargas  Documentos  Escritorio  fichero.txt  Imágenes  Música  Plantillas
Público  Vídeos

martin@debian12:~$ ls --format=horizontal
d1       Descargas  Documentos  Escritorio  fichero.txt  Imágenes  Música  Plantillas
Público  Vídeos

martin@debian12:~$ ls --format=single-column
d1
Descargas
Documentos
Escritorio
fichero.txt
Imágenes
Música
Plantillas
Público
Vídeos
```

5. Ordenación vertical ordenada de un directorio con `ls -v -1`.

```bash
si@si-VirtualBox:~$ ls
Desktop  Documents  Downloads  Music  Pictures  prueba  Public  snap  Templates  Videos
si@si-VirtualBox:~$ ls -1
Desktop
Documents
Downloads
Music
Pictures
prueba
Public
snap
Templates
Videos
si@si-VirtualBox:~$ ls -1 -v
Desktop
Documents
Downloads
Music
Pictures
Public
Templates
Videos
prueba
snap
```