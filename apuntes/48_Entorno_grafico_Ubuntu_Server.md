# Entorno gráfico en Ubuntu Server

## Índice

1. [Ubuntu Server en modo texto](#1-ubuntu-server-en-modo-texto)
2. [¿Instalar un entorno gráfico en un servidor?](#2-instalar-un-entorno-gráfico-en-un-servidor)
3. [Preparar el sistema antes de instalar](#3-preparar-el-sistema-antes-de-instalar)
4. [Instalar el entorno gráfico](#4-instalar-el-entorno-gráfico)
   1. [Con tasksel](#41-con-tasksel)
   2. [Con apt](#42-con-apt)
   3. [Reiniciar](#43-reiniciar)
5. [Inicio de sesión gráfico](#5-inicio-de-sesión-gráfico)
6. [Terminales virtuales (TTY)](#6-terminales-virtuales-tty)
7. [Volver a arrancar en modo texto](#7-volver-a-arrancar-en-modo-texto)

---

## 1. Ubuntu Server en modo texto

Una vez instalado Ubuntu Server, lo que se obtiene es una **terminal en modo texto**: no hay ventanas ni ratón, y todo se hace introduciendo órdenes de Linux. Lo primero que muestra es la pantalla de inicio de sesión, donde hay que escribir el usuario y la contraseña creados durante la instalación:

```bash
Ubuntu 26.04 LTS srv tty1

srv login: usuario
Password:
Welcome to Ubuntu 26.04 LTS

usuario@srv:~$
```

La primera línea indica la versión del sistema, el nombre del equipo (`srv`) y la terminal en la que se está trabajando (`tty1`, apartado 6). Al escribir la contraseña no aparece nada en pantalla, ni siquiera asteriscos. Una vez dentro, el *prompt* `usuario@srv:~$` indica que el sistema está listo para recibir órdenes.

---

## 2. ¿Instalar un entorno gráfico en un servidor?

Es **posible, pero no necesario**, instalar un entorno gráfico para trabajar de una forma más amigable. Conviene conocer sus ventajas y sus inconvenientes antes de hacerlo:

| | Sin entorno gráfico | Con entorno gráfico |
|---|---|---|
| Memoria y disco | Mínimos: el servidor dedica sus recursos a los servicios. | El escritorio consume entre 1 y 2 GB de RAM y varios GB de disco. |
| Seguridad | Menos programas instalados, y por tanto menos fallos de seguridad posibles. | Cientos de paquetes más que mantener actualizados. |
| Facilidad de uso | Exige conocer las órdenes. | Más intuitivo para quien empieza. |
| Administración remota | Por SSH (documento 34), que es lo habitual. | Además, por escritorio remoto (documento 08 de servicios en red). |

> **Importante:** En un entorno real, los servidores casi nunca tienen entorno gráfico: se administran a distancia por SSH o mediante paneles web como Webmin (tarea 1.6 de los apuntes). Instalar un escritorio tiene sentido en un laboratorio, o en un equipo que se vaya a usar también como puesto de trabajo. Si se instala, conviene elegir uno **ligero** (apartado 4).

---

## 3. Preparar el sistema antes de instalar

Antes de instalar el entorno gráfico conviene dar dos pasos. El primero **actualiza la lista** de paquetes y versiones disponibles en los repositorios:

```bash
usuario@srv:~$ sudo apt update
```

El segundo **actualiza los paquetes instalados** a sus nuevas versiones:

```bash
usuario@srv:~$ sudo apt upgrade
```

La diferencia entre las dos órdenes se explica en detalle en el apartado 2.4 del documento 27: `update` solo descarga la lista de lo que hay disponible, sin instalar nada, y `upgrade` instala las versiones nuevas de lo que ya está instalado.

> **Nota:** La orden **`sudo`** (*superuser do*) permite a un usuario ejecutar órdenes con privilegios de administrador (`root`). En Ubuntu, la cuenta de `root` no tiene contraseña y el usuario creado durante la instalación pertenece al grupo `sudo`, que es el que puede usar esta orden. La primera vez que se usa en una sesión, `sudo` pide la contraseña **del propio usuario**, no la de `root`.

---

## 4. Instalar el entorno gráfico

### 4.1 Con tasksel

**`tasksel`** es una utilidad que instala de una vez **conjuntos de paquetes** pensados para una tarea concreta, como un servidor web o un entorno de escritorio. Primero se instala:

```bash
usuario@srv:~$ sudo apt install tasksel
```

Al ejecutarla, muestra un menú con las tareas disponibles:

```bash
usuario@srv:~$ sudo tasksel
```

| Tecla | Acción en el menú de `tasksel` |
|---|---|
| Flechas | Moverse por la lista. |
| Espacio | Marcar o desmarcar una tarea con un asterisco `[*]`. |
| Tabulador | Saltar al botón `<Ok>`. |
| Intro | Aceptar y empezar la instalación. |

Se marca **Ubuntu desktop** y se acepta. La instalación descarga e instala varios cientos de paquetes, así que tarda unos minutos. También se puede indicar la tarea directamente, sin pasar por el menú:

```bash
usuario@srv:~$ sudo tasksel install ubuntu-desktop
```

### 4.2 Con apt

Cada escritorio es en realidad un **metapaquete**: un paquete vacío que solo sirve para instalar como dependencias todos los programas del escritorio. Por eso también se puede instalar directamente con `apt`, eligiendo el tamaño del escritorio:

| Metapaquete | Escritorio | Qué incluye |
|---|---|---|
| `ubuntu-desktop` | GNOME, el de Ubuntu | El escritorio completo: navegador, LibreOffice, reproductores, juegos... |
| `ubuntu-desktop-minimal` | GNOME | El escritorio con lo básico: navegador y utilidades. |
| `xubuntu-desktop` | XFCE | Escritorio ligero y completo, el de Xubuntu. |
| `xubuntu-core` | XFCE | Lo mínimo de XFCE. Es la opción más ligera para un servidor. |

```bash
usuario@srv:~$ sudo apt install ubuntu-desktop-minimal
```

> **Nota:** Durante la instalación de algunos escritorios, se pregunta qué **gestor de inicio de sesión** (*display manager*) usar si hay varios: `gdm3` es el de GNOME y `lightdm` el de XFCE. Es el programa que muestra la pantalla gráfica para escribir el usuario y la contraseña.

### 4.3 Reiniciar

Una vez terminada la instalación, se reinicia el equipo:

```bash
usuario@srv:~$ sudo reboot
```

---

## 5. Inicio de sesión gráfico

Tras el reinicio, en lugar de la terminal de texto aparece la **pantalla gráfica de inicio de sesión**, con la lista de usuarios del sistema. Se elige el usuario, se escribe su contraseña y se entra al **escritorio**.

El escritorio GNOME de Ubuntu tiene una barra superior con la fecha y los menús del sistema, un panel lateral con las aplicaciones favoritas y, al pulsar **Actividades** o la tecla Windows, una vista con todas las aplicaciones y ventanas. La terminal gráfica se abre con **`Ctrl+Alt+T`**.

El sistema arranca ahora en modo gráfico porque, al instalar el escritorio, ha cambiado el **objetivo** (*target*) de arranque de `systemd` (documento 29):

```bash
usuario@srv:~$ systemctl get-default
graphical.target
```

| Objetivo | Arranque |
|---|---|
| `multi-user.target` | Modo texto, con todos los servicios de red. Es el de Ubuntu Server recién instalado. |
| `graphical.target` | Lo mismo, más el entorno gráfico. |

---

## 6. Terminales virtuales (TTY)

Aunque se haya instalado el entorno gráfico, se puede seguir usando la **terminal en modo texto**. Linux ofrece varias **terminales virtuales** (*TTY*), como si el equipo tuviera varias pantallas independientes, y se cambia de una a otra con las combinaciones **`Ctrl+Alt+F1`** a **`Ctrl+Alt+F6`**. Cada terminal virtual corresponde a un fichero de dispositivo: la de `Ctrl+Alt+F6`, por ejemplo, es `/dev/tty6`.

En Ubuntu con escritorio GNOME, las terminales se reparten así:

| Combinación | Terminal | Qué muestra |
|---|---|---|
| `Ctrl+Alt+F1` | `tty1` | La **pantalla gráfica de inicio de sesión** (GDM). |
| `Ctrl+Alt+F2` | `tty2` | La **sesión gráfica** del usuario que ha iniciado sesión. |
| `Ctrl+Alt+F3` a `Ctrl+Alt+F6` | `tty3` a `tty6` | **Terminales en modo texto**, cada una con su propio inicio de sesión. |

> **Importante:** Con el escritorio GNOME, la sesión gráfica no está en `tty1`, sino en la primera terminal libre, la `tty2`: la `tty1` la ocupa la pantalla de inicio de sesión. Por eso, para volver al escritorio después de usar una terminal de texto, se pulsa `Ctrl+Alt+F2`. La distribución exacta depende de cada distribución y de su gestor de inicio de sesión.

Al pasar, por ejemplo, a `Ctrl+Alt+F3`, aparece un inicio de sesión en modo texto como el del apartado 1:

```text
Ubuntu 26.04 LTS srv tty3

srv login:
```

Varias órdenes ayudan a orientarse:

| Orden | Para qué sirve |
|---|---|
| `tty` | Muestra en qué terminal se está trabajando, por ejemplo `/dev/tty3`. En una ventana de terminal del escritorio muestra una pseudoterminal, como `/dev/pts/0`. |
| `who` | Muestra los usuarios conectados y en qué terminal (documento 06). |
| `sudo chvt 3` | Cambia a la terminal 3 desde la línea de órdenes. |

> **Advertencia:** En una máquina virtual, la combinación `Ctrl+Alt+Fn` la captura el **sistema anfitrión** y no llega a la máquina virtual. En VirtualBox se usa en su lugar la **tecla anfitrión** (por defecto, el `Ctrl` derecho) junto con la tecla de función: `Ctrl derecho+F3` equivale a `Ctrl+Alt+F3` dentro de la máquina virtual. También se puede enviar desde el menú **Entrada → Teclado**.

---

## 7. Volver a arrancar en modo texto

El entorno gráfico se puede mantener instalado y, aun así, hacer que el servidor arranque en modo texto, para que no consuma recursos. Se cambia el objetivo de arranque de `systemd`:

```bash
usuario@srv:~$ sudo systemctl set-default multi-user.target
Created symlink '/etc/systemd/system/default.target' → '/usr/lib/systemd/system/multi-user.target'.
usuario@srv:~$ sudo reboot
```

| Orden | Acción |
|---|---|
| `sudo systemctl set-default multi-user.target` | Arranca en modo texto a partir del próximo reinicio. |
| `sudo systemctl set-default graphical.target` | Vuelve a arrancar en modo gráfico. |
| `sudo systemctl isolate graphical.target` | Inicia el entorno gráfico en este momento, sin reiniciar ni cambiar el arranque. |
| `systemctl get-default` | Muestra el objetivo de arranque actual. |

Para desinstalar por completo el entorno gráfico, se elimina el metapaquete instalado y, a continuación, las dependencias que han quedado huérfanas (apartado 2.6 del documento 27):

```bash
usuario@srv:~$ sudo apt purge ubuntu-desktop-minimal
usuario@srv:~$ sudo apt autoremove --purge
```
