# Comando mount y umount

El comando `mount` y `umount` son fundamentales en sistemas Unix/Linux para montar y desmontar sistemas de archivos respectivamente. Aquí te explico cómo funcionan y cómo se utilizan:

## mount:

El comando `mount` se utiliza para montar (conectar) un sistema de archivos en una ubicación específica dentro del árbol de directorios del sistema. Esto permite que el contenido del sistema de archivos sea accesible en esa ubicación. Aquí hay una descripción básica de cómo se utiliza:

```bash
mount [opciones] dispositivo punto_de_montaje
```

- `dispositivo` es la partición o dispositivo que contiene el sistema de archivos que deseas montar.
- `punto_de_montaje` es el directorio en el que deseas montar el sistema de archivos.

Por ejemplo, si tienes una partición `/dev/sdb1` que quieres montar en `/mnt/nueva_particion`, puedes hacerlo así:

```bash
mount /dev/sdb1 /mnt/nueva_particion
```

Además de montar dispositivos, `mount` también puede montar sistemas de archivos de red, como NFS (Network File System) o Samba.

## umount:

El comando `umount` se utiliza para desmontar (desconectar) un sistema de archivos previamente montado de una ubicación específica. Aquí está cómo se utiliza:

```bash
umount [opciones] punto_de_montaje
```

- `punto_de_montaje` es el directorio donde se montó el sistema de archivos y que deseas desmontar.

Por ejemplo, si deseas desmontar la partición que acabamos de montar en `/mnt/nueva_particion`, puedes hacerlo así:

```bash
umount /mnt/nueva_particion
```

3. **Opciones comunes**:

   - `-o` (options): Permite especificar opciones adicionales para el montaje o desmontaje, como opciones de montaje específicas del sistema de archivos.
   - `-t` (type): Permite especificar el tipo de sistema de archivos que se está montando o desmontando.

4. **Ejemplos**:

- Montar una unidad USB en `/mnt/usb`:

```bash
mount /dev/sdb1 /mnt/usb
```

- Desmontar la unidad USB de `/mnt/usb`:

```bash
umount /mnt/usb
```

- Desmontar la carpeta compartida de red NFS:

```bash
umount /mnt/nfs
```
