# Comando du

El comando `du` (disk usage) en sistemas Unix/Linux se utiliza para estimar y mostrar el espacio que ocupa un archivo o directorio en el sistema de archivos. 

**Opciones comunes**:

- `-h` (human-readable): Muestra los tamaños en un formato legible para humanos, utilizando unidades como KB, MB o GB.
- `-s` (summarize): Muestra solo el total ocupado por el archivo o directorio especificado, en lugar de listar el tamaño de cada subdirectorio.

**Ejemplos de uso**:

- `du -h fichero`: Muestra el tamaño de un archivo en formato legible para humanos.
- `du -hs /directorio`: Muestra el tamaño total de un directorio (de forma resumida) en formato legible para humanos.

**Resumen de las opciones utilizadas**:

| Opción     | Descripción                                                                 |
|------------|-----------------------------------------------------------------------------|
| `-h`       | Formato legible para humanos (KB, MB, GB)                                   |
| `-s`       | Muestra solo el total ocupado por el archivo/directorio especificado        |

```bash
root@debian:~# du /tmp
4       /tmp/systemd-private-61a29f4aa9e843908366c93c8306538e-apache2.service-cvrOY8/tmp
8       /tmp/systemd-private-61a29f4aa9e843908366c93c8306538e-apache2.service-cvrOY8
4       /tmp/.ICE-unix
4       /tmp/systemd-private-61a29f4aa9e843908366c93c8306538e-systemd-logind.service-Bvohlw/tmp
8       /tmp/systemd-private-61a29f4aa9e843908366c93c8306538e-systemd-logind.service-Bvohlw
root@debian:~# du /tmp
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

```bash
root@debian:~# du -h /tmp
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

```bash
root@debian:~# du -hs /tmp
48K     /tmp
```