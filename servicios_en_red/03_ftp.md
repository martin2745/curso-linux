# Servicio FTP

**FTP (File Transfer Protocol / Protocolo de Transferencia de Archivos)**

Es un protocolo de red estándar de comunicaciones diseñado específicamente para enviar, recibir y gestionar archivos entre dos equipos conectados a una red TCP/IP (como Internet o tu red local). Funciona bajo un modelo cliente-servidor, donde un usuario (el cliente) se conecta a una máquina remota (el servidor) para subir, descargar o administrar carpetas y documentos. Como características principales destacamos.

- **Especialización:** Está optimizado exclusivamente para la transferencia y estructuración de archivos, no para ejecutar comandos a distancia.
- **Funcionamiento a dos vías:** Separa la comunicación; utiliza el **puerto 21** para enviar las "órdenes" (comandos, usuario, contraseña) y abre puertos adicionales para mover el peso de los datos reales.
- **Seguridad:** Su mayor debilidad es que, en su versión clásica, **no tiene cifrado**. Toda la información viaja en texto plano por la red, motivo por el cual en entornos profesionales actuales ha sido sustituido por alternativas seguras como SFTP o FTPS.

## Índice

1. [Instalación de ProFTPD](#1-instalaci%C3%B3n-de-proftpd)
2. [Gestión de la Conexión](#2-gesti%C3%B3n-de-la-conexi%C3%B3n)
3. [Navegación (Servidor Remoto y Equipo Local)](#3-navegaci%C3%B3n-servidor-remoto-y-equipo-local)
4. [Transferencia de Archivos](#4-transferencia-de-archivos-subir-y-bajar)
5. [Manipulación de Archivos en el Servidor](#5-manipulaci%C3%B3n-de-archivos-en-el-servidor)
6. [Ajustes de la Transferencia](#6-ajustes-de-la-transferencia-muy-importante)
7. [Cuestiones de seguridad a tener en cuenta](#7-cuestiones-de-seguridad-a-tener-en-cuenta)

---

## 1. Instalación de ProFTPD

```bash
usuario@debian:~$ sudo apt update && sudo apt install -y proftpd
```

| Comando/Parámetro | Descripción |
|-------------------|-------------|
| `apt install`     | Instala el servicio o paquete del repositorio por defecto. |
| `proftpd`         | Software a instalar, en este caso uno de los servidores FTP más populares y configurables en Linux. |
| `-y`              | Acepta la instalación sin preguntar interactivamente al administrador. |

```bash
usuario@debian:~$ systemctl status proftpd
● proftpd.service - ProFTPD FTP Server
     Loaded: loaded (/lib/systemd/system/proftpd.service; enabled; preset: enabled)
     Active: active (running) since Thu 2026-04-16 10:35:03 CEST; 25s ago
       Docs: man:proftpd(8)
    Process: 4161 ExecStartPre=/usr/sbin/proftpd --configtest -c $CONFIG_FILE $OPTION>
    Process: 4162 ExecStart=/usr/sbin/proftpd -c $CONFIG_FILE $OPTIONS (code=exited, >
   Main PID: 4163 (proftpd)
      Tasks: 1 (limit: 4615)
     Memory: 1.9M
        CPU: 35ms
     CGroup: /system.slice/proftpd.service
             └─4163 "proftpd: (accepting connections)"
lines 1-12/12 (END)
```

| Comando | Descripción |
|---------|-------------|
| `systemctl status`| Despliega el estado del servicio (información si el demonio ha arrancado, si está activo de manera persistente y los primeros registros). |

```bash
proftpd:x:114:65534::/run/proftpd:/usr/sbin/nologin
ftp:x:115:65534::/srv/ftp:/usr/sbin/nologin
```

```bash
usuario@debian:~$ ls -l /etc/proftpd/
total 1340
-rw-r--r-- 1 root root 1310700 nov 30  2024 blacklist.dat
drwxr-xr-x 2 root root    4096 nov 30  2024 conf.d
-rw-r--r-- 1 root root    9420 nov 30  2024 dhparams.pem
-rw-r--r-- 1 root root    4353 abr 16 10:35 geoip.conf
-rw------- 1 root root     701 abr 16 10:35 ldap.conf
-rw-r--r-- 1 root root    3454 abr 16 10:35 modules.conf
-rw-r--r-- 1 root root    5822 abr 16 10:35 proftpd.conf
-rw-r--r-- 1 root root    1186 abr 16 10:35 sftp.conf
-rw-r--r-- 1 root root     982 abr 16 10:35 snmp.conf
-rw------- 1 root root     862 abr 16 10:35 sql.conf
-rw-r--r-- 1 root root    2082 abr 16 10:35 tls.conf
-rw-r--r-- 1 root root     832 abr 16 10:35 virtuals.conf
```

```bash
usuario@debian:/etc/proftpd$ cat /etc/ftpusers
# /etc/ftpusers: list of users disallowed FTP access. See ftpusers(5).

root
daemon
bin
sys
sync
games
man
lp
mail
news
uucp
nobody
```

```bash
┌──(kali㉿kali)-[~]
└─$ ftp 192.168.50.4
Connected to 192.168.50.4.
220 Servidor ProFTPD (Debian) [::ffff:192.168.50.4]
Name (192.168.50.4:kali): usuario
331 Contraseña necesaria para usuario
Password:
230 Usuario usuario conectado
Remote system type is UNIX.
Using binary mode to transfer files.

ftp> pwd
Remote directory: /home/usuario

ftp> ls
229 Entering Extended Passive Mode (|||6351|)
150 Abriendo conexión de datos en modo ASCII para file list
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Descargas
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Documentos
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Escritorio
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Imágenes
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Música
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Plantillas
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Público
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Vídeos
226 Transferencia completada
```

Puedo por defecto acceder con cualquier usuario del sistema que no esté en /etc/`ftpusers`.

Cuando instalas un servidor FTP "desde cero" en Linux (siendo el más común y popular **`vsftpd`**, o alternativas como **`proftpd`**), los usuarios que puedes utilizar por defecto dependen de la configuración inicial de seguridad de tu distribución, pero generalmente se rigen por las siguientes reglas:

 1. Usuarios Locales del Sistema (Habilitados por defecto)
En la gran mayoría de las distribuciones modernas (como Ubuntu, Debian, CentOS), la instalación por defecto viene configurada para permitir el acceso a los **usuarios locales**. 

2. Usuarios del Sistema Bloqueados (La lista negra)
Por motivos estrictos de seguridad, **no todos** los usuarios locales pueden acceder, aunque tengan contraseña. 

El sistema crea automáticamente un archivo de texto llamado `/etc/ftpusers` (o `/etc/`vsftpd`.ftpusers`). Cualquier usuario que aparezca en esa lista **tendrá el acceso denegado**, incluso si pone bien la contraseña. Por defecto, incluye a usuarios críticos del sistema operativo como:
* `root` (El administrador principal, nunca debe acceder por FTP directamente).
* `daemon`, `bin`, `sys`, `sync`, `games`, `www-data`, etc.

3. El Usuario Anónimo (Deshabilitado por defecto en la actualidad)
Históricamente, los servidores FTP venían con el acceso público activado. Hoy en día, por razones de seguridad, casi todas las instalaciones nuevas traen esto **desactivado**.

* **Si estuviera activado:** Podrías entrar usando el nombre de usuario **`anonymous`** o **`ftp`**, y se suele pedir una dirección de correo electrónico (incluso inventada) como contraseña o directamente sin contraseña.
* **Para activarlo (si lo necesitas):** Tendrías que editar el archivo de configuración (ej. `/etc/`vsftpd`.conf`) y cambiar la directiva `anonymous_enable=NO` a `anonymous_enable=YES`.

```bash
ftp> ?
Commands may be abbreviated.  Commands are:

!               epsv4           mdir            pmlsd           send
$               epsv6           mget            preserve        sendport
account         exit            mkdir           progress        set
append          features        mls             prompt          site
ascii           fget            mlsd            proxy           size
bell            form            mlst            put             sndbuf
binary          ftp             mode            pwd             status
bye             gate            modtime         quit            struct
case            get             more            quote           sunique
cd              glob            mput            rate            system
cdup            hash            mreget          rcvbuf          tenex
chmod           help            msend           recv            throttle
close           idle            newer           reget           trace
connect         image           nlist           remopts         type
cr              lcd             nmap            rename          umask
debug           less            ntrans          reset           unset
delete          lpage           open            restart         usage
dir             lpwd            page            rhelp           user
disconnect      ls              passive         rmdir           verbose
edit            macdef          pdir            rstatus         xferbuf
epsv            mdelete         pls             runique         ?
ftp> ? get
get             receive file
ftp> ? mget
mget            get multiple files
```

> **Nota:** Tambien puedo conectarme a través del explorador de archivos escribiendo la ruta *ftp://usuario:contraseña@ip_servidor o *ftp://ip_servidor* lo que pedirá la contraseña.

Escribir `?` (o la palabra `help`) en la consola del FTP es el atajo clásico para desplegar la ayuda interna del cliente. Te mostrará un listado enorme de comandos, muchos de los cuales son heredados de sistemas antiguos y ya casi no se usan.

### 2. Gestión de la Conexión
* **`quit`**, **`bye`** o **`exit`**: Cierra la conexión con el servidor y te devuelve a tu terminal normal de Linux.
* **`close`** o **`disconnect`**: Cierra la sesión actual con el servidor, pero te mantiene dentro del programa FTP por si quieres conectarte a otro distinto usando el comando `open`.
* **`open [IP_del_servidor]`**: Sirve para iniciar una conexión hacia un servidor FTP.

```bash
┌──(kali㉿kali)-[~]
└─$ ftp
ftp> open 192.168.50.4
Connected to 192.168.50.4.
220 Servidor ProFTPD (Debian) [::ffff:192.168.50.4]
Name (192.168.50.4:kali): usuario
331 Contraseña necesaria para usuario
Password:
230 Usuario usuario conectado
Remote system type is UNIX.
Using binary mode to transfer files.

ftp> pwd
Remote directory: /home/usuario

ftp> close
221 Hasta luego

ftp> open 192.168.50.4
Connected to 192.168.50.4.
220 Servidor ProFTPD (Debian) [::ffff:192.168.50.4]
Name (192.168.50.4:kali): usuario
331 Contraseña necesaria para usuario
Password:
230 Usuario usuario conectado
Remote system type is UNIX.
Using binary mode to transfer files.

ftp> pwd
Remote directory: /home/usuario

ftp> exit
221 Hasta luego
```

### 3. Navegación (Servidor Remoto y Equipo Local)
* **`pwd`**: Imprime en pantalla la ruta exacta de la carpeta en la que estás **en el servidor**.
* **`lpwd`**: Imprime en pantalla la ruta de la carpeta en la que estás **en tu propio ordenador** (Local Print Working Directory).
* **`ls`** o **`dir`**: Lista los archivos y carpetas que hay en tu ubicación actual del servidor.
* **`cd [carpeta]`**: Entra en un directorio del servidor.
* **`lcd [carpeta]`**: Cambia el directorio de tu propio ordenador (fundamental para decidir dónde se van a guardar los archivos que descargues).
* **`cdup`**: Sube un nivel en la jerarquía de carpetas del servidor (es el equivalente exacto a escribir `cd ..`).

```bash
┌──(kali㉿kali)-[~]
└─$ ftp 192.168.50.4
Connected to 192.168.50.4.
220 Servidor ProFTPD (Debian) [::ffff:192.168.50.4]
Name (192.168.50.4:kali): usuario
331 Contraseña necesaria para usuario
Password:
230 Usuario usuario conectado
Remote system type is UNIX.
Using binary mode to transfer files.

ftp> pwd
Remote directory: /home/usuario

ftp> lpwd
Local directory: /home/kali

ftp> ls
229 Entering Extended Passive Mode (|||43191|)
150 Abriendo conexión de datos en modo ASCII para file list
drwxr-xr-x   2 usuario  usuario      4096 Apr 16 09:11 Descargas
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Documentos
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Escritorio
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Imágenes
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Música
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Plantillas
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Público
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Vídeos
226 Transferencia completada

ftp> dir
229 Entering Extended Passive Mode (|||64140|)
150 Abriendo conexión de datos en modo ASCII para file list
drwxr-xr-x   2 usuario  usuario      4096 Apr 16 09:11 Descargas
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Documentos
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Escritorio
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Imágenes
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Música
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Plantillas
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Público
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Vídeos
226 Transferencia completada

ftp> cd /tmp
250 orden CWD ejecutada correctamente

ftp> pwd
Remote directory: /tmp

ftp> cdup
250 orden CDUP ejecutada correctamente

ftp> pwd
Remote directory: /

ftp> lpwd
Local directory: /home/kali

ftp> lcd /home
Local directory now: /home

ftp> lpwd
Local directory: /home
```

### 4. Transferencia de Archivos (Subir y Bajar)
* **`get [nombre_archivo]`**: Descarga un único archivo del servidor y lo guarda en tu equipo local.
* **`mget [archivos]`**: Descarga múltiples archivos a la vez. Puedes usar comodines, por ejemplo, `mget *.txt` descargará todos los archivos de texto de esa carpeta.
* **`put [nombre_archivo]`**: Sube un archivo de tu equipo local hacia el servidor.
* **`mput [archivos]`**: Sube múltiples archivos al servidor a la vez.

Tenemos la siguiente información en el servidor.

```bash
usuario@debian:~/Escritorio$ tree
.
├── fi1.txt
├── fi2.txt
├── fi3.txt
└── subcarpeta
    ├── sub_fi1.txt
    ├── sub_fi2.txt
    └── sub_fi3.txt

2 directories, 6 files
```

```bash
ftp> cd Escritorio
250 orden CWD ejecutada correctamente

ftp> pwd
Remote directory: /home/usuario/Escritorio
```

Traer un archivo.

```bash
ftp> lpwd
Local directory: /home/kali
ftp> lcd Desktop
Local directory now: /home/kali/Desktop
```

```bash
ftp> get fi1.txt
local: fi1.txt remote: fi1.txt
229 Entering Extended Passive Mode (|||27617|)
150 Opening BINARY mode data connection for fi1.txt (5 bytes)
100% |*************************************************|     5       46.50 KiB/s    00:00 ETA
226 Transferencia completada
5 bytes received in 00:00 (4.15 KiB/s)
```

Traer varios archivos.

```bash
ftp> mget fi2.txt fi3.txt
mget fi2.txt [anpqy?]? a
Prompting off for duration of mget.
229 Entering Extended Passive Mode (|||7701|)
150 Opening BINARY mode data connection for fi2.txt (5 bytes)
100% |*************************************************|     5       24.05 KiB/s    00:00 ETA
226 Transferencia completada
5 bytes received in 00:00 (4.29 KiB/s)
229 Entering Extended Passive Mode (|||13368|)
150 Opening BINARY mode data connection for fi3.txt (5 bytes)
100% |*************************************************|     5       29.77 KiB/s    00:00 ETA
226 Transferencia completada
5 bytes received in 00:00 (4.64 KiB/s)
```

Al utilizar el comando múltiple `mget` o `mput`, el cliente FTP asume por precaución que quieres confirmar manualmente cada archivo. Esa extraña cadena de letras [anpqy?]? son las respuestas rápidas que el sistema espera que introduzcas para decidir qué hacer con el primer archivo (fi2.txt):

y (Yes): Sí, descargar este archivo y preguntarme por el siguiente.

n (No): No descargar este archivo, saltarlo y preguntarme por el siguiente.

a (All): Sí a todo. Descargar este archivo y todos los que queden en la lista sin volver a preguntar.

q (Quit): Cancelar la operación entera y no descargar nada más.

p (Prompt): Apaga el modo interactivo en este mismo instante.

```bash
┌──(kali㉿kali)-[~/Desktop]
└─$ ls -l
total 16
-rw-rw-r-- 1 kali kali    5 abr 16 13:18 fi1.txt
-rw-rw-r-- 1 kali kali    5 abr 16 13:18 fi2.txt
-rw-rw-r-- 1 kali kali    5 abr 16 13:18 fi3.txt
```

> **Nota:** Para mover archivos sueltos, ftp es una buena alternativa pero en el momento en que necesites mover carpetas enteras no es posible por razones de seguridad, existen alternativas más modernas como `lftp` o sino emplear herramientas como `wget` que trabajan a través de web. Para el contenido de las carpetas deberíamos hacer algo como lo siguiente.

```bash
ftp> lpwd
Local directory: /home/kali/Desktop
ftp> !mkdir subcarpeta
ftp> lcd subcarpeta/
Local directory now: /home/kali/Desktop/subcarpeta
ftp> pwd
Remote directory: /home/usuario/Escritorio/subcarpeta
ftp> ls
229 Entering Extended Passive Mode (|||54257|)
150 Abriendo conexión de datos en modo ASCII para file list
-rw-r--r--   1 usuario  usuario         5 Apr 16 11:18 sub_fi1.txt
-rw-r--r--   1 usuario  usuario         5 Apr 16 11:18 sub_fi2.txt
-rw-r--r--   1 usuario  usuario         5 Apr 16 11:18 sub_fi3.txt
226 Transferencia completada
ftp> mget *
mget sub_fi2.txt [anpqy?]? a
Prompting off for duration of mget.
229 Entering Extended Passive Mode (|||63355|)
150 Opening BINARY mode data connection for sub_fi2.txt (5 bytes)
100% |*************************************************|     5      143.61 KiB/s    00:00 ETA
226 Transferencia completada
5 bytes received in 00:00 (3.68 KiB/s)
229 Entering Extended Passive Mode (|||1483|)
150 Opening BINARY mode data connection for sub_fi3.txt (5 bytes)
100% |*************************************************|     5       23.14 KiB/s    00:00 ETA
226 Transferencia completada
5 bytes received in 00:00 (4.50 KiB/s)
229 Entering Extended Passive Mode (|||39251|)
150 Opening BINARY mode data connection for sub_fi1.txt (5 bytes)
100% |*************************************************|     5       51.94 KiB/s    00:00 ETA
226 Transferencia completada
5 bytes received in 00:00 (6.47 KiB/s)
```

```bash
┌──(kali㉿kali)-[~/Desktop]
└─$ tree                     
.
├── fi1.txt
├── fi2.txt
├── fi3.txt
└── subcarpeta
    ├── sub_fi1.txt
    ├── sub_fi2.txt
    └── sub_fi3.txt

2 directories, 6 files
```

Ahora eliminados los archivos en el servidor vamos a realizar la transferencia de los archivos de la carpeta subcarpeta al servidor.

Para ejecutar comandos en tu propio ordenador (el cliente) mientras mantienes abierta la conexión FTP con el servidor, tienes que usar el signo de exclamación (!) justo delante del comando que quieras lanzar.

```bash
ftp> lpwd
Local directory: /home/kali
ftp> lcd Desktop/
Local directory now: /home/kali/Desktop
ftp> !tree
.
├── fi1.txt
├── fi2.txt
├── fi3.txt
└── subcarpeta
    ├── sub_fi1.txt
    ├── sub_fi2.txt
    └── sub_fi3.txt

2 directories, 6 files
ftp> pwd
Remote directory: /home/usuario/Escritorio
ftp> ls
229 Entering Extended Passive Mode (|||44251|)
150 Abriendo conexión de datos en modo ASCII para file list
226 Transferencia completada
```

```bash
ftp> put fi1.txt 
local: fi1.txt remote: fi1.txt
229 Entering Extended Passive Mode (|||43279|)
150 Abriendo conexión de datos en modo BINARY para fi1.txt
100% |*************************************************|     5       42.09 KiB/s    00:00 ETA
226 Transferencia completada
5 bytes sent in 00:00 (2.52 KiB/s)
ftp> ls
229 Entering Extended Passive Mode (|||25782|)
150 Abriendo conexión de datos en modo ASCII para file list
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:33 fi1.txt
226 Transferencia completada
ftp> mput fi*
mput fi1.txt [anpqy?]? a
Prompting off for duration of mput.
229 Entering Extended Passive Mode (|||36902|)
150 Abriendo conexión de datos en modo BINARY para fi1.txt
100% |*************************************************|     5       16.22 KiB/s    00:00 ETA
226 Transferencia completada
5 bytes sent in 00:00 (2.04 KiB/s)
229 Entering Extended Passive Mode (|||58375|)
150 Abriendo conexión de datos en modo BINARY para fi2.txt
100% |*************************************************|     5       15.21 KiB/s    00:00 ETA
226 Transferencia completada
5 bytes sent in 00:00 (1.76 KiB/s)
229 Entering Extended Passive Mode (|||24503|)
150 Abriendo conexión de datos en modo BINARY para fi3.txt
100% |*************************************************|     5       15.95 KiB/s    00:00 ETA
226 Transferencia completada
5 bytes sent in 00:00 (1.52 KiB/s)
ftp> ls
229 Entering Extended Passive Mode (|||21214|)
150 Abriendo conexión de datos en modo ASCII para file list
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:34 fi1.txt
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:34 fi2.txt
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:34 fi3.txt
```

```bash
ftp> lcd /home/kali/Desktop/subcarpeta/
Local directory now: /home/kali/Desktop/subcarpeta
ftp> mput *
mput sub_fi1.txt [anpqy?]? a
Prompting off for duration of mput.
229 Entering Extended Passive Mode (|||28437|)
150 Abriendo conexión de datos en modo BINARY para sub_fi1.txt
100% |******************************************f*******|     5       41.73 KiB/s    00:00 ETA
226 Transferencia completada
5 bytes sent in 00:00 (2.42 KiB/s)
229 Entering Extended Passive Mode (|||28965|)
150 Abriendo conexión de datos en modo BINARY para sub_fi2.txt
100% |*************************************************|     5       34.38 KiB/s    00:00 ETA
226 Transferencia completada
5 bytes sent in 00:00 (1.94 KiB/s)
229 Entering Extended Passive Mode (|||24759|)
150 Abriendo conexión de datos en modo BINARY para sub_fi3.txt
100% |*************************************************|     5       50.86 KiB/s    00:00 ETA
226 Transferencia completada
5 bytes sent in 00:00 (1.54 KiB/s)
ftp> pwd
Remote directory: /home/usuario/Escritorio/subcarpeta
ftp> ls
229 Entering Extended Passive Mode (|||37587|)
150 Abriendo conexión de datos en modo ASCII para file list
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:35 sub_fi1.txt
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:35 sub_fi2.txt
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:35 sub_fi3.txt
```

### 5. Manipulación de Archivos en el Servidor
* **`mkdir [nombre]`**: Crea una nueva carpeta en el servidor.
* **`rmdir [nombre]`**: Elimina una carpeta del servidor (normalmente tiene que estar vacía).
* **`delete [archivo]`**: Borra un archivo específico del servidor.
* **`mdelete [archivos]`**: Borra múltiples archivos a la vez en el servidor (ej. `mdelete *.bak`).
* **`rename [nombre_viejo] [nombre_nuevo]`**: Cambia el nombre de un archivo o carpeta en el servidor.

```bash
ftp> ls
229 Entering Extended Passive Mode (|||58768|)
150 Abriendo conexión de datos en modo ASCII para file list
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:35 sub_fi1.txt
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:35 sub_fi2.txt
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:35 sub_fi3.txt
226 Transferencia completada

ftp> delete sub_fi1.txt
250 orden DELE ejecutada correctamente

ftp> ls
229 Entering Extended Passive Mode (|||55312|)
150 Abriendo conexión de datos en modo ASCII para file list
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:35 sub_fi2.txt
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:35 sub_fi3.txt
226 Transferencia completada

ftp> mdelete sub_fi*
mdelete sub_fi2.txt [anpqy?]? a
Prompting off for duration of mdelete.
250 orden DELE ejecutada correctamente
250 orden DELE ejecutada correctamente

ftp> ls
229 Entering Extended Passive Mode (|||5666|)
150 Abriendo conexión de datos en modo ASCII para file list
226 Transferencia completada

ftp> cd ..
250 orden CWD ejecutada correctamente

ftp> pwd
Remote directory: /home/usuario/Escritorio

ftp> ls
229 Entering Extended Passive Mode (|||13539|)
150 Abriendo conexión de datos en modo ASCII para file list
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:34 fi1.txt
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:34 fi2.txt
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:34 fi3.txt
drwxr-xr-x   2 usuario  usuario      4096 Apr 16 12:37 subcarpeta
226 Transferencia completada

ftp> rename subcarpeta renombrado
350 Archivo o directorio existente, esperando el nombre destino
250 Renombrado ejecutado correctamente

ftp> ls
229 Entering Extended Passive Mode (|||25802|)
150 Abriendo conexión de datos en modo ASCII para file list
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:34 fi1.txt
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:34 fi2.txt
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:34 fi3.txt
drwxr-xr-x   2 usuario  usuario      4096 Apr 16 12:37 renombrado
226 Transferencia completada

ftp> mkdir nueva_carpeta
257 "/home/usuario/Escritorio/nueva_carpeta" - Directorio creado correctamente

ftp> ls
229 Entering Extended Passive Mode (|||38995|)
150 Abriendo conexión de datos en modo ASCII para file list
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:34 fi1.txt
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:34 fi2.txt
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:34 fi3.txt
drwxr-xr-x   2 usuario  usuario      4096 Apr 16 12:38 nueva_carpeta
drwxr-xr-x   2 usuario  usuario      4096 Apr 16 12:37 renombrado
226 Transferencia completada

ftp> rmdir renombrado
250 orden RMD ejecutada correctamente

ftp> ls
229 Entering Extended Passive Mode (|||4334|)
150 Abriendo conexión de datos en modo ASCII para file list
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:34 fi1.txt
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:34 fi2.txt
-rw-r--r--   1 usuario  usuario         5 Apr 16 12:34 fi3.txt
drwxr-xr-x   2 usuario  usuario      4096 Apr 16 12:38 nueva_carpeta
226 Transferencia completada

ftp> mdelete *
mdelete nueva_carpeta [anpqy?]? a
Prompting off for duration of mdelete.
550 nueva_carpeta: Es un directorio
250 orden DELE ejecutada correctamente
250 orden DELE ejecutada correctamente
250 orden DELE ejecutada correctamente

ftp> ls
229 Entering Extended Passive Mode (|||65168|)
150 Abriendo conexión de datos en modo ASCII para file list
drwxr-xr-x   2 usuario  usuario      4096 Apr 16 12:38 nueva_carpeta
226 Transferencia completada

ftp> rmdir nueva_carpeta
250 orden RMD ejecutada correctamente

ftp> ls
229 Entering Extended Passive Mode (|||31199|)
150 Abriendo conexión de datos en modo ASCII para file list
226 Transferencia completada
```

### 6. Ajustes de la Transferencia (Muy Importante)
* **`binary`**: Cambia el modo de transferencia a binario. **Debes usar esto siempre** antes de descargar o subir imágenes, vídeos, ejecutables o archivos comprimidos (.zip, .tar). Si no lo haces, los archivos se corromperán en el camino.
* **`ascii`**: Cambia el modo de transferencia a texto. Es el modo por defecto y solo debe usarse para mover archivos de texto plano (como `.txt`, `.html`, `.conf`).
* **`prompt`**: Activa o desactiva el modo interactivo. Por defecto, cuando usas `mget` o `mput` para mover varios archivos, el FTP te preguntará `[s/n]` (sí o no) por **cada uno de los archivos**. Escribir `prompt` desactiva esa molesta confirmación y los mueve todos de golpe.

```bash
ftp> binary
200 Tipo establecido en I

ftp> ascii
200 Tipo establecido en A

ftp> prompt
Interactive mode off.

ftp> prompt
Interactive mode on.
```

```bash
┌──(kali㉿kali)-[~/Desktop]
└─$ tree  
.
├── fi1.txt
├── fi2.txt
├── fi3.txt
└── subcarpeta
    ├── sub_fi1.txt
    ├── sub_fi2.txt
    └── sub_fi3.txt

2 directories, 6 files

┌──(kali㉿kali)-[~]
└─$ tar -cvzf Desktop.tar.gz Desktop
Desktop/
Desktop/fi1.txt
Desktop/subcarpeta/
Desktop/subcarpeta/sub_fi1.txt
Desktop/subcarpeta/sub_fi2.txt
Desktop/subcarpeta/sub_fi3.txt
Desktop/fi3.txt
Desktop/fi2.txt
                                                                                              
┌──(kali㉿kali)-[~]
└─$ tar -tvzf Desktop.tar.gz        
drwxrwxr-x kali/kali         0 2026-04-16 14:44 Desktop/
-rw-rw-r-- kali/kali         5 2026-04-16 14:44 Desktop/fi1.txt
drwxrwxr-x kali/kali         0 2026-04-16 14:44 Desktop/subcarpeta/
-rw-rw-r-- kali/kali         5 2026-04-16 14:44 Desktop/subcarpeta/sub_fi1.txt
-rw-rw-r-- kali/kali         5 2026-04-16 14:44 Desktop/subcarpeta/sub_fi2.txt
-rw-rw-r-- kali/kali         5 2026-04-16 14:44 Desktop/subcarpeta/sub_fi3.txt
-rw-rw-r-- kali/kali         5 2026-04-16 14:44 Desktop/fi3.txt
-rw-rw-r-- kali/kali         5 2026-04-16 14:44 Desktop/fi2.txt
```

```bash
ftp> binary
200 Tipo establecido en I

ftp> ls
229 Entering Extended Passive Mode (|||23583|)
150 Abriendo conexión de datos en modo ASCII para file list
drwxr-xr-x   2 usuario  usuario      4096 Apr 16 09:11 Descargas
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Documentos
drwxr-xr-x   2 usuario  usuario      4096 Apr 16 12:39 Escritorio
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Imágenes
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Música
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Plantillas
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Público
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Vídeos
226 Transferencia completada

ftp> put Desktop.tar.gz
local: Desktop.tar.gz remote: Desktop.tar.gz
229 Entering Extended Passive Mode (|||4900|)
150 Abriendo conexión de datos en modo BINARY para Desktop.tar.gz
100% |*************************************************|   282        2.51 MiB/s    00:00 ETA
226 Transferencia completada
282 bytes sent in 00:00 (128.26 KiB/s)

ftp> ls
229 Entering Extended Passive Mode (|||46519|)
150 Abriendo conexión de datos en modo ASCII para file list
drwxr-xr-x   2 usuario  usuario      4096 Apr 16 09:11 Descargas
-rw-r--r--   1 usuario  usuario       282 Apr 16 12:50 Desktop.tar.gz
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Documentos
drwxr-xr-x   2 usuario  usuario      4096 Apr 16 12:39 Escritorio
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Imágenes
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Música
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Plantillas
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Público
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Vídeos
226 Transferencia completada
```

```bash
usuario@debian:~$ tar -xvzf Desktop.tar.gz
Desktop/
Desktop/fi1.txt
Desktop/subcarpeta/
Desktop/subcarpeta/sub_fi1.txt
Desktop/subcarpeta/sub_fi2.txt
Desktop/subcarpeta/sub_fi3.txt
Desktop/fi3.txt
Desktop/fi2.txt
```

| Comando/Parámetro | Descripción |
|-------------------|-------------|
| `tar`             | Utilidad principal de empaquetado y compresión clásica en GNU/Linux. |
| `-c`              | Crea (Create) un nuevo archivo empaquetado. |
| `-x`              | Extrae (eXtract) los archivos desde un contenedor empaquetado. |
| `-v`              | Modo Verbose; muestra qué archivos están siendo procesados en pantalla. |
| `-z`              | Emplea la compresión gzip para reducir el peso resultante (`.tar.gz`). |
| `-f`              | Archivo (File). Muestra que el siguiente argumento es el nombre del archivo final. |

### 7. Cuestiones de seguridad a tener en cuenta

#### Modificar el puerto de escucha

Podemos modificar el puerto por defecto del servicio FTP editando el archivo `/etc/proftpd/proftpd.conf`. Luego la conexión se realiza en el nuevo puerto.

```bash
usuario@debian:~$ ftp 192.168.50.4 <NUEVO_PUERTO>
```

#### Directiva DefaultRoot

La directiva DefaultRoot es, sin duda, la configuración de seguridad más importante de cualquier servidor FTP. En el mundo de la administración de sistemas, a esto se le conoce coloquialmente como crear una "jaula chroot" (chroot jail).

```bash
usuario@debian:~$ sudo cat -n /etc/proftpd/proftpd.conf | grep DefaultRoot
    39  # DefaultRoot ~
   102  # chroot (e.g. DefaultRoot or <Anonymous>), it will use the non-daylight

usuario@debian:~$ sudo nano /etc/proftpd/proftpd.conf

usuario@debian:~$ sudo cat -n /etc/proftpd/proftpd.conf | grep DefaultRoot
    39  DefaultRoot ~
   102  # chroot (e.g. DefaultRoot or <Anonymous>), it will use the non-daylight

usuario@debian:~$ sudo systemctl reload proftpd

usuario@debian:~$ sudo systemctl status proftpd
```

Fijémonos que ahora no podemos movernos a cualquier ruta del sistema.

```bash
┌──(kali㉿kali)-[~]
└─$ ftp 192.168.50.4                                       
Connected to 192.168.50.4.
220 Servidor ProFTPD (Debian) [::ffff:192.168.50.4]
Name (192.168.50.4:kali): usuario
331 Contraseña necesaria para usuario
Password: 
230 Usuario usuario conectado
Remote system type is UNIX.
Using binary mode to transfer files.

ftp> pwd
Remote directory: /

ftp> cd /home
550 /home: No existe el fichero o el directorio

ftp> ls
229 Entering Extended Passive Mode (|||48185|)
150 Abriendo conexión de datos en modo ASCII para file list
drwxr-xr-x   2 usuario  usuario      4096 Apr 16 09:11 Descargas
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Documentos
drwxr-xr-x   2 usuario  usuario      4096 Apr 16 12:39 Escritorio
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Imágenes
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Música
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Plantillas
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Público
drwxr-xr-x   2 usuario  usuario      4096 May  2  2025 Vídeos
226 Transferencia completada
```

#### Usuario anónimo

El Usuario Anónimo en FTP (Acceso Público)

**¿Qué es y para qué sirve?**
Históricamente, el protocolo FTP se diseñó para compartir archivos a nivel mundial de forma abierta (por ejemplo, para distribuir distribuciones de Linux o documentos públicos). El usuario anónimo permite que cualquier persona se conecte a tu servidor **sin tener una cuenta creada en tu sistema operativo**.

* **Usuario:** Se utiliza la palabra **`anonymous`** (o a veces simplemente `ftp`).
* **Contraseña:** Por convención y cortesía, los servidores pedían que introdujeras tu dirección de correo electrónico como contraseña, pero en la práctica, el servidor suele aceptar cualquier texto inventado o simplemente pulsar Enter.
* **Seguridad:** Por motivos evidentes, hoy en día las instalaciones nuevas traen esto **desactivado por defecto**. Si lo activas, el usuario anónimo normalmente entra en un entorno de "solo lectura" (puede descargar, pero no puede subir archivos ni borrar nada).

---

Cómo activarlo (En ProFTPD)

Si necesitas montar un servidor público donde la gente pueda descargarse archivos sin pedirte credenciales, tienes que habilitar este módulo en la configuración.

**Paso 1: Editar el archivo de configuración**
Abre tu terminal normal (fuera de la sesión FTP) y entra al archivo principal:
```bash
sudo nano /etc/proftpd/proftpd.conf
```

**Paso 2: Descomentar el bloque Anónimo**
Busca una sección que empieza por `<Anonymous ~ftp>`. Esto es un bloque de configuración entero (como si fuera una etiqueta de HTML) que viene desactivado con almohadillas (`#`). 

Para activarlo en su forma más básica y segura (solo lectura), debes quitarle el símbolo `#` a las siguientes líneas esenciales para que queden así:

```bash
<Anonymous ~ftp>
   User                         ftp
   Group                        nogroup
   UserAlias                    anonymous ftp
   DirFakeUser  on ftp
   DirFakeGroup on ftp
   RequireValidShell            off
   MaxClients                   10
   <Directory *>
     <Limit WRITE>
       DenyAll
     </Limit>
   </Directory>
</Anonymous>
```
*(**Nota:** Guárdalo con `Ctrl+O`, `Enter`, y sal con `Ctrl+X`).*

**Paso 3: Aplicar los cambios**
Reinicia el servicio para que lea la nueva configuración:
```bash
sudo systemctl restart proftpd
```

---

Cómo comprobar su comportamiento (El Ejemplo)

Una vez activado, si alguien desde otro equipo intenta conectarse a tu servidor, la interacción en su terminal se vería de esta manera:

```bash
┌──(kali㉿kali)-[~]
└─$ ftp 192.168.50.4
Connected to 192.168.50.4.
220 Servidor ProFTPD (Debian) [::ffff:192.168.50.4]
Name (192.168.50.4:kali): anonymous
331 Acceso anónimo concedido, envíe su identidad (e-mail) como contraseña.
Password:  <-- (Aquí el usuario puede escribir cualquier cosa, ej: invitado@correo.com)
230 Acceso anónimo concedido, aplican restricciones.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> 
```

**El detalle de la "Cárcel" Anónima:**
Por defecto, cuando ProFTPD activa el usuario anónimo, lo encierra automáticamente usando la lógica de `DefaultRoot`. El usuario anónimo solo podrá ver lo que haya dentro de la carpeta `/srv/ftp/` (que es la carpeta pública por defecto en Debian/Kali) y no podrá navegar por el resto de tu disco duro.

#### SFTP (SSH File Transfer Protocol): La Alternativa Segura Definitiva

**¿Qué es?**
A pesar de su nombre, **SFTP no tiene absolutamente nada que ver con el protocolo FTP tradicional** (ni siquiera es "FTP con seguridad", eso se llama FTPS). 

SFTP es en realidad un subsistema del protocolo SSH. Esto significa que utiliza la misma conexión cifrada y segura que usas para administrar el servidor por terminal. Todo viaja encriptado: el usuario, la contraseña y los propios archivos. Además, soluciona todos los problemas de cortafuegos y puertos raros que tiene el FTP clásico, ya que todo pasa por un único puerto: el **puerto 22** (el de SSH).

**¿Qué hace falta para poder usarlo?**
Esta es su mayor ventaja, es increíblemente fácil de desplegar:

1.  **En el Servidor:** No necesitas instalar ProFTPD, `vsftpd` ni configurar nada raro. Solo necesitas tener instalado y funcionando el servicio normal de **OpenSSH** (`sudo apt install openssh-server`). Si puedes entrar por SSH a la máquina, automáticamente puedes usar SFTP.
2.  **En el Cliente:** No hace falta instalar programas extra. Las herramientas de Linux como Kali ya traen el comando `sftp` integrado.


Ejemplo de Ejecución en Terminal

La sintaxis para conectarse es exactamente la misma que usarías para SSH (`sftp usuario@IP`), pero una vez dentro, los comandos que debes usar son los mismos que aprendiste en FTP (`ls`, `pwd`, `get`, `put`, `!ls`, etc.). 

```bash
┌──(kali㉿kali)-[~]
└─$ sftp usuario@192.168.50.4
usuario@192.168.50.4's password:  <-- (Aquí pones la contraseña habitual, ej: abc123.)
Connected to 192.168.50.4.

sftp> pwd
Remote working directory: /home/usuario

sftp> ls
Descargas    Documentos    Escritorio    informe_secreto.pdf

sftp> lcd /home/kali/Desktop
lcd: /home/kali/Desktop

sftp> get informe_secreto.pdf
Fetching /home/usuario/informe_secreto.pdf to informe_secreto.pdf
/home/usuario/informe_secreto.pdf          100%   20MB  45.0MB/s   00:00

sftp> exit
┌──(kali㉿kali)-[~]
└─$ 
```
