# Comando tar

El comando `tar` se utiliza en sistemas Linux y Unix para crear, listar, extraer y manipular archivos y directorios empaquetados en un solo archivo.

## Parámetros

- **c**: Crea un nuevo archivo tar.
- **x**: Extrae los archivos de un archivo tar.
- **t**: Lista el contenido de un archivo tar.
- **v**: Muestra información detallada (verbose) sobre las operaciones realizadas.
- **f**: Especifica el nombre del archivo tar que se va a crear, extraer o manipular.
- **j**: Utiliza el formato bzip2 para comprimir o descomprimir el archivo tar.
- **z**: Utiliza el formato gzip para comprimir o descomprimir el archivo tar.

Proceso de compresión con `tar`

```bash
martin@debian12:/tmp/prueba$ tar cvfz fichero.tar.gz fichero*.txt
fichero1.txt
fichero2.txt
fichero3.txt
fichero4.txt
fichero5.txt

martin@debian12:/tmp/prueba$ tar cvfj fichero.tar.bz2 fichero*.txt
fichero1.txt
fichero2.txt
fichero3.txt
fichero4.txt
fichero5.txt

martin@debian12:/tmp/prueba$ ls -lh
total 28K
-rw-r--r-- 1 martin martin   5 abr 13 08:52 fichero1.txt
-rw-r--r-- 1 martin martin   5 abr 13 08:52 fichero2.txt
-rw-r--r-- 1 martin martin   5 abr 13 08:52 fichero3.txt
-rw-r--r-- 1 martin martin   5 abr 13 08:52 fichero4.txt
-rw-r--r-- 1 martin martin   5 abr 13 08:52 fichero5.txt
-rw-r--r-- 1 martin martin 201 abr 13 08:53 fichero.tar.bz2
-rw-r--r-- 1 martin martin 179 abr 13 08:53 fichero.tar.gz
```

Proceso de listado de contenido con `tar`

```bash
martin@debian12:/tmp/prueba$ tar tf fichero.tar.gz
fichero1.txt
fichero2.txt
fichero3.txt
fichero4.txt
fichero5.txt

martin@debian12:/tmp/prueba$ tar tvf fichero.tar.gz
-rw-r--r-- martin/martin     5 2024-04-13 08:52 fichero1.txt
-rw-r--r-- martin/martin     5 2024-04-13 08:52 fichero2.txt
-rw-r--r-- martin/martin     5 2024-04-13 08:52 fichero3.txt
-rw-r--r-- martin/martin     5 2024-04-13 08:52 fichero4.txt
-rw-r--r-- martin/martin     5 2024-04-13 08:52 fichero5.txt

martin@debian12:/tmp/prueba$ tar tvfz fichero.tar.gz
-rw-r--r-- martin/martin     5 2024-04-13 08:52 fichero1.txt
-rw-r--r-- martin/martin     5 2024-04-13 08:52 fichero2.txt
-rw-r--r-- martin/martin     5 2024-04-13 08:52 fichero3.txt
-rw-r--r-- martin/martin     5 2024-04-13 08:52 fichero4.txt
-rw-r--r-- martin/martin     5 2024-04-13 08:52 fichero5.txt

martin@debian12:/tmp/prueba$ tar tvfj fichero.tar.gz
bzip2: (stdin) is not a bzip2 file.
tar: Child returned status 2
tar: Error is not recoverable: exiting now
```

Proceso de descompresión con `tar`

```bash
martin@debian12:/tmp/prueba$ ls
fichero.tar.bz2  fichero.tar.gz

martin@debian12:/tmp/prueba$ tar xvfz fichero.tar.gz
fichero1.txt
fichero2.txt
fichero3.txt
fichero4.txt
fichero5.txt

martin@debian12:/tmp/prueba$ ls
fichero1.txt  fichero3.txt  fichero5.txt     fichero.tar.gz
fichero2.txt  fichero4.txt  fichero.tar.bz2

martin@debian12:/tmp/prueba$ mkdir /tmp/temporal && tar xvfj fichero.tar.bz2 -C /tmp/temporal
fichero1.txt
fichero2.txt
fichero3.txt
fichero4.txt
fichero5.txt

martin@debian12:/tmp/prueba$ ls /tmp/temporal/
fichero1.txt  fichero2.txt  fichero3.txt  fichero4.txt  fichero5.txt
```

Importante lo siguiente en `tar` si se quiere usar el `-` con los parametros. Siempre que usemos `-` tenemos que poner el orden de los parametros `cvzf`, es decir, siempre la f que indica el fichero resultante al final.

```bash
martin@debian12:/tmp/prueba$ tar -cvzf fichero.tar.gz fichero*.txt
fichero1.txt
fichero2.txt
fichero3.txt
fichero4.txt
fichero5.txt

martin@debian12:/tmp/prueba$ ls
fichero1.txt  fichero3.txt  fichero5.txt
fichero2.txt  fichero4.txt  fichero.tar.gz
```

_*Nota: Tanto la extensión `tar.gz` como `tgz` son equivalentes.*_
