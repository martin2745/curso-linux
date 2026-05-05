# Comando mount y umount

## Índice

1. [Comando mount](#1-comando-mount)
2. [Comando umount](#2-comando-umount)
3. [Opciones comunes](#3-opciones-comunes)
4. [Ejemplos prácticos](#4-ejemplos-prácticos)

---

Los comandos `mount` y `umount` son fundamentales en sistemas Unix/Linux para montar y desmontar sistemas de archivos respectivamente. Aquí te explico cómo funcionan y cómo se utilizan:

---

## 1. Comando mount

El comando `mount` se utiliza para montar (conectar) un sistema de archivos en una ubicación específica dentro del árbol de directorios del sistema. Esto permite que el contenido del sistema de archivos sea accesible en esa ubicación. 

Su sintaxis básica es:

```bash
mount [opciones] dispositivo punto_de_montaje
```

- `dispositivo` es la partición o dispositivo que contiene el sistema de archivos que deseas montar.
- `punto_de_montaje` es el directorio vacío (o que actuará como tal) en el que deseas montar el sistema de archivos.

Por ejemplo, si tienes una partición `/dev/sdb1` que quieres montar en `/mnt/nueva_particion`, puedes hacerlo así:

```bash
mount /dev/sdb1 /mnt/nueva_particion
```

> **Nota:** Además de montar dispositivos físicos (discos, USBs), `mount` también puede montar sistemas de archivos de red, como NFS (Network File System) o Samba (SMB/CIFS).

---

## 2. Comando umount

El comando `umount` se utiliza para desmontar (desconectar) un sistema de archivos previamente montado de una ubicación específica.

Su sintaxis básica es:

```bash
umount [opciones] punto_de_montaje
```

- `punto_de_montaje` es el directorio donde se montó el sistema de archivos y que deseas desmontar. (También se puede usar el nombre del dispositivo, por ejemplo `umount /dev/sdb1`).

Por ejemplo, si deseas desmontar la partición que acabamos de montar en `/mnt/nueva_particion`, puedes hacerlo así:

```bash
umount /mnt/nueva_particion
```

> **Advertencia:** No podrás desmontar un sistema de archivos si hay algún proceso usándolo o si algún usuario tiene una terminal abierta dentro de ese directorio. Si necesitas forzarlo o ver quién lo bloquea, puedes usar comandos como `lsof` o `fuser`.

---

## 3. Opciones comunes

| Parámetro | Descripción |
|-----------|-------------|
| `-o` | (`options`) Permite especificar opciones adicionales para el montaje o desmontaje, separadas por comas (ej. `rw`, `ro`, `remount`). |
| `-t` | (`type`) Permite especificar el tipo de sistema de archivos que se está montando o desmontando (ej. `ext4`, `ntfs`, `nfs`). |

---

## 4. Ejemplos prácticos

Montar una unidad USB en `/mnt/usb`:

```bash
mount /dev/sdb1 /mnt/usb
```

Desmontar la unidad USB de `/mnt/usb`:

```bash
umount /mnt/usb
```

Desmontar una carpeta compartida de red NFS:

```bash
umount /mnt/nfs
```
