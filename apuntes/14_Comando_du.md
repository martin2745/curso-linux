# Comando du

## Índice

1. [Opciones comunes](#1-opciones-comunes)
2. [Ejemplos de uso](#2-ejemplos-de-uso)

---

El comando `du` (_disk usage_) en sistemas Unix/Linux se utiliza para estimar y mostrar el espacio que ocupa un archivo o directorio en el sistema de archivos.

> **Recuerda:** A diferencia de `df` (que calcula el total del disco), `du` analiza recursivamente los directorios para calcular exactamente cuánto pesa el contenido de carpetas y subcarpetas.

---

## 1. Opciones comunes

| Parámetro | Descripción |
|-----------|-------------|
| `-h`      | Muestra los tamaños en un formato legible para humanos, utilizando unidades como KB, MB o GB. |
| `-s`      | Muestra solo el total ocupado por el archivo o directorio especificado, en lugar de listar el tamaño de cada subdirectorio de forma recursiva. |

---

## 2. Ejemplos de uso

Para mostrar el tamaño de archivos y de un directorio completo (listando por defecto todos sus subdirectorios en bloques de memoria):

```bash
usuario@debian:~# du /tmp
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
usuario@debian:~# du -h /tmp
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
usuario@debian:~# du -sh /tmp
48K     /tmp
```

> **Nota:** La combinación `du -sh *` ejecutada dentro de un directorio es una forma excelente de ver rápidamente cuánto espacio ocupa cada archivo o carpeta directamente contenida en él.
