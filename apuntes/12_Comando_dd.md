# Comando dd

## Índice

1. [Uso básico y parámetros](#1-uso-básico-y-parámetros)
2. [Usos habituales de dd](#2-usos-habituales-de-dd)
3. [Proceso de arranque en MBR](#3-proceso-de-arranque-en-mbr)
4. [Comando dd destructivo (ejemplo)](#4-comando-dd-destructivo-ejemplo)
   1. [Efecto del comando](#41-efecto-del-comando)
   2. [Consecuencias](#42-consecuencias)

---

## 1. Uso básico y parámetros

El formato básico del comando `dd` es:

```bash
dd if=archivo_de_entrada of=archivo_de_salida
```

Esto copia el contenido del archivo de entrada (`if` significa "input file") al archivo de salida (`of` significa "output file"). Por ejemplo:

```bash
dd if=/dev/sda of=copia_de_seguridad.img
```

Esto copiaría todo el contenido del disco físico `/dev/sda` en el archivo `copia_de_seguridad.img`.

`dd` puede aceptar una serie de parámetros para personalizar su comportamiento, como el tamaño del bloque, el desplazamiento, etc. Por ejemplo:

```bash
dd if=archivo_de_entrada of=archivo_de_salida bs=tamaño_del_bloque count=número_de_bloques
```

Aquí, `bs` es el tamaño del bloque (_block size_) y `count` es el número de bloques. Esto puede ser útil cuando se quiere ajustar el rendimiento de la copia o la conversión.

| Parámetro | Descripción |
|-----------|-------------|
| `if=`     | Especifica el archivo o dispositivo de entrada (Input File). |
| `of=`     | Especifica el archivo o dispositivo de salida (Output File). |
| `bs=`     | Establece el tamaño del bloque de bytes a leer/escribir de una vez. |
| `count=`  | Indica el número total de bloques a copiar. |
| `skip=N`  | Salta los `N` primeros bloques **del origen** antes de empezar a leer. |
| `seek=N`  | Salta los `N` primeros bloques **del destino** antes de empezar a escribir, de modo que no se tocan. |
| `status=progress` | Muestra el avance de la copia en tiempo real. Sin esta opción, `dd` permanece en silencio hasta terminar, lo que en un disco grande hace pensar que se ha colgado. |
| `conv=notrunc` | No trunca el fichero de salida. Imprescindible al sobrescribir una parte de un fichero o dispositivo ya existente. |
| `conv=noerror` | Continúa la copia aunque se produzcan errores de lectura. Se usa al rescatar datos de un soporte deteriorado. |
| `conv=sync`   | Rellena con ceros los bloques leídos de forma incompleta, de manera que la copia conserve las posiciones originales. Suele combinarse como `conv=noerror,sync`. |

> **Nota:** El valor de `bs=` admite sufijos (`bs=1M`, `bs=512K`, `bs=4096`) y afecta mucho al rendimiento. Un bloque demasiado pequeño multiplica el número de operaciones de entrada y salida; uno razonable para copiar discos completos suele estar entre `1M` y `4M`.

> **Advertencia:** Para recuperar datos de discos con sectores defectuosos existen `ddrescue` y `dd_rescue`, que llevan registro de los bloques ya rescatados y pueden reanudar el trabajo. Son preferibles a `dd conv=noerror,sync` en cualquier escenario real de recuperación.

---

## 2. Usos habituales de dd

Antes de llegar al ejemplo destructivo conviene ver para qué se utiliza `dd` en el trabajo diario.

**Copia de seguridad del MBR.** Los 512 primeros bytes del disco caben en un fichero minúsculo, así que guardarlos antes de tocar el particionado cuesta un segundo:

```bash
root@debian:~# dd if=/dev/sda of=/root/mbr-sda.img bs=512 count=1
1+0 registros leídos
1+0 registros escritos
512 bytes copiados, 0,000271 s, 1,9 MB/s
```

Y su restauración, en caso de desastre, desde un sistema arrancado en modo rescate:

```bash
root@debian:~# dd if=/root/mbr-sda.img of=/dev/sda bs=512 count=1
```

> **Recuerda:** Si solo se quiere recuperar el código de arranque **sin** tocar la tabla de particiones actual, hay que restaurar únicamente los primeros 446 bytes: `dd if=/root/mbr-sda.img of=/dev/sda bs=446 count=1`. Restaurar los 512 completos devolvería también la tabla de particiones antigua, lo que destruiría cualquier cambio de particionado posterior a la copia.

**Creación de un fichero de intercambio.** Reserva el espacio escribiendo ceros:

```bash
root@debian:~# dd if=/dev/zero of=/swapfile bs=1M count=1024 status=progress
root@debian:~# chmod 600 /swapfile
root@debian:~# mkswap /swapfile
root@debian:~# swapon /swapfile
```

**Escritura de una imagen ISO en una memoria USB.** Aquí el destino es el dispositivo completo, no una partición:

```bash
root@debian:~# dd if=debian-13.iso of=/dev/sdb bs=4M status=progress conv=fsync
```

> **Advertencia:** Es imprescindible comprobar con `lsblk` que `/dev/sdb` es realmente la memoria USB y no un disco del sistema. Confundir `sdb` con `sda` en esta orden destruye el disco duro por completo, y no existe deshacer.

**Medición de la velocidad de escritura del disco:**

```bash
root@debian:~# dd if=/dev/zero of=/tmp/prueba bs=1M count=1024 oflag=direct
1024+0 registros escritos
1073741824 bytes (1,1 GB) copiados, 3,2541 s, 330 MB/s
```

> **Nota:** Mientras `dd` está copiando se le puede pedir un informe de progreso sin interrumpirlo, enviándole la señal `USR1` desde otra terminal: `kill -USR1 $(pgrep -x dd)`. Es la alternativa a `status=progress` en sistemas antiguos.

---

## 3. Proceso de arranque en MBR

Antes de ver un comando peligroso en un sistema MBR (*Master Boot Record*), conviene repasar de forma resumida cómo es el proceso de arranque. El tema se trata con más detalle en el documento 36, y los esquemas de particionado MBR y GPT en el documento 37.

1. **Encendido del Sistema y Ejecución del BIOS**:
   - Al encender el sistema, el BIOS (_Basic Input/Output System_) se inicia y realiza una serie de pruebas de hardware conocidas como POST (_Power-On Self Test_).
   - Una vez completadas las pruebas, el BIOS busca un dispositivo de arranque (como un disco duro) y lee el primer sector del dispositivo, conocido como el Master Boot Record (MBR).

2. **Código de Arranque en el MBR**:
   - El MBR es el primer sector del disco (512 bytes) y contiene:
     - **Código de Arranque o Boot Code** (los primeros 446 bytes): Este es un pequeño programa que se ejecuta inmediatamente después de que el BIOS carga el MBR en la memoria.
     - **Tabla de Particiones** (64 bytes): Describe la estructura de las particiones del disco.
     - **Firma de Arranque** (2 bytes): Un valor fijo (`0x55AA`) que indica un MBR válido.
   - El **Código de Arranque** del MBR tiene la tarea de localizar la partición activa (una de las particiones primarias marcadas como activa en la tabla de particiones), por lo que es el encargado de iniciar el proceso de arranque.

3. **Gestor de Arranque Secundario**:
   - El código de arranque en el MBR carga y ejecuta el gestor de arranque secundario desde el sector de arranque de la partición activa.
   - Ejemplos de gestores de arranque secundarios son GRUB o GRUB2, LILO en sistemas Linux, o BOOTMGR en sistemas Windows.
   - En el caso concreto de GRUB2 sobre MBR, el código de los 446 bytes es demasiado pequeño para contener el gestor completo, de modo que se limita a cargar una segunda fase alojada en el espacio libre que queda entre el MBR y la primera partición, conocido como *MBR gap*. Por eso GRUB necesita que ese hueco exista y no dependa de marcar ninguna partición como activa.
   - El **Gestor de Arranque Secundario** presenta un menú al usuario para seleccionar entre múltiples sistemas operativos o diferentes modos de arranque.

4. **Cargador de Arranque**:
   - El gestor de arranque secundario carga el **Cargador de Arranque** del sistema operativo seleccionado.
   - Este es el programa específico del sistema operativo que finalmente carga el núcleo (`kernel`) del sistema operativo en la memoria y transfiere el control al núcleo para completar el proceso de arranque.

---

## 4. Comando dd destructivo (ejemplo)

> **Advertencia:** El siguiente comando destruirá la capacidad de arranque y la tabla de particiones de tu disco si lo ejecutas en tu sistema. Se expone con fines estrictamente educativos.

Un comando peligroso en un sistema MBR es ejecutar:

```bash
dd if=/dev/zero of=/dev/sda bs=512 count=1
```

Cuando ejecutas el comando `dd if=/dev/zero of=/dev/sda bs=512 count=1`, sucede lo siguiente:

1. **`dd`**: Es una herramienta de copia de datos en Unix y Linux.
2. **`if=/dev/zero`**: Indica que el archivo de entrada será `/dev/zero`, un dispositivo especial que genera un flujo continuo de ceros.
3. **`of=/dev/sda`**: Indica que el archivo de salida será `/dev/sda`, que representa el disco duro principal completo.
4. **`bs=512`**: Establece el tamaño del bloque en 512 bytes.
5. **`count=1`**: Especifica que se copiará un solo bloque de 512 bytes.

### 4.1 Efecto del comando

Este comando escribe 512 bytes de ceros en el primer sector del disco duro (`/dev/sda`), que es el MBR.

- **Sobrescribir el MBR**:
  - El código de arranque en el MBR será sobrescrito con ceros.
  - La tabla de particiones también será sobrescrita, eliminando la información sobre las particiones del disco.
  - La firma de arranque (`0x55AA`) será eliminada, lo que indica al BIOS que el MBR no es un sector de arranque válido.

### 4.2 Consecuencias

1. **Sistema no arrancable**: Sin un código de arranque válido en el MBR, el BIOS no podrá iniciar el proceso de arranque desde el disco.
2. **Pérdida de información de particiones**: La tabla de particiones se perderá, haciendo que todas las particiones del disco sean inaccesibles mediante métodos normales.
3. **Recuperación**: Para recuperar el sistema, necesitarías restaurar un MBR válido y posiblemente la tabla de particiones, lo que puede requerir software de recuperación especializado (como TestDisk) y una copia de seguridad previa de la tabla de particiones.

> **Importante:** Este comando debe usarse con extrema precaución. Su ejecución accidental causará una pérdida de datos significativa y dejará el sistema en un estado no arrancable.
