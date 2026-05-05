# Gestión de paquetes y repositorios

## Índice

1. [Concepto de Paquete y Repositorio](#1-concepto-de-paquete-y-repositorio)
2. [Sistemas basados en Debian (.deb)](#2-sistemas-basados-en-debian-deb)
   1. [Herramienta dpkg](#herramienta-dpkg)
   2. [Herramienta apt](#herramienta-apt)
   3. [Búsqueda e instalación de paquetes con apt](#búsqueda-e-instalación-de-paquetes-con-apt)
   4. [Actualización de la distribución](#actualización-de-la-distribución)
   5. [Diferencias entre clean, remove, purge y autoremove](#diferencias-entre-clean-remove-purge-y-autoremove)
3. [Sistemas basados en Red Hat (.rpm)](#3-sistemas-basados-en-red-hat-rpm)
   1. [Herramienta rpm](#herramienta-rpm)
   2. [Herramienta yum / dnf](#herramienta-yum--dnf)

---

## 1. Concepto de Paquete y Repositorio

A diferencia de Windows, en los sistemas Linux y Unix no es común contar con programas que incluyan un instalador interactivo (como el típico `install.exe`). En ocasiones, algunos desarrolladores ofrecen scripts de instalación que, en la mayoría de los casos, simplemente descomprimen los archivos y los colocan en los directorios correspondientes.

En Linux es mucho más habitual distribuir aplicaciones, herramientas y actualizaciones en forma de **paquetes** (_packages_). Un paquete es un archivo, a veces de gran tamaño, que contiene el software a instalar junto con una serie de instrucciones o reglas que definen su gestión. Estas reglas pueden incluir:

- **Gestión de dependencias:** el software solo podrá instalarse si los programas que necesita ya están presentes en el sistema.
- **Acciones de preinstalación:** tareas previas necesarias antes de la instalación, como modificar permisos o crear directorios.
- **Acciones de postinstalación:** configuraciones que se ejecutan después de la instalación, como ajustar parámetros de archivos o realizar compilaciones adicionales.

Cada distribución de Linux utiliza diferentes formatos de paquetes, siendo dos los más extendidos:

- **`.deb`**: familia Debian (Ubuntu, Kali, Linux Mint...). Usamos herramientas como `dpkg` y `apt`.
- **`.rpm`**: familia Red Hat (CentOS, Fedora, SUSE...). Usamos herramientas como `rpm`, `yum` y `dnf`.

---

## 2. Sistemas basados en Debian (.deb)

### Herramienta dpkg

Gestiona paquetes **`.deb`** a bajo nivel, es decir, **sin gestión automática de dependencias**. La base de datos de `dpkg` donde figura todo lo instalado está en `/var/lib/dpkg`.

| Opción | Descripción |
|--------|-------------|
| `-i paquete.deb` | Instala el paquete. |
| `-R directorio/` | Instala todos los paquetes que se encuentren en un directorio. |
| `-l` | Muestra la lista de paquetes instalados en el sistema. |
| `-c paquete.deb` | Lista los archivos contenidos dentro del archivo `.deb` antes de instalar. |
| `-L paquete` | Muestra los archivos físicos proporcionados por un paquete ya instalado. |
| `-S ruta/archivo` | Determina a qué paquete pertenece un archivo existente en el disco. |
| `-r paquete` | Elimina un paquete instalado, pero **deja** sus archivos de configuración. |
| `-P paquete` | Elimina (purga) un paquete instalado, **incluyendo** sus archivos de configuración. |
| `--get-selections` | Busca paquetes instalados, desinstalados y purgados en el SO. |
| `--configure --pending` | Reconfigura paquetes que no terminaron su configuración. |
| `--info paquete.deb` | Muestra metadatos y dependencias del archivo `.deb`. |
| `--unpack paquete.deb` | Desempaqueta un archivo `.deb` sin llegar a configurarlo. |

> **Nota:** Existe una diferencia fundamental entre eliminar y purgar. Eliminar el paquete hace que las configuraciones previas permanezcan, facilitando futuras reinstalaciones. Purgar el paquete (`-P`) implica eliminar todos esos archivos de configuración de sistema (salvo las configuraciones de usuario que estén dentro de `/home`).

```bash
root@debian:~/Descargas# dpkg -i debian-refcard_12.0_all.deb
Seleccionando el paquete debian-refcard previamente no seleccionado.
(Leyendo la base de datos ... 260028 ficheros o directorios instalados actualmente.)
Preparando para desempaquetar debian-refcard_12.0_all.deb ...
Desempaquetando debian-refcard (12.0) ...
Configurando debian-refcard (12.0) ...
```

> **Recuerda:** Cuando ejecutamos `dpkg -l`, un paquete instalado correctamente aparecerá marcado como `ii`, mientras que uno eliminado (pero no purgado) aparecerá como `rc`. Para volver a configurar un paquete interactivo, usa el comando `dpkg-reconfigure nombre_paquete`.

---

### Herramienta apt

Facilita la instalación de paquetes **`.deb`**, descargándolos de los repositorios y **gestionando automáticamente sus dependencias**. Los repositorios que utiliza `apt` se definen en `/etc/apt/sources.list` y dentro del directorio `/etc/apt/sources.list.d/`.

| Comando `apt` | Funcionalidad |
|---------------|---------------|
| `search` | Busca un paquete por nombre o descripción en la base de datos local. |
| `install` | Instala uno o varios paquetes resolviendo dependencias. |
| `remove` | Elimina paquetes dejando sus configuraciones. |
| `purge` | Elimina paquetes y también sus archivos de configuración globales. |
| `autoremove` | Elimina paquetes huérfanos que se instalaron como dependencias y ya no se necesitan. |
| `update` | Actualiza la lista local de metadatos de los repositorios. **No instala nada**. |
| `upgrade` | Actualiza todos los paquetes instalados a sus versiones más recientes. |
| `dist-upgrade` / `full-upgrade` | Actualización profunda que puede eliminar paquetes obsoletos o instalar nuevos para resolver conflictos de dependencias entre versiones (usado al cambiar de versión de SO). |
| `list --installed` | Muestra una lista de todos los paquetes instalados por APT. |
| `clean` | Elimina **todos** los instaladores `.deb` de la caché (`/var/cache/apt/archives/`). |
| `autoclean` | Elimina **solo** los `.deb` antiguos u obsoletos de la caché. |

---

### Búsqueda e instalación de paquetes con apt

El comando `apt search` (o el tradicional `apt-cache search`) permite localizar paquetes:

```bash
root@debian:~# apt search neovim
Ordenando... Hecho
Buscar en todo el texto... Hecho
neovim/oldstable 0.7.2-7 amd64
  heavily refactored vim fork
...
```

Interpretando la salida:
- **`neovim`**: nombre del paquete.
- **`oldstable`**: rama del repositorio.
- **`0.7.2-7`**: versión.
- **`amd64`**: arquitectura.
- **`heavily refactored vim fork`**: descripción breve.

Instalación y validación:

```bash
root@debian:~# apt install neovim -y
root@debian:~# apt list --installed | grep neovim
neovim-runtime/oldstable,now 0.7.2-7 all [instalado, automático]
neovim/oldstable,now 0.7.2-7 amd64 [instalado]
```

> **Importante:** Una dependencia es una librería o programa adicional necesario para el funcionamiento del paquete principal. Cuando elimines software con `apt remove paquete` o `apt purge paquete`, siempre es buena práctica ejecutar seguidamente `apt autoremove` para limpiar las dependencias que han quedado huérfanas en el sistema.

---

### Actualización de la distribución

Para realizar saltos de versión (por ejemplo, de Debian 12 "Bookworm" a Debian 13 "Trixie"), el proceso es el siguiente:

```bash
root@debian:~# sed -i 's/bookworm/trixie/g' /etc/apt/sources.list
root@debian:~# sed -i 's/bookworm/trixie/g' /etc/apt/sources.list.d/*.list
root@debian:~# apt update
root@debian:~# apt upgrade -y
root@debian:~# apt dist-upgrade -y
root@debian:~# reboot
```

---

### Diferencias entre clean, remove, purge y autoremove

Cuando se instalan paquetes, `apt` descarga temporalmente los instaladores en `/var/cache/apt/archives/`. Para no saturar el disco, debemos saber diferenciarlos:

| Comando | Qué elimina | Configuración eliminada | `.deb` de caché eliminados |
|---------|-------------|-------------------------|----------------------------|
| `apt clean` | Archivos `.deb` descargados en caché | No | Sí (Todos) |
| `apt remove` | Paquete instalado | No | No |
| `apt purge` | Paquete instalado | Sí | No |
| `apt autoremove` | Dependencias no necesarias (huérfanas) | No | No |
| `apt autoclean` | Archivos `.deb` obsoletos en caché | No | Sí (Solo obsoletos) |

---

## 3. Sistemas basados en Red Hat (.rpm)

### Herramienta rpm

Gestiona paquetes `.rpm` a bajo nivel sin resolver automáticamente dependencias. La base de datos de los paquetes instalados reside en `/var/lib/rpm`. 

| Comando | Descripción |
|---------|-------------|
| `-i paquete.rpm` | Instala un paquete. |
| `-e paquete` | Elimina un paquete. |
| `-U paquete.rpm` | Actualiza un paquete, o lo instala si no está presente. |
| `-qa` | Consulta la lista de todos los paquetes instalados. |
| `-qi paquete` | Muestra información detallada sobre un paquete. |
| `-ql paquete` | Lista los archivos que instala un paquete y dónde los coloca. |
| `-qf /ruta/archivo` | Consulta a qué paquete pertenece un archivo del sistema. |
| `--rebuilddb` | Regenera la base de datos de RPM si se corrompe. |

```bash
[root@centos8 ~]# rpm -i nano-2.9.8-1.el8.x86_64.rpm
[root@centos8 ~]# rpm -ql nano
/usr/bin/nano
/usr/share/man/man1/nano.1.gz
```

> **Advertencia:** Al usar `rpm` directamente, si faltan dependencias la instalación fallará emitiendo un error. Para evitar esto, se recomienda usar siempre `yum` o `dnf`.

---

### Herramienta yum / dnf

Es el equivalente a `apt` en distribuciones Red Hat (CentOS, Fedora, Rocky, AlmaLinux). Resuelve dependencias automáticamente. Modernamente, `dnf` reemplaza a `yum`, manteniendo la misma sintaxis de comandos.

| Comando `yum` | Funcionalidad |
|---------------|---------------|
| `install` | Instala paquetes y resuelve dependencias. |
| `update` | Actualiza todos los paquetes instalados. |
| `check-update` | Comprueba si existen actualizaciones (equivalente a `apt update`). |
| `remove` | Elimina paquetes. |
| `search` | Busca paquetes en los repositorios (`.repo` en `/etc/yum.repos.d/`). |
| `info` | Muestra información detallada de un paquete. |
| `repolist` | Lista los repositorios configurados y su estado habilitado/deshabilitado. |
| `grouplist` | Muestra agrupaciones de paquetes diseñados para roles específicos (ej. "Web Server"). |

```bash
[root@centos8 ~]# yum install nano
[root@centos8 ~]# yum update
[root@centos8 ~]# yum clean all
```

> **Nota:** En distribuciones como openSUSE (familia RPM), la herramienta equivalente de resolución de dependencias se llama `zypper`.
