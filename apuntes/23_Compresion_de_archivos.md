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
- **k**: La opción --keep-old-files solicita una confirmación si el file ya existe.

A continuación vamos a realizar unos ejemplo de compresión **.gz**, **.bz2** y **.xz**

Creamos la carpeta donde trabajar.

```bash
root@debian:/tmp# mkdir prueba
root@debian:/tmp# ls -ld prueba/
drwxr-xr-x 2 root root 4096 abr 28 17:05 prueba/
root@debian:/tmp# cd /root
root@debian:~# pwd
/root
```

Dentro de la carpeta creamos 10 archivos para utilizar en la práctica.

```bash
root@debian:/tmp# for i in $(seq 1 10); do echo "Archivo $i" > prueba/archivo$i.txt; done
root@debian:/tmp# ls -l prueba/
total 40
-rw-r--r-- 1 root root 11 abr 28 17:08 archivo10.txt
-rw-r--r-- 1 root root 10 abr 28 17:08 archivo1.txt
-rw-r--r-- 1 root root 10 abr 28 17:08 archivo2.txt
-rw-r--r-- 1 root root 10 abr 28 17:08 archivo3.txt
-rw-r--r-- 1 root root 10 abr 28 17:08 archivo4.txt
-rw-r--r-- 1 root root 10 abr 28 17:08 archivo5.txt
-rw-r--r-- 1 root root 10 abr 28 17:08 archivo6.txt
-rw-r--r-- 1 root root 10 abr 28 17:08 archivo7.txt
-rw-r--r-- 1 root root 10 abr 28 17:08 archivo8.txt
-rw-r--r-- 1 root root 10 abr 28 17:08 archivo9.txt
```

## Compresión en .gz

1. Empaquetamos los archivos y los comprimirmos a formato **.gz**.

```bash
root@debian:/tmp# tar cvfz prueba.tar.gz prueba/
prueba/
prueba/archivo2.txt
prueba/archivo5.txt
prueba/archivo10.txt
prueba/archivo6.txt
prueba/archivo4.txt
prueba/archivo7.txt
prueba/archivo3.txt
prueba/archivo8.txt
prueba/archivo1.txt
prueba/archivo9.txt
```

_*Nota: Tanto la extensión `tar.gz` como `tgz` son equivalentes.*_

2. Visualizamos el contenido.

```bash
root@debian:/tmp# tar tvfz prueba.tar.gz
drwxr-xr-x root/root         0 2025-04-28 17:08 prueba/
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo2.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo5.txt
-rw-r--r-- root/root        11 2025-04-28 17:08 prueba/archivo10.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo6.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo4.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo7.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo3.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo8.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo1.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo9.txt
```

3. Eliminamos el directorio prueba.

```bash
root@debian:/tmp# rm -r prueba
```

4. Extraemos el contenido.

```bash
root@debian:/tmp# tar xvfz prueba.tar.gz
prueba/
prueba/archivo2.txt
prueba/archivo5.txt
prueba/archivo10.txt
prueba/archivo6.txt
prueba/archivo4.txt
prueba/archivo7.txt
prueba/archivo3.txt
prueba/archivo8.txt
prueba/archivo1.txt
prueba/archivo9.txt

root@debian:/tmp# ls prueba*
prueba.tar.gz

prueba:
archivo10.txt  archivo2.txt  archivo4.txt  archivo6.txt  archivo8.txt
archivo1.txt   archivo3.txt  archivo5.txt  archivo7.txt  archivo9.txt
```

_*Nota*_: Muy interesante es indicar con el parámetro **-C** la dirección donde queremos descomprimir el contenido del fichero comprimido.

```bash
root@debian:/tmp# tar xvfz prueba.tar.gz -C /root
prueba/
prueba/archivo2.txt
prueba/archivo5.txt
prueba/archivo10.txt
prueba/archivo6.txt
prueba/archivo4.txt
prueba/archivo7.txt
prueba/archivo3.txt
prueba/archivo8.txt
prueba/archivo1.txt
prueba/archivo9.txt
root@debian:/tmp# ls /root/
prueba
```

## Compresión en bz2

Eliminamos el archivo `prueba.tar.gz` ya que no nos hace falta.

```bash
root@debian:/tmp# rm -r /root/prueba/
root@debian:/tmp# rm prueba.tar.gz
```

1. Comprimirmos el directorio _prueba_ en _prueba.tar.gz2_.

```bash
root@debian:/tmp# tar cvfj prueba.tar.bz2 prueba/
prueba/
prueba/archivo2.txt
prueba/archivo5.txt
prueba/archivo10.txt
prueba/archivo6.txt
prueba/archivo4.txt
prueba/archivo7.txt
prueba/archivo3.txt
prueba/archivo8.txt
prueba/archivo1.txt
prueba/archivo9.txt
```

2. Vemos el contenido del fichero empaquetado en extensión **bz2**.

```bash
root@debian:/tmp# tar tvfj prueba.tar.bz2
drwxr-xr-x root/root         0 2025-04-28 17:08 prueba/
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo2.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo5.txt
-rw-r--r-- root/root        11 2025-04-28 17:08 prueba/archivo10.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo6.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo4.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo7.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo3.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo8.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo1.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo9.txt
```

3. Descomprimimos su contenido.

```bash
root@debian:/tmp# tar xvfj prueba.tar.bz2
prueba/
prueba/archivo2.txt
prueba/archivo5.txt
prueba/archivo10.txt
prueba/archivo6.txt
prueba/archivo4.txt
prueba/archivo7.txt
prueba/archivo3.txt
prueba/archivo8.txt
prueba/archivo1.txt
prueba/archivo9.txt
```

## Compresión con xz

Eliminamos el archivo `prueba.tar.xz` ya que no nos hace falta.

```bash
root@debian:/tmp# rm -r /root/prueba/
root@debian:/tmp# rm prueba.tar.xz
```

1. Comprimirmos el directorio _prueba_ en _prueba.tar.xz_.

```bash
root@debian:/tmp# tar cvfj prueba.tar.xz prueba/
prueba/
prueba/archivo2.txt
prueba/archivo5.txt
prueba/archivo10.txt
prueba/archivo6.txt
prueba/archivo4.txt
prueba/archivo7.txt
prueba/archivo3.txt
prueba/archivo8.txt
prueba/archivo1.txt
prueba/archivo9.txt
```

2. Vemos el contenido del fichero empaquetado en extensión **xz**.

```bash
root@debian:/tmp# tar tvfj prueba.tar.xz
drwxr-xr-x root/root         0 2025-04-28 17:08 prueba/
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo2.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo5.txt
-rw-r--r-- root/root        11 2025-04-28 17:08 prueba/archivo10.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo6.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo4.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo7.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo3.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo8.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo1.txt
-rw-r--r-- root/root        10 2025-04-28 17:08 prueba/archivo9.txt
```

3. Descomprimimos su contenido.

```bash
root@debian:/tmp# tar xvfj prueba.tar.xz
prueba/
prueba/archivo2.txt
prueba/archivo5.txt
prueba/archivo10.txt
prueba/archivo6.txt
prueba/archivo4.txt
prueba/archivo7.txt
prueba/archivo3.txt
prueba/archivo8.txt
prueba/archivo1.txt
prueba/archivo9.txt
```

## Otras cuestiones y comandos de compresión

| Comando | Compresor | Finalidad                                                    |
| ------- | --------- | ------------------------------------------------------------ |
| zcat    | gzip      | Muestra el contenido de un fichero de texto comprimido .gz.  |
| zless   | gzip      | Pagina el contenido de un fichero de texto comprimido .gz.   |
| bzcat   | bzip2     | Muestra el contenido de un fichero de texto comprimido .bz2. |
| bzless  | bzip2     | Pagina el contenido de un fichero de texto comprimido .bz2.  |
| xzcat   | xz        | Muestra el contenido de un fichero de texto comprimido .xz.  |
| xzless  | xz        | Pagina el contenido de un fichero de texto comprimido .xz.   |

```bash
root@debian:/tmp# zcat prueba.tar.gz
prueba/0000755000000000000000000000000015004102071011020 5ustar  rootrootprueba/arch9.txt0000644000000000000000000000002115004102071012560 0ustar  rootrootSoy el fichero 9
prueba/arch7.txt0000644000000000000000000000002115004102071012556 0ustar  rootrootSoy el fichero 7
prueba/arch8.txt0000644000000000000000000000002115004102071012557 0ustar  rootrootSoy el fichero 8
prueba/arch5.txt0000644000000000000000000000002115004102071012554 0ustar  rootrootSoy el fichero 5
prueba/arch2.txt0000644000000000000000000000002115004102071012551 0ustar  rootrootSoy el fichero 2
prueba/arch6.txt0000644000000000000000000000002115004102071012555 0ustar  rootrootSoy el fichero 6
prueba/arch1.txt0000644000000000000000000000002115004102071012550 0ustar  rootrootSoy el fichero 1
prueba/arch4.txt0000644000000000000000000000002115004102071012553 0ustar  rootrootSoy el fichero 4
prueba/arch3.txt0000644000000000000000000000002115004102071012552 0ustar  rootrootSoy el fichero 3
prueba/arch10.txt0000644000000000000000000000002215004102071012631 0ustar  rootrootSoy el fichero 10
```

# Comando zip

El comando zip permite comprimir y descomprimir archivos con extensión `.zip`. Puede darse la necesidad de tener que instalarlo con `sudo apt install zip -y`.

```bash
root@debian:/tmp# zip -r prueba.zip prueba
  adding: prueba/ (stored 0%)
root@debian:/tmp# file prueba.zip
prueba.zip: Zip archive data, at least v1.0 to extract, compression method=store
```

Para el proceso de descomprimir zip en linux lo realizamos de la siguiente forma:

```bash
root@debian:/tmp# rm -r prueba
root@debian:/tmp# unzip prueba.zip
Archive:  prueba.zip
   creating: prueba/
 extracting: prueba/arch9.txt
 extracting: prueba/arch7.txt
 extracting: prueba/arch8.txt
 extracting: prueba/arch5.txt
 extracting: prueba/arch2.txt
 extracting: prueba/arch6.txt
 extracting: prueba/arch1.txt
 extracting: prueba/arch4.txt
 extracting: prueba/arch3.txt
 extracting: prueba/arch10.txt
root@debian:/tmp# ls prueba
arch10.txt  arch1.txt  arch2.txt  arch3.txt  arch4.txt  arch5.txt  arch6.txt  arch7.txt  arch8.txt  arch9.txt
```

_*Nota*_: Si queremos indicar la ruta de destino con _unzip_ tenemos el parámetro _-d_ para indicar el directorio de destino.

```bash
root@debian:/tmp# unzip -d prueba.zip /root
unzip:  cannot find or open /root, /root.zip or /root.ZIP.
root@debian:/tmp# unzip -d /root prueba.zip
Archive:  prueba.zip
   creating: /root/prueba/
 extracting: /root/prueba/arch9.txt
 extracting: /root/prueba/arch7.txt
 extracting: /root/prueba/arch8.txt
 extracting: /root/prueba/arch5.txt
 extracting: /root/prueba/arch2.txt
 extracting: /root/prueba/arch6.txt
 extracting: /root/prueba/arch1.txt
 extracting: /root/prueba/arch4.txt
 extracting: /root/prueba/arch3.txt
 extracting: /root/prueba/arch10.txt
root@debian:/tmp# ls /root
prueba
root@debian:/tmp# ls /root/prueba/
arch10.txt  arch1.txt  arch2.txt  arch3.txt  arch4.txt  arch5.txt  arch6.txt  arch7.txt  arch8.txt  arch9.txt
```

# Comando rar

Para comprimir .rar, debemos utilizar

```bash
rar -a archivo.rar /carpeta/archivos
```

Para descomprimir .rar, debemos utilizar:

```bash
rar -x archivo.rar
```
