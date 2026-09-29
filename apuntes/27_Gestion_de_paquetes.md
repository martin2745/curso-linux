# Gestión de paquetes y repositorios

## Índice

1. [Concepto de paquete y repositorio](#1-concepto-de-paquete-y-repositorio)
2. [Sistemas basados en Debian (.deb)](#2-sistemas-basados-en-debian-deb)
   1. [Herramienta dpkg](#21-herramienta-dpkg)
   2. [Herramienta apt](#22-herramienta-apt)
   3. [Búsqueda e instalación de paquetes con apt](#23-búsqueda-e-instalación-de-paquetes-con-apt)
   4. [Diferencia entre update, upgrade y dist-upgrade](#24-diferencia-entre-update-upgrade-y-dist-upgrade)
   5. [Actualización de la distribución](#25-actualización-de-la-distribución)
   6. [Diferencias entre clean, remove, purge y autoremove](#26-diferencias-entre-clean-remove-purge-y-autoremove)
3. [Sistemas basados en Red Hat (.rpm)](#3-sistemas-basados-en-red-hat-rpm)
   1. [Herramienta rpm](#31-herramienta-rpm)
   2. [Herramienta yum / dnf](#32-herramienta-yum--dnf)
4. [Práctica: dos versiones de Apache en el mismo servidor](#4-práctica-dos-versiones-de-apache-en-el-mismo-servidor)
   1. [Esquema de la práctica](#41-esquema-de-la-práctica)
   2. [Instalación desde el repositorio](#42-instalación-desde-el-repositorio)
   3. [Preparación y descarga del código fuente](#43-preparación-y-descarga-del-código-fuente)
   4. [Compilación e instalación en /opt](#44-compilación-e-instalación-en-opt)
   5. [Configuración para que no choquen](#45-configuración-para-que-no-choquen)
   6. [Registro como servicio de systemd](#46-registro-como-servicio-de-systemd)
   7. [Comprobación: los dos Apache a la vez](#47-comprobación-los-dos-apache-a-la-vez)
   8. [Comparativa: apt frente a código fuente](#48-comparativa-apt-frente-a-código-fuente)

---

## 1. Concepto de paquete y repositorio

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

### 2.1 Herramienta dpkg

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
| `--get-selections` | Lista el estado de selección de los paquetes (instalados, eliminados, purgados). Sirve para exportar la lista y replicarla en otra máquina con `--set-selections`. |
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
>
> Las dos letras del estado responden a dos preguntas distintas: la primera indica lo que el administrador **desea** y la segunda lo que **hay**.
>
> | Código | Significado |
> |---|---|
> | `ii` | Se quiere instalado y está instalado correctamente. |
> | `rc` | Se pidió su eliminación y solo quedan sus ficheros de configuración. |
> | `iU` | Se quiere instalado pero está desempaquetado y sin configurar. |
> | `iF` | Se quiere instalado pero su configuración quedó a medias. |

> **Nota:** Dos comandos de diagnóstico que conviene conocer:
>
> - `dpkg --audit` enumera los paquetes que quedaron a medio instalar o sin configurar, algo típico tras un corte de corriente o un `apt` interrumpido. La reparación habitual es `dpkg --configure -a` o `apt --fix-broken install`.
> - `dpkg -V paquete` verifica la integridad de los ficheros instalados comparando sus sumas de comprobación con las registradas. Una salida vacía significa que todo está intacto.

> **Recuerda:** `dpkg -S` solo localiza ficheros de paquetes **ya instalados**. Para averiguar qué paquete habría que instalar para disponer de un fichero que aún no se tiene, la herramienta es `apt-file`:
>
> ```bash
> root@debian:~# apt install apt-file && apt-file update
> root@debian:~# apt-file search bin/htpasswd
> apache2-utils: /usr/bin/htpasswd
> ```

---

### 2.2 Herramienta apt

Facilita la instalación de paquetes **`.deb`**, descargándolos de los repositorios y **gestionando automáticamente sus dependencias**. Los repositorios que utiliza `apt` se definen en `/etc/apt/sources.list` y dentro del directorio `/etc/apt/sources.list.d/`.

#### El fichero de repositorios

Cada línea del formato clásico de `sources.list` sigue esta estructura:

```bash
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main
```

| Campo | Significado |
|---|---|
| `deb` / `deb-src` | Paquetes binarios ya compilados, o código fuente. Las líneas `deb-src` solo hacen falta si se va a recompilar software. |
| URI | Dirección del servidor espejo. `deb.debian.org` es el servicio oficial de redirección descrito en el documento 00. |
| Distribución | Nombre en clave de la versión (`trixie`, `bookworm`) o su alias de ciclo de vida (`stable`, `testing`, `unstable`). |
| Componentes | Secciones del archivo, según la licencia del software. |

Los componentes de Debian responden a criterios de licencia y no de calidad:

| Componente | Contenido |
|---|---|
| `main` | Software totalmente libre y que no depende de nada fuera de `main`. Es lo único que forma parte oficialmente de Debian. |
| `contrib` | Software libre, pero que necesita algún componente no libre para funcionar. |
| `non-free` | Software con restricciones de licencia, como el compresor `rar` mencionado en el documento 23. |
| `non-free-firmware` | Componente introducido en Debian 12 para separar el firmware privativo de dispositivos del resto de `non-free`. |

> **Advertencia:** Elegir el nombre en clave (`trixie`) o el alias (`stable`) no es indiferente. Con `stable`, la máquina saltará sola a la siguiente versión mayor de Debian en cuanto esta se publique, en medio de un `apt upgrade` rutinario y sin previo aviso. En un servidor conviene fijar siempre el nombre en clave y decidir la actualización de forma consciente.

> **Nota:** A partir de Debian 12, la distribución emplea por defecto el formato **deb822**, con ficheros `.sources` en lugar de `.list`. Una instalación nueva de Debian 13 trae su configuración en `/etc/apt/sources.list.d/debian.sources` con este aspecto:
>
> ```bash
> Types: deb
> URIs: http://deb.debian.org/debian
> Suites: trixie trixie-updates
> Components: main
> Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
> ```
>
> Ambos formatos conviven y `apt` los lee indistintamente, pero conviene saber cuál usa la máquina antes de editar nada. Se comprueba con `apt policy` o mirando el contenido de `/etc/apt/sources.list.d/`.

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
| `show` | Muestra la descripción completa, la versión, el tamaño y las dependencias de un paquete. |
| `policy` | Indica qué versión hay instalada, cuál es la candidata y de qué repositorio procede cada una. |
| `depends` / `rdepends` | Lista las dependencias de un paquete, o los paquetes que dependen de él. |
| `list --upgradable` | Muestra qué paquetes tienen actualización pendiente. |

> **Importante:** `apt` y `apt-get` no son intercambiables sin más. `apt` nació como interfaz **para uso interactivo**: agrupa las funciones más usadas de `apt-get` y `apt-cache`, muestra barras de progreso y colorea la salida. Precisamente por eso, sus mensajes y su comportamiento pueden cambiar entre versiones, y al ejecutarlo dentro de un script avisa:
>
> ```bash
> WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
> ```
>
> Dentro de un script hay que usar `apt-get` y `apt-cache`, cuya interfaz sí está garantizada.

> **Recuerda:** Existe una diferencia importante entre `apt upgrade` y `apt full-upgrade`. El primero nunca elimina paquetes ni instala otros nuevos: si una actualización exigiera cualquiera de las dos cosas, la deja retenida y avisa con `Los siguientes paquetes se han retenido`. El segundo sí está autorizado a añadir y quitar paquetes para resolver el conflicto. Por eso el primero es seguro para el mantenimiento diario y el segundo es el que se necesita al saltar de versión.

#### Fijar la versión de un paquete

Cuando interesa que un paquete concreto no se actualice, por ejemplo el núcleo de un servidor en producción o una versión de base de datos con la que una aplicación es compatible, se marca como retenido:

```bash
root@debian:~# apt-mark hold nginx
nginx puesto en retenido
root@debian:~# apt-mark showhold
nginx
root@debian:~# apt-mark unhold nginx
```

> **Nota:** `apt-mark` sirve además para corregir la clasificación de un paquete. `apt-mark manual paquete` lo marca como instalado expresamente por el administrador, de modo que `apt autoremove` no lo retire; `apt-mark auto paquete` hace lo contrario y permite que se elimine cuando deje de ser necesario.

---

### 2.3 Búsqueda e instalación de paquetes con apt

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

### 2.4 Diferencia entre update, upgrade y dist-upgrade

Estos tres comandos se confunden constantemente porque los tres suenan a "actualizar", pero hacen cosas muy distintas. La clave está en entender que `apt` maneja **dos cosas separadas**: por un lado la **lista** (el catálogo de qué versiones hay disponibles en los repositorios) y por otro los **programas** realmente instalados en el disco.

> **Analogía:** Piensa en el catálogo de una tienda.
>
> - `apt update` es **pedir el catálogo nuevo** para enterarte de qué productos y qué versiones hay ahora. No compras nada, solo te informas.
> - `apt upgrade` es **ir a comprar** las versiones nuevas de lo que ya tienes, sin deshacerte de nada de lo que ya posees.
> - `apt full-upgrade` (`dist-upgrade`) es una compra en la que, si hiciera falta para que todo encaje, **te deshaces de cosas viejas** o **compras algo nuevo**.

| Comando | Qué hace | ¿Instala software? | ¿Puede eliminar paquetes? |
|---|---|---|---|
| `apt update` | Refresca la **lista** de versiones disponibles (los metadatos de los repositorios). | No, solo actualiza información. | No |
| `apt upgrade` | Actualiza a su última versión los paquetes **ya instalados**. | Sí | **No**, nunca borra ni añade paquetes |
| `apt full-upgrade` / `dist-upgrade` | Igual que `upgrade`, pero además resuelve conflictos de dependencias entre versiones. | Sí | **Sí**, puede añadir y quitar paquetes si es necesario |

**`apt update` — refrescar la lista (no instala nada).** Descarga de cada repositorio la relación actualizada de qué paquetes existen y en qué versión. Es pura información: después de un `update`, ni un solo programa del sistema ha cambiado. Sin este paso, `apt` trabajaría con un catálogo viejo y no se enteraría de las actualizaciones publicadas; por eso **siempre se ejecuta primero**.

**`apt upgrade` — actualizar lo instalado (sin quitar nada).** Con la lista ya al día, instala las versiones nuevas de los paquetes que ya tienes. Su regla de oro es que **nunca elimina un paquete ni instala uno que no tuvieras**. Si una actualización obligara a hacer cualquiera de esas dos cosas, la deja pendiente y avisa con el mensaje `Los siguientes paquetes se han retenido`. Es la operación segura del mantenimiento diario.

**`apt full-upgrade` / `dist-upgrade` — actualización profunda.** Hace lo mismo que `upgrade`, pero se le permite justo lo que a `upgrade` no: **eliminar paquetes obsoletos e instalar paquetes nuevos** cuando es la única forma de resolver los cambios de dependencias entre versiones. Es la que se necesita al **saltar de una versión de Debian a otra** y, por su capacidad de borrar, exige más cuidado.

> **Importante:** El flujo normal de mantenimiento combina siempre los dos primeros, en este orden:
>
> ```bash
> root@debian:~# apt update && apt upgrade
> ```
>
> Primero refrescar la lista, luego aplicar las actualizaciones. La `&&` encadena ambos: `upgrade` solo se ejecuta si `update` terminó bien. La actualización profunda (`full-upgrade`/`dist-upgrade`) se reserva para los saltos de versión, que se detallan en el apartado siguiente.

> **Nota:** `dist-upgrade` es el nombre histórico en `apt-get`; en el comando moderno `apt` se llama `full-upgrade`. Ambos hacen exactamente lo mismo, así que se pueden usar indistintamente.

---

### 2.5 Actualización de la distribución

Para realizar saltos de versión (por ejemplo, de Debian 12 "Bookworm" a Debian 13 "Trixie"), el proceso es el siguiente:

```bash
root@debian:~# cp -a /etc/apt/sources.list /etc/apt/sources.list.bak
root@debian:~# sed -i 's/bookworm/trixie/g' /etc/apt/sources.list
root@debian:~# sed -i 's/bookworm/trixie/g' /etc/apt/sources.list.d/*.list
root@debian:~# apt update
root@debian:~# apt upgrade --without-new-pkgs
root@debian:~# apt full-upgrade
root@debian:~# apt --purge autoremove
root@debian:~# reboot
```

> **Advertencia:** Los dos comandos `sed` solo actúan sobre ficheros con extensión `.list`. Si la máquina emplea el formato **deb822** descrito más arriba, su configuración vive en ficheros `.sources` y el patrón no encontrará nada, con lo que `apt update` seguirá apuntando a la versión antigua y el salto no se producirá. En ese caso hay que incluir también:
>
> ```bash
> root@debian:~# sed -i 's/bookworm/trixie/g' /etc/apt/sources.list.d/*.sources
> ```

> **Importante:** El orden `upgrade --without-new-pkgs` antes de `full-upgrade` es el que recomiendan las notas de publicación de Debian, y no es caprichoso. La primera pasada actualiza lo que puede sin eliminar nada, de modo que el sistema queda en un estado coherente; la segunda resuelve ya los cambios que exigen añadir o retirar paquetes. Hacer directamente `full-upgrade` sobre un sistema a medio actualizar multiplica las posibilidades de quedarse con dependencias rotas a mitad de proceso.

> **Recuerda:** Antes de un salto de versión conviene siempre comprobar que no queda nada a medias (`dpkg --audit`), que no hay paquetes retenidos que puedan bloquear el proceso (`apt-mark showhold`), leer las notas de publicación de la versión de destino y, sobre todo, disponer de una copia de seguridad. En una máquina virtual, una instantánea previa resuelve el problema por completo.

---

### 2.6 Diferencias entre clean, remove, purge y autoremove

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

### 3.1 Herramienta rpm

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

### 3.2 Herramienta yum / dnf

Es el equivalente a `apt` en distribuciones Red Hat (CentOS, Fedora, Rocky, AlmaLinux). Resuelve dependencias automáticamente. Modernamente, `dnf` reemplaza a `yum`, manteniendo la misma sintaxis de comandos.

| Comando `yum` | Funcionalidad |
|---------------|---------------|
| `install` | Instala paquetes y resuelve dependencias. |
| `update` | Actualiza todos los paquetes instalados. |
| `check-update` | Lista los paquetes que tienen actualización disponible. Se parece más a `apt list --upgradable` que a `apt update`, ya que `yum` y `dnf` refrescan sus metadatos automáticamente cuando caducan. El equivalente exacto de `apt update` sería `dnf makecache`. |
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

---

## 4. Práctica: dos versiones de Apache en el mismo servidor

Hasta ahora todo el software se ha instalado con `apt`. Es la vía recomendada, pero no la única. En esta práctica se instalan en el mismo Debian 13 **dos servidores Apache distintos funcionando a la vez**:

- El Apache del **repositorio de Debian**, instalado con `apt`, escuchando en el puerto **80**.
- Un Apache **2.4.62 compilado desde su código fuente** (`.tar.gz`), instalado en `/opt` y escuchando en el puerto **8080**.

En la vida real se recurre a esto cuando una aplicación antigua solo está certificada para una versión concreta, cuando se quiere probar una versión nueva antes de actualizar la de producción, o cuando se necesita una opción de compilación que el paquete de la distribución no incluye.

### 4.1 Esquema de la práctica

| | Apache de `apt` | Apache compilado |
|---|---|---|
| Origen | Repositorio de Debian (paquete `.deb`) | Código fuente `.tar.gz` de apache.org |
| Ubicación | Repartido según el FHS: `/usr/sbin/apache2`, `/etc/apache2`, `/var/www/html` | Todo junto en `/opt/apache-2.4.62` |
| Puerto | 80 | 8080 |
| Nombre del binario | `apache2` | `httpd` |
| Servicio | `apache2.service` (lo trae el paquete) | `apache-opt.service` (lo crea el administrador) |

> **Nota:** ¿Por qué `/opt` y no `/usr/local`? Según el FHS (documento 01), `/usr/local` es para software compilado en local que se **integra** en el sistema, repartiendo sus ficheros en `/usr/local/bin`, `/usr/local/etc`... Mientras que `/opt/<paquete>` es para software **autocontenido**, con todos sus ficheros dentro de un único directorio. Al instalar en `/opt/apache-2.4.62`, con la versión en el nombre, pueden convivir varias versiones sin mezclarse, y desinstalar una se reduce a borrar su directorio.

### 4.2 Instalación desde el repositorio

La vía habitual, con un solo comando y las dependencias resueltas automáticamente:

```bash
root@debian:~# apt update && apt install apache2 -y
root@debian:~# apache2 -v
Server version: Apache/2.4.65 (Debian)
Server built:   2025-07-29T10:21:46
root@debian:~# echo '<h1>Apache de apt (puerto 80)</h1>' > /var/www/html/index.html
```

La versión exacta depende de las actualizaciones que haya publicado Debian; lo importante es que será distinta de la que se va a compilar. La página de inicio se cambia para poder distinguir después qué Apache responde.

### 4.3 Preparación y descarga del código fuente

Compilar exige herramientas y bibliotecas que no hacen falta para instalar con `apt`:

```bash
root@debian:~# apt install build-essential libapr1-dev libaprutil1-dev libpcre2-dev libssl-dev wget -y
```

| Paquete | Para qué se necesita |
|---|---|
| `build-essential` | El compilador `gcc`, `make` y las herramientas básicas de compilación. |
| `libapr1-dev`, `libaprutil1-dev` | *Apache Portable Runtime*, la biblioteca base sobre la que está construido Apache. |
| `libpcre2-dev` | Expresiones regulares, usadas en la configuración y en `mod_rewrite`. |
| `libssl-dev` | Soporte de HTTPS (`mod_ssl`). |

> **Nota:** Los paquetes terminados en `-dev` contienen las **cabeceras** (ficheros `.h`) de una biblioteca. Para *ejecutar* un programa basta con la biblioteca compartida (`.so`, documento 01), pero para *compilarlo* el compilador necesita además sus cabeceras. Por eso un servidor en producción no suele tener instalados los `-dev`.

El código fuente se descarga en `/usr/local/src`, el directorio que el FHS reserva para el código fuente de lo que se compila en local. Junto al `.tar.gz` se descarga su suma de comprobación para verificar que el fichero es íntegro:

```bash
root@debian:~# cd /usr/local/src
root@debian:/usr/local/src# wget https://archive.apache.org/dist/httpd/httpd-2.4.62.tar.gz
root@debian:/usr/local/src# wget https://archive.apache.org/dist/httpd/httpd-2.4.62.tar.gz.sha256
root@debian:/usr/local/src# sha256sum -c httpd-2.4.62.tar.gz.sha256
httpd-2.4.62.tar.gz: OK
root@debian:/usr/local/src# tar -xzf httpd-2.4.62.tar.gz
root@debian:/usr/local/src# cd httpd-2.4.62
```

> **Importante:** Con `apt`, la autenticidad de cada paquete se comprueba sola mediante las firmas del repositorio. Al descargar software a mano, esa comprobación pasa a ser **responsabilidad del administrador**: si `sha256sum -c` no devuelve `OK`, el fichero está dañado o ha sido manipulado y no debe usarse.

> **Advertencia:** Se usa `archive.apache.org` porque conserva todas las versiones publicadas, mientras que la web de descargas principal solo mantiene la más reciente. La 2.4.62 tiene vulnerabilidades corregidas en versiones posteriores: sirve para el laboratorio, precisamente por ser distinta de la de Debian, pero en producción se compila siempre la última versión disponible.

### 4.4 Compilación e instalación en /opt

La instalación desde código fuente sigue tres pasos clásicos, comunes a la mayoría del software libre:

```bash
root@debian:/usr/local/src/httpd-2.4.62# ./configure --prefix=/opt/apache-2.4.62 --enable-so --enable-ssl --enable-rewrite
root@debian:/usr/local/src/httpd-2.4.62# make -j"$(nproc)"
root@debian:/usr/local/src/httpd-2.4.62# make install
```

| Paso | Qué hace |
|---|---|
| `./configure` | Examina el sistema (compilador, bibliotecas disponibles) y prepara la compilación para esta máquina concreta. Con `--prefix` se indica dónde se instalará todo, y con las opciones `--enable-...` qué módulos se incluyen. |
| `make` | Compila el código fuente y genera los binarios. Es el paso más largo; `-j"$(nproc)"` reparte el trabajo entre todos los núcleos del procesador. |
| `make install` | Copia los binarios, la configuración y la documentación al directorio indicado en `--prefix`. |

> **Nota:** Si `./configure` se detiene con un error del tipo `APR not found` o `pcre2-config not found`, falta alguna biblioteca de desarrollo. La última línea del error indica cuál; basta con instalar el paquete `-dev` correspondiente y repetir el paso.

El resultado es un árbol completo y autocontenido dentro de `/opt`:

```bash
root@debian:~# ls /opt/apache-2.4.62
bin  build  cgi-bin  conf  error  htdocs  icons  include  logs  man  manual  modules
root@debian:~# /opt/apache-2.4.62/bin/httpd -v
Server version: Apache/2.4.62 (Unix)
Server built:   Sep 29 2026 10:42:17
```

| Directorio | Contenido |
|---|---|
| `bin/` | Los ejecutables: `httpd` y la herramienta de control `apachectl`. |
| `conf/` | La configuración, con `httpd.conf` como fichero principal. |
| `htdocs/` | La raíz de la web (el equivalente a `/var/www/html`). |
| `logs/` | Los registros de acceso y de error, y el fichero con el PID. |
| `modules/` | Los módulos compilados. |

> **Recuerda:** Estos binarios no están en ninguna ruta del `PATH`, así que `httpd -v` a secas devuelve `command not found`. Hay que invocarlos con su ruta completa (documento 07). Es una ventaja: así nunca se confunden con los del Apache de `apt`.

### 4.5 Configuración para que no choquen

Dos servicios no pueden escuchar en el mismo puerto. Como el Apache de `apt` ya ocupa el 80, el compilado se pasa al 8080:

```bash
root@debian:~# sed -i 's/^Listen 80$/Listen 8080/' /opt/apache-2.4.62/conf/httpd.conf
root@debian:~# echo 'ServerName localhost:8080' >> /opt/apache-2.4.62/conf/httpd.conf
root@debian:~# echo '<h1>Apache 2.4.62 compilado en /opt (puerto 8080)</h1>' > /opt/apache-2.4.62/htdocs/index.html
root@debian:~# /opt/apache-2.4.62/bin/apachectl -t
Syntax OK
```

La directiva `ServerName` evita el aviso de que Apache no puede determinar el nombre del servidor, y `apachectl -t` comprueba la sintaxis de la configuración antes de arrancar.

> **Advertencia:** Si se omite el cambio de puerto, el segundo Apache no arranca y en su log de errores aparece `(98)Address already in use: AH00072: make_sock: could not bind to address [::]:80`. Es el error típico de dos servicios que intentan ocupar el mismo puerto.

### 4.6 Registro como servicio de systemd

El Apache de `apt` trae su propia unidad de `systemd`, pero el compilado no: hay que crearla para poder gestionarlo con `systemctl` y que arranque con el sistema (documento 29). Se crea el fichero `/etc/systemd/system/apache-opt.service`:

```ini
[Unit]
Description=Apache HTTP Server 2.4.62 (compilado en /opt)
After=network.target

[Service]
Type=forking
PIDFile=/opt/apache-2.4.62/logs/httpd.pid
ExecStart=/opt/apache-2.4.62/bin/apachectl -k start
ExecStop=/opt/apache-2.4.62/bin/apachectl -k graceful-stop
ExecReload=/opt/apache-2.4.62/bin/apachectl -k graceful
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

| Directiva | Significado |
|---|---|
| `After=network.target` | Se arranca después de que la red esté configurada. |
| `Type=forking` | `apachectl` lanza el proceso de Apache en segundo plano y termina; `systemd` debe seguir al proceso que queda en marcha. |
| `PIDFile` | Fichero donde Apache anota su PID, para que `systemd` sepa qué proceso vigilar. |
| `ExecStart` / `ExecStop` / `ExecReload` | Órdenes para arrancar, parar y recargar la configuración. |
| `Restart=on-failure` | Si Apache se cae por un fallo, `systemd` lo vuelve a levantar. |
| `WantedBy=multi-user.target` | Hace que, una vez habilitado, arranque con el sistema. |

Se recarga `systemd` para que lea la nueva unidad, y se habilita y arranca en un solo paso:

```bash
root@debian:~# systemctl daemon-reload
root@debian:~# systemctl enable --now apache-opt
root@debian:~# systemctl status apache-opt
● apache-opt.service - Apache HTTP Server 2.4.62 (compilado en /opt)
     Loaded: loaded (/etc/systemd/system/apache-opt.service; enabled; preset: enabled)
     Active: active (running) since mar 2026-09-29 10:51:03 CEST; 4s ago
```

### 4.7 Comprobación: los dos Apache a la vez

Con `ss` (documento 32) se ve que hay dos servicios distintos escuchando, cada uno en su puerto:

```bash
root@debian:~# ss -tlnp | grep -E ':(80|8080) '
LISTEN 0  511  *:80    *:*  users:(("apache2",pid=1432,fd=4),("apache2",pid=1431,fd=4))
LISTEN 0  511  *:8080  *:*  users:(("httpd",pid=2210,fd=3),("httpd",pid=2209,fd=3))
```

Y con `curl` (documento 33) se comprueba que cada uno sirve su propia página:

```bash
root@debian:~# curl http://localhost
<h1>Apache de apt (puerto 80)</h1>
root@debian:~# curl http://localhost:8080
<h1>Apache 2.4.62 compilado en /opt (puerto 8080)</h1>
```

> **Nota:** El propio nombre del proceso delata el origen de cada uno. El proyecto Apache llama a su binario `httpd`, mientras que Debian lo renombra a `apache2` en su paquete.

### 4.8 Comparativa: apt frente a código fuente

| Aspecto | Instalación con `apt` | Compilación en `/opt` |
|---|---|---|
| Instalación | Un comando; dependencias automáticas. | Dependencias de compilación a mano y los pasos `configure`, `make` y `make install`. |
| Ficheros | Repartidos por el FHS (`/usr/sbin`, `/etc/apache2`, `/var/www`). | Todo junto en `/opt/apache-2.4.62`. |
| Versión y opciones | Las que decide Debian. | Las que elige el administrador. |
| Actualizaciones de seguridad | Automáticas con `apt upgrade`. | **Ninguna**: hay que descargar y compilar cada versión nueva. |
| Servicio de `systemd` | Lo trae el paquete. | Hay que crearlo. |
| Desinstalación | `apt purge apache2` | Parar el servicio, borrar su unidad y el directorio de `/opt`. |

> **Importante:** La gran desventaja de compilar es que `apt` **no sabe que ese Apache existe**, así que no recibirá ningún parche de seguridad. Por eso solo se compila cuando hay un motivo concreto, y en ese caso el administrador asume el mantenimiento de esa versión.

Para desinstalar el Apache compilado basta con deshacer lo hecho, gracias a que todo está en un único directorio:

```bash
root@debian:~# systemctl disable --now apache-opt
root@debian:~# rm /etc/systemd/system/apache-opt.service
root@debian:~# systemctl daemon-reload
root@debian:~# rm -rf /opt/apache-2.4.62
```
