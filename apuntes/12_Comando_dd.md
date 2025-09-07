# Comando dd

El comando `dd` se utiliza principalmente para copiar y convertir archivos de datos, con opciones muy flexibles para manejar bloques de datos. El comando `dd` (device to device) tiene como misión la copia física, bloque por bloque, de un archivo periférico hacia un archivo periférico. Al principio se utilizaba para la lectura y escritura en cinta magnética, pero se puede utilizar también con cualquier archivo. `dd` viene de data duplicator pero, humorísticamente, también se le conoce como disk destroyer o data destroyer por ser una herramienta muy poderosa.

- **Uso básico**: El formato básico del comando `dd` es:

```bash
dd if=archivo_de_entrada of=archivo_de_salida
```

Esto copia el contenido del archivo de entrada (`if` significa "input file") al archivo de salida (`of` significa "output file"). Por ejemplo:

```bash
dd if=/dev/sda of=copia_de_seguridad.img
```

Esto copiaría todo el contenido del disco `/dev/sda` en el archivo `copia_de_seguridad.img`.

- **Parámetros adicionales**: `dd` puede aceptar una serie de parámetros para personalizar su comportamiento, como el tamaño del bloque, el desplazamiento, etc. Por ejemplo:

```bash
dd if=archivo_de_entrada of=archivo_de_salida bs=tamaño_del_bloque count=número_de_bloques
```

Aquí, `bs` es el tamaño del bloque (block size) y `count` es el número de bloques. Esto puede ser útil cuando se quiere ajustar el rendimiento de la copia o la conversión.

Un comando peligroso en un sistema MBR es ejecutar el comando:

```bash
dd if=/dev/zero of=/dev/sda bs=512 count=1
```

A continuación definimos cual es la consecuencia de este comando en el proceso de arranque pero antes veamos resumidamente el proceso de arranque del sistema:

## Proceso de Arranque en MBR

1. **Encendido del Sistema y Ejecución del BIOS**:

   - Al encender el sistema, el BIOS (Basic Input/Output System) se inicia y realiza una serie de pruebas de hardware conocidas como POST (Power-On Self Test).
   - Una vez completadas las pruebas, el BIOS busca un dispositivo de arranque (como un disco duro) y lee el primer sector del dispositivo, conocido como el Master Boot Record (MBR).

2. **Código de Arranque en el MBR**:

   - El MBR es el primer sector del disco (512 bytes) y contiene:
     - **Código de Arranque o Boot Code** (los primeros 446 bytes): Este es un pequeño programa que se ejecuta inmediatamente después de que el BIOS carga el MBR en la memoria.
     - **Tabla de Particiones** (64 bytes): Describe la estructura de las particiones del disco.
     - **Firma de Arranque** (2 bytes): Un valor fijo (0x55AA) que indica un MBR válido.
   - El **Código de Arranque** del MBR tiene la tarea de localizar la partición activa (una de las particiones primarias marcadas como activa en la tabla de particiones), por lo que es el encargado de iniciar el proceso de arranque.

3. **Gestor de Arranque Secundario**:

   - El código de arranque en el MBR carga y ejecuta el gestor de arranque secundario desde el sector de arranque de la partición activa.
   - Ejemplos de gestores de arranque secundarios son GRUB o GRUB2, LILO en sistemas Linux, o BOOTMGR en sistemas Windows.
   - El **Gestor de Arranque Secundario** presenta un menú al usuario para seleccionar entre múltiples sistemas operativos o diferentes modos de arranque.

4. **Cargador de Arranque**:
   - El gestor de arranque secundario carga el **Cargador de Arranque** del sistema operativo seleccionado.
   - Este es el programa específico del sistema operativo que finalmente carga el núcleo (kernel) del sistema operativo en la memoria y transfiere el control al núcleo para completar el proceso de arranque.

### Comando `dd if=/dev/zero of=/dev/sda bs=512 count=1`

Cuando ejecutas el comando `dd if=/dev/zero of=/dev/sda bs=512 count=1`, sucede lo siguiente:

1. **`dd`**: Es una herramienta de copia de datos en Unix y Linux.
2. **`if=/dev/zero`**: Indica que el archivo de entrada será `/dev/zero`, un dispositivo especial que genera un flujo continuo de ceros.
3. **`of=/dev/sda`**: Indica que el archivo de salida será `/dev/sda`, que representa el disco duro completo.
4. **`bs=512`**: Establece el tamaño del bloque en 512 bytes.
5. **`count=1`**: Especifica que se copiará un solo bloque de 512 bytes.

### Efecto del Comando

- Este comando escribe 512 bytes de ceros en el primer sector del disco duro (`/dev/sda`), que es el MBR.
- **Sobrescribir el MBR**:
  - El código de arranque en el MBR será sobrescrito con ceros.
  - La tabla de particiones también será sobrescrita, eliminando la información sobre las particiones del disco.
  - La firma de arranque (0x55AA) será eliminada, lo que indica al BIOS que el MBR no es un sector de arranque válido.

### Consecuencias

1. **Sistema No Arrancable**: Sin un código de arranque válido en el MBR, el BIOS no podrá iniciar el proceso de arranque desde el disco.
2. **Pérdida de Información de Particiones**: La tabla de particiones se perderá, haciendo que todas las particiones del disco sean inaccesibles mediante métodos normales.
3. **Recuperación**: Para recuperar el sistema, necesitarías restaurar un MBR válido y posiblemente la tabla de particiones, lo que puede requerir software de recuperación especializado y una copia de seguridad previa de la tabla de particiones.

Este comando debe usarse con extrema precaución, ya que puede causar una pérdida de datos significativa y dejar el sistema en un estado no arrancable.
