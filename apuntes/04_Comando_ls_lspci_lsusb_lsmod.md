# Comando ls

El comando ls lista archivos y directorios en un directorio especificado.

```bash
martin@debian12:~$ ls -l
total 36
drwxr-xr-x 2 martin martin 4096 mar  4 09:58 d1
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Descargas
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Documentos
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Escritorio
-rw-r--r-- 1 martin martin    0 abr 12 16:29 fichero.txt
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Imágenes
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Música
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Plantillas
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Público
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Vídeos
```

_*Nota: Se refiere el campo de fecha a la hora en la que se hizo la última modificación de contenido del fichero o directorio (creacción o eliminación de contenido en su interior).*_

Parámetros bien conocidos:

- -l: Información extendida.
- -h: Tamaño del archivo en formato humano.
- -i: Número de inodo.
- -a: Archivos ocultos.
- -r: Inverso.
- -v: Ordena la salida.
- -t: Según el orden de modificación en lugar de orden alfabético.
- --sort: Para ordenar.
- --size: En función del tamaño.
- --format: Para dar un formato a la salida.
- --time: Para mostrar por atime, mtime, o ctime.
- -1: Muestra en vertical la salida.

1. -t: Lista los ficheros o directorios más nuevos al principio.

```bash
martin@debian12:~$ ls -l -t
martin@debian12:~$ ls -l --sort=time
```

```bash
martin@debian12:~$ ls -l -t
total 36
-rw-r--r-- 1 martin martin    0 abr 12 16:29 fichero.txt
drwxr-xr-x 2 martin martin 4096 mar  4 09:58 d1
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Descargas
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Documentos
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Escritorio
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Imágenes
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Música
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Plantillas
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Público
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Vídeos
```

2. -S: Lista por tamaño de mayor a menor.

```bash
martin@debian12:~$ ls -l -S
martin@debian12:~$ ls -l --sort=size
```

```bash
martin@debian12:~$ ls -l -S
total 36
drwxr-xr-x 2 martin martin 4096 mar  4 09:58 d1
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Descargas
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Documentos
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Escritorio
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Imágenes
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Música
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Plantillas
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Público
drwxr-xr-x 2 martin martin 4096 feb  2 18:10 Vídeos
-rw-r--r-- 1 martin martin    0 abr 12 16:29 fichero.txt
```

3. -m: Listado de elementos separados por comas.

```bash
martin@debian12:~$ ls -m
martin@debian12:~$ ls -l --format=commas
```

```bash
martin@debian12:~$ ls -m
d1, Descargas, Documentos, Escritorio, fichero.txt, Imágenes, Música, Plantillas,
Público, Vídeos
```

4. Vertical, Horizontal y una columna: El listado se realiza por linea y no por columa.

```bash
martin@debian12:~$ ls -x
martin@debian12:~$ ls -l --format=horizontal
```

```bash
martin@debian12:~$ ls
d1         Documentos  fichero.txt  Música      Público
Descargas  Escritorio  Imágenes     Plantillas  Vídeos

martin@debian12:~$ ls --format=vertical
d1         Documentos  fichero.txt  Música      Público
Descargas  Escritorio  Imágenes     Plantillas  Vídeos

martin@debian12:~$ ls -x
d1       Descargas  Documentos  Escritorio  fichero.txt  Imágenes  Música  Plantillas
Público  Vídeos

martin@debian12:~$ ls --format=horizontal
d1       Descargas  Documentos  Escritorio  fichero.txt  Imágenes  Música  Plantillas
Público  Vídeos

martin@debian12:~$ ls --format=single-column
d1
Descargas
Documentos
Escritorio
fichero.txt
Imágenes
Música
Plantillas
Público
Vídeos
```

5. Ordenación vertical ordenada de un directorio con `ls -v -1`.

```bash
si@si-VirtualBox:~$ ls
Desktop  Documents  Downloads  Music  Pictures  prueba  Public  snap  Templates  Videos
si@si-VirtualBox:~$ ls -1
Desktop
Documents
Downloads
Music
Pictures
prueba
Public
snap
Templates
Videos
si@si-VirtualBox:~$ ls -1 -v
Desktop
Documents
Downloads
Music
Pictures
Public
Templates
Videos
prueba
snap
```

# Comando lspci

El comando **lspci** muestra información sobre los dispositivos PCI conectados al sistema (tarjetas de red, gráficas, etc.).

```bash
usuario@usuario:~$ lspci
00:00.0 Host bridge: Intel Corporation 440FX - 82441FX PMC [Natoma] (rev 02)
00:01.0 ISA bridge: Intel Corporation 82371SB PIIX3 ISA [Natoma/Triton II]
00:01.1 IDE interface: Intel Corporation 82371AB/EB/MB PIIX4 IDE (rev 01)
00:02.0 VGA compatible controller: VMware SVGA II Adapter
00:03.0 Ethernet controller: Intel Corporation 82540EM Gigabit Ethernet Controller (rev 02)
00:04.0 System peripheral: InnoTek Systemberatung GmbH VirtualBox Guest Service
00:05.0 Multimedia audio controller: Intel Corporation 82801AA AC'97 Audio Controller (rev 01)
00:06.0 USB controller: Apple Inc. KeyLargo/Intrepid USB
00:07.0 Bridge: Intel Corporation 82371AB/EB/MB PIIX4 ACPI (rev 08)
00:0b.0 USB controller: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Family) USB2 EHCI Controller
00:0d.0 SATA controller: Intel Corporation 82801HM/HEM (ICH8M/ICH8M-E) SATA Controller [AHCI mode] (rev 02)
```

### Opciones más usadas

- **`-v` (verbose):**  
  Muestra información más detallada sobre cada dispositivo PCI, como recursos asignados y capacidades adicionales.

```bash
usuario@usuario:~$ lspci -v
00:00.0 Host bridge: Intel Corporation 440FX - 82441FX PMC [Natoma] (rev 02)
        Flags: fast devsel

00:01.0 ISA bridge: Intel Corporation 82371SB PIIX3 ISA [Natoma/Triton II]
        Flags: bus master, medium devsel, latency 0

00:01.1 IDE interface: Intel Corporation 82371AB/EB/MB PIIX4 IDE (rev 01) (prog-if 8a [ISA Compatibility mode controller, supports both channels switched to PCI native mode, supports bus mastering])
        Flags: bus master, fast devsel, latency 64
        Memory at 000001f0 (32-bit, non-prefetchable) [virtual] [size=8]
        Memory at 000003f0 (type 3, non-prefetchable) [virtual]
        Memory at 00000170 (32-bit, non-prefetchable) [virtual] [size=8]
        Memory at 00000370 (type 3, non-prefetchable) [virtual]
        I/O ports at d000 [virtual] [size=16]
        Kernel driver in use: ata_piix
        Kernel modules: pata_acpi

00:02.0 VGA compatible controller: VMware SVGA II Adapter (prog-if 00 [VGA controller])
        Subsystem: VMware SVGA II Adapter
        Flags: bus master, fast devsel, latency 64, IRQ 18
        I/O ports at d010 [size=16]
        Memory at e0000000 (32-bit, prefetchable) [size=16M]
        Memory at f0000000 (32-bit, non-prefetchable) [size=2M]
        Expansion ROM at 000c0000 [virtual] [disabled] [size=128K]
        Kernel driver in use: vmwgfx
        Kernel modules: vmwgfx
...
```

- **`-s ` (select):**  
  Filtra la salida para mostrar solo el dispositivo PCI que coincide con la dirección especificada (formato: `[[[[dominio]:]bus]:][dispositivo][.función]`, en hexadecimal).

```bash
usuario@usuario:~$ lspci -s 00:03.0
00:03.0 Ethernet controller: Intel Corporation 82540EM Gigabit Ethernet Controller (rev 02)

usuario@usuario:~$ lspci -s 00:03.0 -v
00:03.0 Ethernet controller: Intel Corporation 82540EM Gigabit Ethernet Controller (rev 02)
        Subsystem: Intel Corporation PRO/1000 MT Desktop Adapter
        Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 19
        Memory at f0200000 (32-bit, non-prefetchable) [size=128K]
        I/O ports at d020 [size=8]
        Capabilities: <access denied>
        Kernel driver in use: e1000
        Kernel modules: e1000
```

- **`-k` (kernel drivers):**  
  Muestra, además, información sobre los controladores (drivers) del kernel que están en uso y los disponibles para cada dispositivo PCI.
  
```bash
usuario@usuario:~$ lspci -s 00:03.0 -k
00:03.0 Ethernet controller: Intel Corporation 82540EM Gigabit Ethernet Controller (rev 02)
        Subsystem: Intel Corporation PRO/1000 MT Desktop Adapter
        Kernel driver in use: e1000
        Kernel modules: e1000
```

_*Nota*_: Diferencia entre **kernel driver** y **kernel module**.
- Kernel driver: Código encargado de controlar hardware específico.
- Kernel module: Fragmento de código que puede añadirse o quitarse del kernel en caliente y tiene como objetivo en este contexto, implementar un driver.

# Comando lsusb

El comando `lsusb` muestra información sobre los buses USB y los dispositivos conectados a ellos, como memorias USB, impresoras, cámaras, etc.

```bash
usuario@usuario:~$ lsusb
Bus 002 Device 003: ID 090c:1000 Silicon Motion, Inc. - Taiwan (formerly Feiya Technology Corp.) Flash Drive
Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 002: ID 80ee:0021 VirtualBox USB Tablet
Bus 001 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
```

### Opciones más usadas

- **`-v` (verbose):**  
  Muestra información detallada sobre cada dispositivo USB, incluyendo descripciones de las interfaces, endpoints, capacidades y más detalles técnicos. Es útil para diagnósticos avanzados o para conocer características específicas de cada dispositivo.

```bash
usuario@usuario:~$ lsusb -v

Bus 002 Device 003: ID 090c:1000 Silicon Motion, Inc. - Taiwan (formerly Feiya Technology Corp.) Flash Drive
Couldn't open device, some information will be missing
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               2.00
  bDeviceClass            0
  bDeviceSubClass         0
  bDeviceProtocol         0
  bMaxPacketSize0        64
  idVendor           0x090c Silicon Motion, Inc. - Taiwan (formerly Feiya Technology Corp.)
  idProduct          0x1000 Flash Drive
  bcdDevice           11.00
  iManufacturer           1 General
  iProduct                2 USB Flash Disk
  iSerial                 3 1314310000000042
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength       0x0020
    bNumInterfaces          1
...
```

- **`-s :` (select):**  
  Permite filtrar la salida para mostrar solo el dispositivo USB que coincide con el número de bus y dispositivo especificado. El formato es `-s :`, por ejemplo, `lsusb -s 001:002` mostrará solo el dispositivo con bus 001 y dispositivo 002.

```bash
usuario@usuario:~$ lsusb -v -s 002:003

Bus 002 Device 003: ID 090c:1000 Silicon Motion, Inc. - Taiwan (formerly Feiya Technology Corp.) Flash Drive
Couldn't open device, some information will be missing
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               2.00
  bDeviceClass            0
  bDeviceSubClass         0
  bDeviceProtocol         0
...
```

- **`-t` (tree):**  
  Muestra la topología de los dispositivos USB conectados en forma de árbol, permitiendo visualizar cómo están conectados los dispositivos y hubs entre sí. Esto ayuda a entender la jerarquía y la relación física entre los dispositivos USB del sistema.

```bash
usuario@usuario:~$ lsusb -t
/:  Bus 02.Port 1: Dev 1, Class=root_hub, Driver=ehci-pci/12p, 480M
    |__ Port 1: Dev 3, If 0, Class=Mass Storage, Driver=usb-storage, 480M
/:  Bus 01.Port 1: Dev 1, Class=root_hub, Driver=ohci-pci/12p, 12M
    |__ Port 1: Dev 2, If 0, Class=Human Interface Device, Driver=usbhid, 12M
```

# Comando lsmod, comandos de gestión de módulos del kernel

Enfocado en el listado de módulos del kernel tenemos este comando. Los módulos son partes del kernel que podemos activar o desactivar para añadir o quitar funcionalidades. Tiene una relación muy estrecha con los driver.

Son archivos terminados con la extensión .ko que se almacenan en la ubicación `/lib/modules/<versión_del_kernel>/`

```bash
root@usuario:~# lsmod | grep floppy
root@usuario:~# find / -name floppy.ko 2> /dev/null
/usr/lib/modules/6.8.0-49-generic/kernel/drivers/block/floppy.ko
/usr/lib/modules/6.8.0-40-generic/kernel/drivers/block/floppy.ko
root@usuario:~# uname -r
6.8.0-49-generic
```

- **lsmod**: Muestra módulos cargados en el sistema.
- **modinfo**: Amplia información de un módulo.  
- **insmod**: Carga un fichero .ko en el sistema.  
- **rmmod**: Quita un módulo del sistema.
  -w : Espera a que deje de utilizarse.  
  -f : Fuerza el borrado.  

Vamos a eliminar el módulo *psmouse* ya que no es necesario para nuestra máquina. 

```bash
root@usuario:~# lsmod | grep psmouse
psmouse               217088  0
root@usuario:~# rmmod psmouse
root@usuario:~# lsmod | grep psmouse
```

Instalamos el módulo *psmouse* de nuevo. En caso de que existan dependencias tendremos un error y tendremos que gestionar las dependencias una por una.

```bash
root@usuario:~# uname -r
6.8.0-49-generic
root@usuario:~# cd /lib/modules/6.8.0-49-generic/
root@usuario:/lib/modules/6.8.0-49-generic# find -name psmouse.ko
./kernel/drivers/input/mouse/psmouse.ko
root@usuario:/lib/modules/6.8.0-49-generic# insmod $(find -name psmouse.ko) && lsmod | grep psmouse
psmouse               217088  0
```

Por otro lado tenemos el comando **modprobe**, el cual carga o borra módulos y resuelve las dependencias entre éstos. Como parámetros a destacar.
- f : Fuerza la carga del módulo aunque la versión del kernel no coincida con la que espera encontrar.  
- r : Elimina el módulo.  
- v : Muestra información adicional de lo que realiza.  
- n : Hace una simulación pero no inserta el módulo.

Elimino el módulo *psmouse* y lo instalo de nuevo. En este caso *psmouse* no requiere dependencias de otros módulos pero si fuera el caso las instalaría.

```bash
root@usuario:~# modprobe -r psmouse
root@usuario:~# lsmod | grep psmouse
root@usuario:~# modprobe psmouse
root@usuario:~# lsmod | grep psmouse
psmouse               217088  0
```

A mayores, existe el comando **dmesg** en Linux que muestra los mensajes del buffer del kernel, incluyendo información sobre hardware, dispositivos, errores y eventos del sistema. Para ejecutarlo en una terminal podemos realizar:
- dmesg: Muestra todos los mensajes del buffer del kernel.
- dmesg --level=err: Muestra errores del kernel.
- dmesg -T: Nos muestra los mensajes del kernel en una fecha legible para humanos.