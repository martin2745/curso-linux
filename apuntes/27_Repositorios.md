# Repositorios

Tenemos dos comando principales para la gestión de repositorios en linux.

## apt:

- `get`: Obtiene los paquetes de los repositorios pero no los instala. Actualmente ya no es necesario.
- `install`: Instala uno o varios paquetes.
- `remove`: Elimina uno o varios paquetes.
- `purge`: Elimina uno o varios paquetes y también sus archivos de configuración.
- `update`: Actualiza la lista de paquetes disponibles en los repositorios.
- `upgrade`: Actualiza todos los paquetes instalados a las versiones más recientes disponibles.
- `dist-upgrade`: Realiza una actualización más completa que `apt upgrade`, incluyendo la resolución de dependencias y la eliminación o instalación de nuevos paquetes si es necesario para completar la actualización de forma coherente.
- `list --installed`: En linux, ejecutar `apt list --installed` permite mostrar todos los paquetes deb instalados en el sistema.

Podemos ver los repositorios donde `apt` hace sus busquedas a continuación:

```bash
si@si-VirtualBox:~$ cat /etc/apt/sources.list | sed -e '/^#/d' -e '/^$/d'
deb http://es.archive.ubuntu.com/ubuntu/ jammy main restricted
deb http://es.archive.ubuntu.com/ubuntu/ jammy-updates main restricted
deb http://es.archive.ubuntu.com/ubuntu/ jammy universe
deb http://es.archive.ubuntu.com/ubuntu/ jammy-updates universe
deb http://es.archive.ubuntu.com/ubuntu/ jammy multiverse
deb http://es.archive.ubuntu.com/ubuntu/ jammy-updates multiverse
deb http://es.archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu jammy-security main restricted
deb http://security.ubuntu.com/ubuntu jammy-security universe
deb http://security.ubuntu.com/ubuntu jammy-security multiverse
```

## dpkg:

- `-i`: Instala un paquete.
- `-r`: Elimina un paquete pero conserva sus archivos de configuración.
- `-P`: Elimina un paquete y también sus archivos de configuración.
- `-l`: Lista todos los paquetes instalados en el sistema.
- `-L`: Lista todos los ficheros instalados que pertenecen a un paquete específico.
- `--get-selectios`: En linux, ejecutar `dpkg --get-selections` permite mostrar todos los paquetes deb instalados en el sistema.

```bash
root@debian12:~/Descargas# ls
debian-refcard_12.0_all.deb

root@debian12:~/Descargas# dpkg -i debian-refcard_12.0_all.deb
Seleccionando el paquete debian-refcard previamente no seleccionado.
(Leyendo la base de datos ... 260028 ficheros o directorios instalados actualmente.)
Preparando para desempaquetar debian-refcard_12.0_all.deb ...
Desempaquetando debian-refcard (12.0) ...
Configurando debian-refcard (12.0) ...

root@debian12:~/Descargas# dpkg -l debian-refcard
Deseado=desconocido(U)/Instalar/eliminaR/Purgar/retener(H)
| Estado=No/Inst/ficheros-Conf/desempaqUetado/medio-conF/medio-inst(H)/espera-disparo(W)/pendienTe-disparo
|/ Err?=(ninguno)/requiere-Reinst (Estado,Err: mayúsc.=malo)
||/ Nombre         Versión      Arquitectura Descripción
+++-==============-============-============-==============================================
ii  debian-refcard 12.0         all          printable reference card for the Debian system

root@debian12:~/Descargas# dpkg -L debian-refcard
/.
/usr
/usr/share
/usr/share/doc
/usr/share/doc/debian-refcard
/usr/share/doc/debian-refcard/changelog.gz
/usr/share/doc/debian-refcard/copyright
/usr/share/doc/debian-refcard/index.html
/usr/share/doc/debian-refcard/openlogo-nd-25.png
/usr/share/doc/debian-refcard/refcard-bg-a4.pdf.gz
/usr/share/doc/debian-refcard/refcard-ca-a4.pdf.gz

root@debian12:~/Descargas# dpkg -P debian-refcard
(Leyendo la base de datos ... 260072 ficheros o directorios instalados actualmente.)
Desinstalando debian-refcard (12.0) ...

root@debian12:~/Descargas# dpkg -l debian-refcard
dpkg-query: no se ha encontrado ningún paquete que corresponda con debian-refcard.
```
