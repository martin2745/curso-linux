# Comando ls y Gestión de Hardware/Módulos

## Índice

1. [Comando ls](#comando-ls)
2. [Comandos lspci, lsusb y lsmod (Hardware e interfaces)](#comandos-lspci-lsusb-y-lsmod-hardware-e-interfaces)
3. [Comando lspci](#comando-lspci)
4. [Comando lsusb](#comando-lsusb)
5. [Comando lsmod y gestión de módulos del kernel](#comando-lsmod-y-gestión-de-módulos-del-kernel)
6. [Comando dmesg](#comando-dmesg)

---

## Comando ls

El comando `ls` (*List*) se utiliza para listar archivos y directorios en un directorio especificado. Es uno de los comandos más utilizados en la administración diaria para observar la estructura del sistema de ficheros y revisar atributos, permisos y fechas de los elementos.

```bash
usuario@debian:~$ ls -l
total 36
drwxr-xr-x 2 usuario usuario 4096 mar  4 09:58 d1
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Descargas
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Documentos
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Escritorio
-rw-r--r-- 1 usuario usuario    0 abr 12 16:29 fichero.txt
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Imágenes
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Música
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Plantillas
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Público
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Vídeos
```

> **Nota:** El campo de fecha y hora mostrado en el formato extendido se refiere por defecto al momento en el que se hizo la última modificación del contenido del fichero o directorio (creación o eliminación de contenido en su interior, es decir, el *mtime*).

### Tabla de Parámetros bien conocidos

Para ajustar la salida de `ls`, podemos usar los siguientes parámetros:

| Parámetro / Opción | Descripción |
|--------------------|-------------|
| `-l` | Muestra la información en formato extendido o detallado (permisos, propietario, tamaño, fecha). |
| `-h` | (*Human-readable*) Muestra el tamaño de los archivos de forma legible, como KB, MB, GB (se usa junto a `-l`). |
| `-i` | Muestra el número de inodo que identifica internamente al archivo en el sistema de ficheros. |
| `-a` | (*All*) Lista también los archivos ocultos (los que comienzan con un punto `.`). |
| `-r` | (*Reverse*) Invierte el orden de la salida listada. |
| `-v` | (*Version*) Ordena la salida numéricamente teniendo en cuenta el versionado de los nombres de fichero. |
| `-t` | (*Time*) Ordena la lista basándose en la fecha de modificación (los más recientes primero) en lugar del orden alfabético. |
| `--sort=WORD` | Ordena explícitamente usando palabras clave como `none`, `time`, `size`, `extension` o `version`. |
| `--size` o `-s` | Muestra o utiliza para ordenar el tamaño asignado de los archivos. |
| `--format=WORD` | Configura el aspecto de la salida (ej. `across`, `commas`, `horizontal`, `long`, `single-column`, `vertical`). |
| `--time=WORD` | Cambia el tiempo mostrado u ordenado entre tiempo de acceso (`atime`), cambio de atributos (`ctime`) o modificación (`mtime`). |
| `-1` (uno) | Obliga a que la salida se muestre en una sola columna vertical estricta. |

### Ejemplos de uso avanzado del comando ls

**1. Ordenación por tiempo:** Lista los ficheros o directorios más nuevos al principio. El parámetro `-t` o `--sort=time` realiza esta misma acción.

```bash
usuario@debian:~$ ls -l -t
# O de manera equivalente:
usuario@debian:~$ ls -l --sort=time
```

Ambos comandos devolverán la lista priorizando lo modificado recientemente:

```bash
usuario@debian:~$ ls -l -t
total 36
-rw-r--r-- 1 usuario usuario    0 abr 12 16:29 fichero.txt
drwxr-xr-x 2 usuario usuario 4096 mar  4 09:58 d1
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Descargas
...
```

**2. Ordenación por tamaño:** Lista los archivos de mayor a menor tamaño (útil para encontrar archivos pesados).

```bash
usuario@debian:~$ ls -l -S
# O de manera equivalente:
usuario@debian:~$ ls -l --sort=size
```

Cuyo resultado prioriza `d1` y otros directorios frente al archivo de 0 bytes:

```bash
usuario@debian:~$ ls -l -S
total 36
drwxr-xr-x 2 usuario usuario 4096 mar  4 09:58 d1
...
-rw-r--r-- 1 usuario usuario    0 abr 12 16:29 fichero.txt
```

**3. Formato separado por comas:** Muestra un listado de elementos contiguos separados por comas, lo que ahorra espacio visual.

```bash
usuario@debian:~$ ls -m
# O de manera equivalente:
usuario@debian:~$ ls -l --format=commas
```

La salida resultante rellena la pantalla usando todo el ancho disponible:

```bash
usuario@debian:~$ ls -m
d1, Descargas, Documentos, Escritorio, fichero.txt, Imágenes, Música, Plantillas,
Público, Vídeos
```

**4. Visualización Vertical, Horizontal y Columna Única:** Por defecto, la salida simple de `ls` intenta mostrarse en varias columnas ordenadas verticalmente, pero podemos forzar el diseño.

```bash
usuario@debian:~$ ls
d1         Documentos  fichero.txt  Música      Público
Descargas  Escritorio  Imágenes     Plantillas  Vídeos
```

Podemos utilizar la flag `--format` para experimentar distintas agrupaciones:

```bash
usuario@debian:~$ ls --format=vertical
d1         Documentos  fichero.txt  Música      Público
Descargas  Escritorio  Imágenes     Plantillas  Vídeos

usuario@debian:~$ ls -x
d1       Descargas  Documentos  Escritorio  fichero.txt  Imágenes  Música  Plantillas
Público  Vídeos

usuario@debian:~$ ls --format=single-column
d1
Descargas
Documentos
...
```

**5. Ordenación numérica natural (Version):** El uso de `-v` junto con `-1` garantiza que los nombres que terminan en números (como `file1`, `file2`, `file10`) se listen correctamente de forma numérica y no en el estricto orden alfabético del diccionario.

```bash
si@si-VirtualBox:~$ ls -1
Desktop
Documents
...
si@si-VirtualBox:~$ ls -1 -v
Desktop
Documents
...
```

---

## Comandos lspci, lsusb y lsmod (Hardware e interfaces)

Los comandos `lspci`, `lsusb` y `lsmod` actúan como interfaces para leer e interpretar la información del hardware y dispositivos almacenada internamente por el sistema operativo.

Este tipo de información de bajo nivel se encuentra documentada y guardada en archivos especiales virtuales dentro de los directorios `/proc` y `/sys`. Estos directorios actúan como puntos de montaje para pseudo-sistemas de archivos que no existen en el disco duro, sino que residen exclusivamente en el espacio de la memoria RAM utilizado por el núcleo del sistema operativo. Allí se exponen configuraciones del hardware en tiempo de ejecución y parámetros de red.

---

## Comando lspci

El comando `lspci` (*List PCI*) muestra información detallada sobre los buses PCI (*Peripheral Component Interconnect*) y los dispositivos conectados a ellos en el sistema. Esto abarca un gran número de componentes internos fundamentales, como tarjetas de red, controladoras de vídeo (gráficas), puertos USB base, controladores SATA/IDE, y tarjetas de sonido.

```bash
usuario@debian:~$ lspci
00:00.0 Host bridge: Intel Corporation 440FX - 82441FX PMC [Natoma] (rev 02)
00:01.0 ISA bridge: Intel Corporation 82371SB PIIX3 ISA [Natoma/Triton II]
00:01.1 IDE interface: Intel Corporation 82371AB/EB/MB PIIX4 IDE (rev 01)
00:02.0 VGA compatible controller: VMware SVGA II Adapter
00:03.0 Ethernet controller: Intel Corporation 82540EM Gigabit Ethernet Controller (rev 02)
00:04.0 System peripheral: InnoTek Systemberatung GmbH VirtualBox Guest Service
00:05.0 Multimedia audio controller: Intel Corporation 82801AA AC'97 Audio Controller (rev 01)
...
```

### Opciones más usadas de `lspci`

| Parámetro | Descripción |
|-----------|-------------|
| `-v`      | (*Verbose*) Muestra información técnica detallada sobre cada dispositivo PCI, incluyendo direcciones de memoria asignadas, *flags*, e interrupciones (IRQs). |
| `-s [bus]`| (*Select*) Filtra la salida para imprimir únicamente el dispositivo PCI que coincide con la dirección o el slot especificado en formato hexadecimal. |
| `-k`      | (*Kernel*) Añade al listado qué controladores o módulos del kernel están manejando actualmente el dispositivo. Útil para debugear fallos de *drivers*. |

Ejemplo del uso de `-v` (Verbose):

```bash
usuario@debian:~$ lspci -v
00:00.0 Host bridge: Intel Corporation 440FX - 82441FX PMC [Natoma] (rev 02)
        Flags: fast devsel

00:01.0 ISA bridge: Intel Corporation 82371SB PIIX3 ISA [Natoma/Triton II]
        Flags: bus master, medium devsel, latency 0
...
```

Ejemplo del uso de `-s` (Select), filtrando por un componente específico usando su identificador `00:03.0`:

```bash
usuario@debian:~$ lspci -s 00:03.0
00:03.0 Ethernet controller: Intel Corporation 82540EM Gigabit Ethernet Controller (rev 02)

usuario@debian:~$ lspci -s 00:03.0 -v
00:03.0 Ethernet controller: Intel Corporation 82540EM Gigabit Ethernet Controller (rev 02)
        Subsystem: Intel Corporation PRO/1000 MT Desktop Adapter
        Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 19
        Memory at f0200000 (32-bit, non-prefetchable) [size=128K]
...
```

Ejemplo del uso de `-k` (Kernel) para averiguar qué controlador de sistema mueve el componente anterior:

```bash
usuario@debian:~$ lspci -s 00:03.0 -k
00:03.0 Ethernet controller: Intel Corporation 82540EM Gigabit Ethernet Controller (rev 02)
        Subsystem: Intel Corporation PRO/1000 MT Desktop Adapter
        Kernel driver in use: e1000
        Kernel modules: e1000
```

> **Recuerda:** Existe una diferencia fundamental entre **Kernel Driver** y **Kernel Module**:
> - **Kernel driver:** Es el concepto abstracto del código o software que se encarga de hablar y controlar una pieza de hardware en específico.
> - **Kernel module:** Es el fragmento de código empaquetado (el archivo físico) que implementa dicho *driver* y que tiene la capacidad de insertarse o retirarse de la memoria del núcleo "en caliente", sin necesidad de reiniciar el sistema.

---

## Comando lsusb

El comando `lsusb` muestra información sobre los buses USB (*Universal Serial Bus*) de la placa base y todos los dispositivos físicos actualmente conectados a ellos. Permite identificar memorias pendrive, impresoras, webcams, ratones y teclados que estén siendo reconocidos.

```bash
usuario@debian:~$ lsusb
Bus 002 Device 003: ID 090c:1000 Silicon Motion, Inc. - Taiwan (formerly Feiya Technology Corp.) Flash Drive
Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 002: ID 80ee:0021 VirtualBox USB Tablet
Bus 001 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
```

### Opciones más usadas de `lsusb`

| Parámetro | Descripción |
|-----------|-------------|
| `-v`      | (*Verbose*) Imprime volcados inmensos de información descriptiva sobre cada puerto y dispositivo USB, detallando el consumo de energía, velocidades y clases de dispositivos soportadas. |
| `-s [B:D]`| (*Select*) Filtra para ver exclusivamente el hardware alojado en el bus (`Bus`) y número de dispositivo (`Device`) concretos. |
| `-t`      | (*Tree*) Pinta un diagrama en formato de árbol jerárquico que permite observar gráficamente a qué controladores o *hubs* USB internos están enganchados los periféricos. |

Ejemplo del uso de `-v` (Verbose):

```bash
usuario@debian:~$ lsusb -v

Bus 002 Device 003: ID 090c:1000 Silicon Motion, Inc. - Taiwan (formerly Feiya Technology Corp.) Flash Drive
Couldn't open device, some information will be missing
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               2.00
  bDeviceClass            0
...
```

Ejemplo del uso de `-s` (Select), donde `002:003` son los identificadores de bus y dispositivo:

```bash
usuario@debian:~$ lsusb -v -s 002:003

Bus 002 Device 003: ID 090c:1000 Silicon Motion, Inc. - Taiwan (formerly Feiya Technology Corp.) Flash Drive
Couldn't open device, some information will be missing
...
```

Ejemplo del uso de `-t` (Tree), ilustrando las velocidades máximas de conexión (`12M` para USB 1.1, `480M` para USB 2.0):

```bash
usuario@debian:~$ lsusb -t
/:  Bus 02.Port 1: Dev 1, Class=root_hub, Driver=ehci-pci/12p, 480M
    |__ Port 1: Dev 3, If 0, Class=Mass Storage, Driver=usb-storage, 480M
/:  Bus 01.Port 1: Dev 1, Class=root_hub, Driver=ohci-pci/12p, 12M
    |__ Port 1: Dev 2, If 0, Class=Human Interface Device, Driver=usbhid, 12M
```

---

## Comando lsmod y gestión de módulos del kernel

Esta familia de herramientas está enfocada exclusivamente en interactuar con los **módulos del kernel**. 

Los módulos tienen un papel primordial en Linux, ya que la arquitectura permite que muchas funciones complejas y soporte para hardware nuevo se gestionen dinámicamente como módulos. Si el kernel activo no dispone de un módulo necesario cargado (por ejemplo, el módulo que permite leer sistemas de ficheros NTFS o manejar adaptadores Wi-Fi específicos), esas funciones simplemente no estarán operativas para el sistema.

Los módulos son archivos binarios precompilados que terminan en la extensión `.ko` (*Kernel Object*) y que se inyectan en la memoria RAM en función de las necesidades del hardware detectado. Existen módulos base monolíticos que siempre permanecen empotrados en el núcleo, y otros flotantes que se almacenan tradicionalmente en el disco en la ubicación: `/lib/modules/<versión_del_kernel>/`.

```bash
root@debian:~# lsmod | grep floppy
root@debian:~# find / -name floppy.ko 2> /dev/null
/usr/lib/modules/6.8.0-49-generic/kernel/drivers/block/floppy.ko
/usr/lib/modules/6.8.0-40-generic/kernel/drivers/block/floppy.ko
root@debian:~# uname -r
6.8.0-49-generic
```

### Herramientas básicas de gestión de módulos

| Comando | Descripción de uso |
|---------|--------------------|
| `lsmod` | Muestra una lista limpia de todos los módulos actualmente inyectados y activos en la memoria del núcleo, indicando su tamaño y si están siendo utilizados por otros. |
| `modinfo [modulo]` | Proporciona amplia información extraída del interior del propio fichero `.ko` (autor, licencia, descripciones, alias). |
| `insmod [ruta]` | (*Insert module*) Carga un fichero `.ko` crudo pasándole su ruta absoluta en el sistema. **No** resuelve ni carga dependencias automáticamente. |
| `rmmod [modulo]`| (*Remove module*) Expulsa o quita un módulo actualmente cargado en memoria, liberando recursos. |

El comando `rmmod` acepta además ciertos parámetros para afinar su comportamiento:
- `-w` (*wait*): Espera pacientemente a que el módulo deje de estar en uso antes de desmontarlo.
- `-f` (*force*): Fuerza agresivamente el borrado de la memoria (puede causar inestabilidad si el sistema lo está usando).

A continuación, a modo de ejemplo, listaremos y trataremos de eliminar temporalmente el módulo `psmouse` (responsable del funcionamiento básico de ratones PS/2 o táctiles), asumiendo que no es crítico para nuestro servidor sin interfaz gráfica.

```bash
root@debian:~# lsmod | grep psmouse
psmouse               217088  0
root@debian:~# rmmod psmouse
root@debian:~# lsmod | grep psmouse
```

Tras confirmar que el módulo se ha desvanecido, tratamos de cargarlo nuevamente utilizando la herramienta básica `insmod` apuntando a la ruta física descubierta:

```bash
root@debian:~# uname -r
6.8.0-49-generic
root@debian:~# cd /lib/modules/6.8.0-49-generic/
root@debian:/lib/modules/6.8.0-49-generic# find -name psmouse.ko
./kernel/drivers/input/mouse/psmouse.ko
root@debian:/lib/modules/6.8.0-49-generic# insmod $(find -name psmouse.ko) && lsmod | grep psmouse
psmouse               217088  0
```

> **Advertencia:** El comando `insmod` es rústico. En caso de que el módulo requiera la ayuda o dependencias de otros módulos previos para funcionar, el comando arrojará un error silencioso o fallará, obligándonos a insertar manualmente las dependencias en orden.

### La herramienta avanzada modprobe

Para evitar el tedio de localizar rutas y esquivar la resolución manual de dependencias complejas, surge el comando inteligente **`modprobe`**. Esta herramienta actúa como un orquestador: carga o retira módulos automáticamente leyendo unas tablas maestras de dependencias (generadas por `depmod`). 

| Parámetro | Descripción de uso |
|-----------|--------------------|
| `-f`      | Fuerza la carga del módulo saltándose las comprobaciones, incluso si la etiqueta de versión no coincide plenamente con la del kernel en ejecución. |
| `-r`      | Elimina u expulsa el módulo de manera recursiva (también intentará quitar módulos inactivos que ya no son requeridos tras esta extracción). |
| `-v`      | (*Verbose*) Muestra la traza exacta de directorios y acciones internas que ejecuta el orquestador por debajo. |
| `-n`      | (*Dry-run*) Realiza una simulación visual para predecir lo que va a ocurrir, pero sin inyectar ni alterar el sistema en realidad. |

Si repetimos el ejemplo anterior de borrar y cargar el módulo `psmouse` valiéndonos ahora de `modprobe`:

```bash
root@debian:~# modprobe -r psmouse
root@debian:~# lsmod | grep psmouse
root@debian:~# modprobe psmouse
root@debian:~# lsmod | grep psmouse
psmouse               217088  0
```

En este caso `psmouse` no requiere dependencias secundarias, pero de haber sido así, `modprobe` habría ido a la carpeta `/lib/modules/` para ir activándolas e inyectándolas en cascada antes que a él.

---

## Comando dmesg

Para diagnosticar el éxito de la carga de los módulos, o para visualizar reportes internos del hardware de bajo nivel, existe el comando **`dmesg`** (*Diagnostic Messages*). Esta instrucción lee y vuelca por pantalla los eventos atrapados temporalmente en el búfer anular de los mensajes de arranque y estado del núcleo (*kernel ring buffer*).

| Sintaxis | Descripción |
|----------|-------------|
| `dmesg`  | Despliega el volcado masivo y bruto de todos los mensajes registrados desde el encendido hasta el momento actual. |
| `dmesg --level=err` | Filtra el búfer para mostrar exclusivamente aquellos mensajes catalogados con severidad de error crítico (problemas hardware o de módulos insalvables). |
| `dmesg -T` | Introduce una pequeña transformación que nos muestra el sello de tiempo crudo del kernel traducido a una fecha y hora estándar (legible para humanos). |
