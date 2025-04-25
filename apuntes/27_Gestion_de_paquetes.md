# Repositorios

A la hora de instalar software en un sistema linux, tenemos dos maneras de hacerlo: compilando el código fuente o instalando un paquete precompilado. 
Cada distribución de linux utiliza diferentes formatos de paquetes, siendo dos los más extendidos.
- .deb: familia Debian (Ubuntu, Kali, Linux Mint...). Para ello usaremos la herramienta *dpkg*.
- .rpm: familia Red Hat (CentOS, Fedora, SUSE...).
Tenemos un conjunto de comandos principales para la gestión de paquetes en linux. Para ello usaremos la herramienta *yum*.

## .deb
### dpkg

Gestiona paquetes .deb sin gestión de dependencias.

- `-i`: Instala un paquete.
- `-G`: Actualiza el paquete si hay una versión más actual a la instalada.
- `-r`: Elimina un paquete pero conserva sus archivos de configuración.
- `-P | --purge`: Elimina un paquete y también sus archivos de configuración.
- `-l | --list`: Lista todos los paquetes instalados en el sistema.
- `-L`: Lista todos los ficheros instalados que pertenecen a un paquete específico.
- `--get-selectios`: En linux, ejecutar `dpkg --get-selections` permite mostrar todos los paquetes .deb instalados en el sistema.
- `-s`: Muestra información sobre un paquete.
  
_*Nota*_: Existe una diferencia fundamental entre eliminar y purgar. Cuando instalamos un paquete es normal que existan configuraciones personales que se almacenan en el `/home` de cada usuario, una eliminación del paquete hace que estas configuraciones permanezcan, lo que hace que si posteriormente se instala de nuevo el paquete estas permanecen en el sistema. Por otro lado, purgar el paquete implica eliminar todos esos archivos de creación personal. 

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

_*Nota*_: Cuando ejecutamos *dpkg -l* puede darnos que el paquete esté instalado como *ii* o eliminado como *rc*.
_*Nota*_: Si queremos volver a realizar la configuración de un paquete cuando se instaló (preguntas que contesta el usuario durante la instalación), tenemos el comando dpkg-reconfigure.

### apt

Facilita la instalación de paquetes .deb, descargándolos de los repositorios y gestionando las dependencias de estos, usamos la herramienta *Advanced Package Tool: apt-get*. Es importante tener en cuenta que al ser un repositorio online, si cada vez que tuvieramos que realizar una descarga tuvieramos que comprobar en que repositorio se encuentra el paquete el proceso podría demorarse mucho, por este motivo se guarda en el sistema en la ruta `/etc/apt/surces.list` con los respositorios en los cuales se encuentran los paquetes y en una caché local los paquetes que se encuentran en cada repostiorio así como la versión de los mismos. Es buena práctica actualizar la información de esta caché antes de realizar la descarga de un paquete.

- `get`: Obtiene los paquetes de los repositorios pero no los instala. Actualmente ya no es necesario.
- `search`: Accede a los repositorios para poder buscar el paquete deseado.
- `install`: Instala uno o varios paquetes.
- `remove`: Elimina uno o varios paquetes.
- `purge`: Elimina uno o varios paquetes y también sus archivos de configuración.
- `update`: Actualiza la lista de paquetes disponibles en los repositorios.
- `upgrade`: Actualiza todos los paquetes instalados a las versiones más recientes disponibles de los repositorios y si no están actualizados nos dirá que es necesario instalar.
- `download`: Descarga el paquete .deb sin instalarlo.
- `dist-upgrade`: Realiza una actualización más completa que `apt upgrade`, incluyendo la resolución de dependencias y la eliminación o instalación de nuevos paquetes si es necesario para completar la actualización de forma coherente de los paquetes ya existentes. 
- `list --installed`: En linux, ejecutar `apt list --installed` permite mostrar todos los paquetes deb instalados en el sistema.
- `autoremove`: Elimina paquetes huérfanos, es decir, no requeridos por ningún otro paquete.

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

## .rpm

### rpm

Gestiona paquetes .rpm sin resolver automáticamente las dependencias.

- `-i`: Instala un paquete.
- `-U`: Actualiza un paquete o lo instala si no está presente.
- `-F`: Actualiza solo si el paquete ya está instalado.
- `-e`: Elimina un paquete.
- `-q`: Consulta información sobre paquetes instalados.
- `-qa`: Lista todos los paquetes instalados en el sistema.
- `-ql`: Lista todos los archivos instalados que pertenecen a un paquete específico.
- `-qf `: Muestra a qué paquete pertenece un archivo.
- `-V`: Verifica la integridad de los archivos instalados por un paquete.
- `--rebuilddb`: Reconstruye la base de datos de rpm si hay problemas de corrupción.

_*Nota*_: El comando `rpm` no resuelve automáticamente las dependencias. Si intentas instalar un paquete y faltan dependencias, deberás instalarlas manualmente o usar una herramienta como `yum` o `dnf`.

```bash
[root@centos8 ~]# ls
nano-2.9.8-1.el8.x86_64.rpm

[root@centos8 ~]# rpm -i nano-2.9.8-1.el8.x86_64.rpm
# Instala el paquete nano

[root@centos8 ~]# rpm -q nano
nano-2.9.8-1.el8.x86_64

[root@centos8 ~]# rpm -ql nano
/usr/bin/nano
/usr/share/doc/nano
/usr/share/man/man1/nano.1.gz

[root@centos8 ~]# rpm -e nano
# Elimina el paquete nano

[root@centos8 ~]# rpm -qa | grep nano
# Comprueba si nano sigue instalado
```

_*Nota*_: Para ver a qué paquete pertenece un archivo, puedes usar `rpm -qf /ruta/al/archivo`.

### yum

Facilita la instalación de paquetes .rpm, resolviendo automáticamente las dependencias y gestionando los repositorios. Es el gestor estándar en distribuciones como CentOS, RHEL y Fedora (en versiones recientes, reemplazado por `dnf`).

- `install`: Instala uno o varios paquetes.
- `check-update`: Comprueba si hay actualizaciones disponibles para los repositorios. Es el equivalente a *apt update*.
- `update`: Actualiza todos los paquetes instalados o uno específico. Es el equivalente a *apt upgrade*.
- `search`: Busca paquetes por nombre o descripción.
- `list`: Lista paquetes disponibles, instalados o actualizables.
- `info`: Muestra información detallada de un paquete.
- `remove`: Elimina uno o varios paquetes.
- `autoremove`: Elimina paquetes huérfanos (no requeridos por otros).
- `repolist`: Lista los repositorios configurados y su estado.
- `downloadonly`: Descarga únicamente el paquete sin instalarlo.
- `downloaddir`: Indica el lugar donde se descarga. 
- `grouplist`: Nos da el conjunto de metapaquetes que contienen otros paquetes y están agrupados en base a una utilidad concreta, como la gestión de redes, servidores web...

_*Nota*_: Los repositorios de yum se configuran en archivos con extensión `.repo` dentro de `/etc/yum.repos.d/`.

```bash
[root@centos8 ~]# yum install nano
# Instala el paquete nano y todas sus dependencias

[root@centos8 ~]# yum list installed nano
# Muestra si nano está instalado

[root@centos8 ~]# yum remove nano
# Elimina el paquete nano

[root@centos8 ~]# yum search editor
# Busca paquetes relacionados con "editor"

[root@centos8 ~]# yum update
# Actualiza todos los paquetes instalados

[root@centos8 ~]# yum clean all
# Limpia la caché de yum
```

_*Nota*_: `yum` resuelve automáticamente las dependencias y descarga los paquetes desde los repositorios configurados, facilitando la gestión de software en sistemas basados en RPM.
_*Nota*_: A parte de `yum` existe el comando `dnf`. *YUM (Yellowdog Updater, Modified)* es un gestor de paquetes para sistemas Linux basados en RPM, como Red Hat, CentOS y Fedora. Permite instalar, actualizar y eliminar paquetes y sus dependencias automáticamente desde repositorios de software *DNF (Dandified YUM)* es el sucesor moderno de YUM, diseñado para ser más rápido, eficiente y con mejor resolución de dependencias. Es el gestor de paquetes predeterminado en las versiones recientes de Fedora y otras distribuciones RPM, manteniendo comandos similares a YUM pero con mejoras en rendimiento y manejo de transacciones. A mayores encontramos herramientas como *zypper* desarrolladas por openSUSE.