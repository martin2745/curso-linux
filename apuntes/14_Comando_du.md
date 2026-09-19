# Comando du

## Índice

1. [Opciones comunes](#1-opciones-comunes)
2. [Ejemplos de uso](#2-ejemplos-de-uso)
3. [Localizar qué está llenando el disco](#3-localizar-qué-está-llenando-el-disco)

---

## 1. Opciones comunes

| Parámetro | Descripción |
|-----------|-------------|
| `-h`      | Muestra los tamaños en un formato legible para humanos, utilizando unidades como KB, MB o GB. |
| `-s`      | (*Summarize*) Muestra solo el total ocupado por el archivo o directorio especificado, en lugar de listar el tamaño de cada subdirectorio de forma recursiva. |
| `-a`      | (*All*) Incluye también los ficheros, no solo los directorios. |
| `-c`      | (*Total*) Añade una línea final con la suma de todo lo listado. |
| `-d N`    | (*Max-depth*) Limita el listado a `N` niveles de profundidad. `du -h -d 1` es el término medio entre el detalle abrumador de `du` y el dato único de `du -s`. |
| `-x`      | No cruza a otros sistemas de ficheros. Evita que un `du /` se ponga a recorrer los discos de red o las particiones montadas. |
| `--apparent-size` | Muestra el tamaño real del contenido en lugar del espacio que ocupa en disco. |
| `--exclude=PATRÓN` | Omite las rutas que coincidan con el patrón, por ejemplo `--exclude='*.iso'`. |
| `-t TAM` | (*Threshold*) Omite las entradas que no alcancen el tamaño indicado, como `du -h -t 100M`. |

> **Importante:** `du` no informa del tamaño de los ficheros, sino del **espacio que ocupan en el disco**, y esas dos magnitudes rara vez coinciden. El sistema de ficheros asigna el espacio en bloques completos, normalmente de 4 KB, de modo que un fichero de 10 bytes consume igualmente un bloque entero. Es lo que explica que en la salida siguiente todos los directorios vacíos aparezcan como `4,0K`.
>
> ```bash
> usuario@debian:~$ echo "hola" > /tmp/minusculo.txt
> usuario@debian:~$ du -h /tmp/minusculo.txt
> 4,0K    /tmp/minusculo.txt
> usuario@debian:~$ du -h --apparent-size /tmp/minusculo.txt
> 5       /tmp/minusculo.txt
> usuario@debian:~$ ls -l /tmp/minusculo.txt
> -rw-r--r-- 1 usuario usuario 5 sep 18 10:31 /tmp/minusculo.txt
> ```
>
> El fichero mide 5 bytes, pero ocupa 4 KB. En un directorio con miles de ficheros pequeños, la diferencia entre ambas cifras llega a ser enorme.

> **Nota:** `du` cuenta una sola vez los ficheros que comparten inodo mediante enlaces duros, de modo que el total no se infla al recorrer un árbol que los contenga. En cambio, los ficheros dispersos (*sparse files*), como las imágenes de disco de las máquinas virtuales, aparecen con el espacio que realmente consumen, que puede ser mucho menor que su tamaño declarado.

---

## 2. Ejemplos de uso

Para mostrar el tamaño de archivos y de un directorio completo (listando por defecto todos sus subdirectorios en bloques de memoria):

```bash
usuario@debian:~$ du /tmp
4       /tmp/systemd-private-61a29f4aa9e843908366c93c8306538e-apache2.service-cvrOY8/tmp
8       /tmp/systemd-private-61a29f4aa9e843908366c93c8306538e-apache2.service-cvrOY8
4       /tmp/.ICE-unix
4       /tmp/systemd-private-61a29f4aa9e843908366c93c8306538e-systemd-logind.service-Bvohlw/tmp
8       /tmp/systemd-private-61a29f4aa9e843908366c93c8306538e-systemd-logind.service-Bvohlw
4       /tmp/systemd-private-61a29f4aa9e843908366c93c8306538e-chrony.service-eqmIPM/tmp
8       /tmp/systemd-private-61a29f4aa9e843908366c93c8306538e-chrony.service-eqmIPM
4       /tmp/.font-unix
4       /tmp/.XIM-unix
4       /tmp/.X11-unix
48      /tmp
```

Añadiendo el flag `-h` para que el tamaño sea legible (en KB, MB, etc.):

```bash
usuario@debian:~$ du -h /tmp
4,0K    /tmp/systemd-private-61a29f4aa9e843908366c93c8306538e-apache2.service-cvrOY8/tmp
8,0K    /tmp/systemd-private-61a29f4aa9e843908366c93c8306538e-apache2.service-cvrOY8
4,0K    /tmp/.ICE-unix
4,0K    /tmp/systemd-private-61a29f4aa9e843908366c93c8306538e-systemd-logind.service-Bvohlw/tmp
8,0K    /tmp/systemd-private-61a29f4aa9e843908366c93c8306538e-systemd-logind.service-Bvohlw
4,0K    /tmp/systemd-private-61a29f4aa9e843908366c93c8306538e-chrony.service-eqmIPM/tmp
8,0K    /tmp/systemd-private-61a29f4aa9e843908366c93c8306538e-chrony.service-eqmIPM
4,0K    /tmp/.font-unix
4,0K    /tmp/.XIM-unix
4,0K    /tmp/.X11-unix
48K     /tmp
```

Usando la combinación `-sh` para suprimir la salida de los subdirectorios y mostrar **solo el peso total** del directorio indicado:

```bash
usuario@debian:~$ du -sh /tmp
48K     /tmp
```

> **Nota:** La combinación `du -sh *` ejecutada dentro de un directorio es una forma excelente de ver rápidamente cuánto espacio ocupa cada archivo o carpeta directamente contenida en él.

---

## 3. Localizar qué está llenando el disco

El uso real de `du` en administración de sistemas consiste en responder a la pregunta "se ha llenado el disco, ¿dónde está el problema?". La respuesta pasa siempre por ordenar la salida, y para eso hace falta `sort -h`, que sabe interpretar los sufijos `K`, `M` y `G`:

```bash
usuario@debian:~$ du -sh * | sort -h
4,0K    Escritorio
4,0K    Plantillas
16K     Documentos
1,2M    Imágenes
340M    Descargas
```

> **Advertencia:** `du -sh *` no incluye los ficheros y directorios ocultos, porque el comodín `*` no los expande. Para no dejarse nada conviene usar `du -sh .[!.]* *` o, más cómodo, `du -h -d 1 .`, que sí los tiene en cuenta.

La estrategia habitual consiste en descender nivel a nivel desde la raíz, siguiendo siempre la rama más pesada:

```bash
root@debian:~# du -h -d 1 -x / | sort -h | tail -5
1,1G    /usr
2,3G    /home
4,8G    /var
8,9G    /
root@debian:~# du -h -d 1 -x /var | sort -h | tail -3
412M    /var/cache
3,9G    /var/log
4,8G    /var
```

En dos comandos hemos pasado de "el disco está lleno" a "el problema está en `/var/log`".

> **Recuerda:** La opción `-x` es importante al analizar `/`. Sin ella, `du` se adentra en `/proc`, `/sys`, `/run` y en cualquier unidad de red montada, lo que hace el recorrido lentísimo y falsea el total.

Para localizar directamente los ficheros individuales más grandes, `find` suele ser mejor herramienta que `du`:

```bash
root@debian:~# find /var -type f -size +100M -exec du -h {} + | sort -h
```

> **Nota:** Existen herramientas interactivas que automatizan este recorrido y resultan mucho más cómodas en una sesión de diagnóstico. La más extendida es `ncdu` (*NCurses Disk Usage*), que se instala con `apt install ncdu` y permite navegar por el árbol con las flechas viendo los tamaños ordenados.
