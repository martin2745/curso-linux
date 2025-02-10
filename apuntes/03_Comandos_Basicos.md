# Comandos básicos

A continuación vamos a ver un conjunto de los principales comandos de linux con su explicación.

## Comandos principales básicos

```bash
┌──(kali㉿kali)-[~]
└─$ whoami
kali
```
**Explicación:** El comando `whoami` muestra el nombre del usuario actual, que en este caso es `kali`.

---

```bash
┌──(kali㉿kali)-[~]
└─$ id
uid=1000(kali) gid=1000(kali) groups=1000(kali),4(adm),20(dialout),24(cdrom),25(floppy),27(sudo),29(audio),30(dip),44(video),46(plugdev),100(users),101(netdev),118(bluetooth),120(vboxsf),124(wireshark),126(lpadmin),134(scanner),139(kaboxer)
```
**Explicación:** El comando `id` muestra la información del usuario actual. En este caso, el UID y GID del usuario `kali` son 1000, y muestra los grupos a los que pertenece.

---

```bash
┌──(kali㉿kali)-[~]
└─$ groups
kali adm dialout cdrom floppy sudo audio dip video plugdev users netdev bluetooth vboxsf wireshark lpadmin scanner kaboxer
```
**Explicación:** El comando `groups` muestra todos los grupos a los que pertenece el usuario `kali`.

---

```bash
┌──(kali㉿kali)-[~]
└─$ sudo su
[sudo] password for kali: 
```
**Explicación:** El comando `sudo su` permite al usuario cambiar a la cuenta de `root` (superusuario) después de ingresar la contraseña.

---

```bash
┌──(root㉿kali)-[/home/kali]
└─# whoami
root
```
**Explicación:** Después de ejecutar `sudo su`, el comando `whoami` ahora muestra que el usuario actual es `root`.

---

```bash
┌──(root㉿kali)-[/home/kali]
└─# exit
```
**Explicación:** El comando `exit` termina la sesión de superusuario y vuelve al usuario anterior (`kali`).

---

```bash
┌──(kali㉿kali)-[~]
└─$ sudo id
uid=0(root) gid=0(root) groups=0(root)
```
**Explicación:** El comando `sudo id` muestra la información de usuario del `root`. El UID y GID son ambos 0, indicando que se trata del superusuario.

---

```bash
┌──(kali㉿kali)-[~]
└─$ which whoami
/usr/bin/whoami
```
**Explicación:** El comando `which whoami` muestra la ubicación del comando `whoami` en el sistema. En este caso, se encuentra en `/usr/bin/whoami`.

---

```bash
┌──(kali㉿kali)-[~]
└─$ which cat
/usr/bin/cat
```
**Explicación:** El comando `which cat` muestra la ubicación del comando `cat`, que está en `/usr/bin/cat`.

---

```bash
┌──(kali㉿kali)-[~]
└─$ id
uid=1000(kali) gid=1000(kali) groups=1000(kali),4(adm),20(dialout),24(cdrom),25(floppy),27(sudo),29(audio),30(dip),44(video),46(plugdev),100(users),101(netdev),118(bluetooth),120(vboxsf),124(wireshark),126(lpadmin),134(scanner),139(kaboxer)
```
**Explicación:** El comando `id` muestra de nuevo la información del usuario `kali`, confirmando el UID 1000 y los grupos a los que pertenece.

---

```bash
┌──(kali㉿kali)-[~]
└─$ /usr/bin/cat /etc/group | grep 27
sudo:x:27:kali
inetsim:x:127:
```
**Explicación:** Este comando muestra el contenido del archivo `/etc/group` filtrado por el número 27. Se encuentra que el grupo `sudo` tiene el identificador 27, y el usuario `kali` pertenece a ese grupo.

---

```bash
┌──(kali㉿kali)-[~]
└─$ /usr/bin/whoami
kali
```
**Explicación:** Este comando ejecuta `whoami` desde su ubicación completa y muestra que el usuario actual es `kali`.

---

```bash
┌──(kali㉿kali)-[~]
└─$ which whoami
/usr/bin/whoami
```
**Explicación:** De nuevo, este comando muestra la ubicación completa del comando `whoami`, que es `/usr/bin/whoami`.

---

```bash
┌──(kali㉿kali)-[~]
└─$ echo $PATH
/home/kali/.local/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/home/kali/.dotnet/tools
```
**Explicación:** El comando `echo $PATH` muestra la variable de entorno `PATH`, que contiene los directorios en los que el sistema busca los ejecutables de los comandos. Aquí, se muestra una lista de directorios como `/home/kali/.local/bin`, `/usr/bin`, etc.

---

```bash
┌──(kali㉿kali)-[~]
└─$ pwd
/home/kali
```
**Explicación:** El comando `pwd` (print working directory) muestra el directorio de trabajo actual. En este caso, está en el directorio `/home/kali`.

---

```bash
┌──(kali㉿kali)-[~]
└─$ ls
Desktop  Documents  Downloads  Music  Pictures  Public  Templates  Videos
```
**Explicación:** El comando `ls` lista los archivos y directorios en el directorio actual. En este caso, muestra las carpetas del usuario `kali`: `Desktop`, `Documents`, `Downloads`, `Music`, `Pictures`, `Public`, `Templates`, y `Videos`.

---

```bash
┌──(kali㉿kali)-[~]
└─$ ls -l
total 32
drwxr-xr-x 2 kali kali 4096 Feb 10 11:54 Desktop
drwxr-xr-x 2 kali kali 4096 Feb 10 11:52 Documents
drwxr-xr-x 2 kali kali 4096 Feb 10 11:52 Downloads
drwxr-xr-x 2 kali kali 4096 Feb 10 11:52 Music
drwxr-xr-x 2 kali kali 4096 Feb 10 11:52 Pictures
drwxr-xr-x 2 kali kali 4096 Feb 10 11:52 Public
drwxr-xr-x 2 kali kali 4096 Feb 10 11:52 Templates
drwxr-xr-x 2 kali kali 4096 Feb 10 11:52 Videos
```
**Explicación:** El comando `ls -l` muestra una lista detallada de los archivos y directorios en el directorio actual, incluyendo permisos, número de enlaces, propietario, grupo, tamaño y fecha de última modificación.

---

```bash
┌──(kali㉿kali)-[~]
└─$ cd /
```
**Explicación:** El comando `cd /` cambia al directorio raíz `/`, que es el directorio más alto del sistema de archivos.

---

```bash
┌──(kali㉿kali)-[/]
└─$ ls -l
total 64
lrwxrwxrwx   1 root root     7 Feb 10 11:41 bin -> usr/bin
drwxr-xr-x   3 root root  4096 Feb 10 11:51 boot
drwxr-xr-x  18 root root  3300 Feb 10 12:18 dev
drwxr-xr-x 187 root root 12288 Feb 10 12:18 etc
drwxr-xr-x   3 root root  4096 Feb 10 11:48 home
lrwxrwxrwx   1 root root    28 Feb 10 11:41 initrd.img -> boot/initrd.img-6.11.2-amd64
lrwxrwxrwx   1 root root     7 Feb 10 11:41 lib -> usr/lib
lrwxrwxrwx   1 root root     9 Feb 10 11:41 lib32 -> usr/lib32
lrwxrwxrwx   1 root root     9 Feb 10 11:41 lib64 -> usr/lib64
drwx------   2 root root 16384 Feb 10 11:41 lost+found
drwxr-xr-x   3 root root  4096 Nov 30 09:39 media
drwxr-xr-x   2 root root  4096 Nov 30 09:39 mnt
drwxr-xr-x   3 root root  4096 Feb 10 11:41 opt
dr-xr-xr-x 218 root root     0 Feb 10 12:17 proc
drwx------   4 root root  4096 Feb 10 12:22 root
drwxr-xr-x  38 root root   960 Feb 10 12:18 run
lrwxrwxrwx   1 root root     8 Feb 10 11:41 sbin -> usr/sbin
drwxr-xr-x   3 root root  4096 Feb 10 11:41 srv
dr-xr-xr-x  13 root root     0 Feb 10 12:17 sys
drwxrwxrwt  14 root root   340 Feb 10 12:24 tmp
drwxr-xr-x  15 root root  4096 Feb 10 11:47 usr
drwxr-xr-x  12 root root  4096 Feb 10 11:51 var
lrwxrwxrwx   1 root root    25 Feb 10 11:47 vmlinuz -> boot/vmlinuz-6.11.2-amd64
```
**Explicación:** El comando `ls -l` en el directorio raíz `/` muestra una lista detallada de los directorios y archivos que lo componen, como `bin`, `boot`, `etc`, `home`, entre otros.

---

```bash
┌──(kali㉿kali)-[/]
└─$ cd
```
**Explicación:** El comando `cd` sin argumentos cambia al directorio home del usuario actual, que es `/home/kali`.

---

```bash
┌──(kali㉿kali)-[~]
└─$ pwd
/home/kali
```
**Explicación:** El comando `pwd` muestra que el directorio de trabajo actual es `/home/kali`.

---

```bash
┌──(kali㉿kali)-[~]
└─$ cd /
```
**Explicación:** El comando `cd /` cambia al directorio raíz `/` nuevamente.

---

```bash
┌──(kali㉿kali)-[/]
└─$ cd ~
```
**Explicación:** El comando `cd ~` lleva al directorio home del usuario actual, que es `/home/kali`.

---

```bash
┌──(kali㉿kali)-[~]
└─$ pwd
/home/kali
```
**Explicación:** El comando `pwd` confirma que el directorio de trabajo actual es `/home/kali`.

---

```bash
┌──(kali㉿kali)-[~]
└─$ cd
```
**Explicación:** El comando `cd` sin argumentos nuevamente lleva al directorio home del usuario actual, que es `/home/kali`.

---

```bash
┌──(kali㉿kali)-[~]
└─$ cd /
```
**Explicación:** El comando `cd /` cambia al directorio raíz `/` una vez más.

---

```bash
┌──(kali㉿kali)-[/]
└─$ cd /home/kali
```
**Explicación:** El comando `cd /home/kali` cambia al directorio `/home/kali`, el directorio home del usuario `kali`.

---

```bash
┌──(kali㉿kali)-[~]
└─$ echo $PATH
/home/kali/.local/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/home/kali/.dotnet/tools
```
**Explicación:** El comando `echo $PATH` muestra la variable de entorno `PATH`, que contiene los directorios donde el sistema busca los ejecutables de los comandos. Aquí, la variable incluye directorios como `/home/kali/.local/bin`, `/usr/bin`, y otros.

---

