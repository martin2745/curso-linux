# Comando du

El comando `du`, que significa "disk usage" (uso de disco), se utiliza para estimar el espacio utilizado por archivos y directorios en el sistema de archivos.

- **Uso básico**: La forma más básica de utilizar `du` es simplemente invocarlo con el nombre de un directorio:

```bash
du directorio
```

Esto mostrará el espacio utilizado por ese directorio y sus subdirectorios. Por ejemplo:

```bash
du /home/usuario
```

Esto mostrará el espacio utilizado por el directorio `/home/usuario` y sus subdirectorios.

- **Opciones adicionales**: `du` puede tomar varias opciones para personalizar su salida. Por ejemplo, `-h` (human-readable) muestra los tamaños de una manera más legible para los humanos, mientras que `-a` muestra el tamaño de cada archivo en un directorio:

```bash
si@si-VirtualBox:/tmp$ du -h prueba/
64K prueba/

si@si-VirtualBox:/tmp$ du -ah prueba/
4,0K prueba/fichero1.txt
4,0K prueba/fichero9.txt
4,0K prueba/fichero13.txt
4,0K prueba/fichero6.txt
4,0K prueba/fichero4.txt
4,0K prueba/fichero10.txt
4,0K prueba/fichero2.txt
4,0K prueba/fichero7.txt
4,0K prueba/fichero8.txt
4,0K prueba/fichero11.txt
4,0K prueba/fichero15.txt
4,0K prueba/fichero12.txt
4,0K prueba/fichero3.txt
4,0K prueba/fichero14.txt
4,0K prueba/fichero5.txt
64K prueba/
```
