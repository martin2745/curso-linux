# Comando wget y curl

## Índice

1. [Comando wget](#1-comando-wget)
2. [Comando curl](#2-comando-curl)

---

## 1. Comando wget

Es una herramienta de línea de comandos que permite la descarga de archivos desde servidores remotos a través de HTTP, HTTPS y FTP. Es muy útil para descargar archivos de Internet de forma sencilla y automatizada.

### Parámetros de wget

| Parámetro | Definición |
|-----------|------------|
| `-O` | Especifica el nombre del archivo de salida. |
| `-q` | Ejecución silenciosa, sin mensajes de progreso ni verbosidad. |
| `-P` | Especifica el directorio de destino para guardar el archivo. |
| `-c` | Continúa descargas interrumpidas (resume). |
| `-r` | Descarga recursiva, sigue enlaces dentro de la página. |

### Ejemplos de wget

Descarga estándar de un archivo:

```bash
usuario@debian:/tmp/pr$ wget https://d.winrar.es/d/97z1713015469/hrYvljKNPEqbS2FjdvSpsQ/rarlinux-x64-700.tar.gz
--2024-04-13 15:36:35--  https://d.winrar.es/d/97z1713015469/hrYvljKNPEqbS2FjdvSpsQ/rarlinux-x64-700.tar.gz
Resolving d.winrar.es (d.winrar.es)... 82.98.170.158
Connecting to d.winrar.es (d.winrar.es)|82.98.170.158|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 730268 (713K) [application/octet-stream]
Saving to: ‘rarlinux-x64-700.tar.gz’

rarlinux-x64-700.tar. 100%[=======================>] 713,15K   251KB/s    in 2,8s

2024-04-13 15:36:38 (251 KB/s) - ‘rarlinux-x64-700.tar.gz’ saved [730268/730268]

usuario@debian:/tmp/pr$ ls
rarlinux-x64-700.tar.gz
```

Descarga en modo silencioso (`-q`):

```bash
usuario@debian:/tmp/pr$ wget -q https://d.winrar.es/d/97z1713015469/hrYvljKNPEqbS2FjdvSpsQ/rarlinux-x64-700.tar.gz

usuario@debian:/tmp/pr$ ls
rarlinux-x64-700.tar.gz
```

Descarga silenciosa especificando ruta y nombre de salida (`-qO`):

```bash
usuario@debian:/tmp/prueba$ wget -qO /tmp/rar.tar.gz https://d.winrar.es/d/97z1713015469/hrYvljKNPEqbS2FjdvSpsQ/rarlinux-x64-700.tar.gz
usuario@debian:/tmp/prueba$ ls /tmp/
rar.tar.gz
```

---

## 2. Comando curl

Es una herramienta de línea de comandos para transferir datos desde o hacia un servidor, utilizando uno de los protocolos compatibles, como HTTP, HTTPS, FTP, etc. Es muy versátil y admite una amplia gama de funciones avanzadas.

### Parámetros de curl

| Parámetro | Definición |
|-----------|------------|
| `-o` | Especifica el nombre y ruta del archivo de salida. |
| `-O` | Descarga y guarda el archivo utilizando su nombre original remoto. |
| `-s` | Ejecución silenciosa, oculta mensajes de progreso. |
| `-C -` | Continúa descargas interrumpidas. |
| `-L` | Sigue redirecciones HTTP (código 3XX) de forma automática. |

### Ejemplos de curl

Descarga conservando el nombre original (`-O`):

```bash
usuario@debian:/tmp/pr$ curl -O https://d.winrar.es/d/97z1713015469/hrYvljKNPEqbS2FjdvSpsQ/rarlinux-x64-700.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   169  100   169    0     0   1264      0 --:--:-- --:--:-- --:--:--  1261
```

Descarga silenciosa conservando el nombre original (`-sO`):

```bash
usuario@debian:/tmp/pr$ curl -sO https://d.winrar.es/d/97z1713015469/hrYvljKNPEqbS2FjdvSpsQ/rarlinux-x64-700.tar.gz
usuario@debian:/tmp/pr$ ls
rarlinux-x64-700.tar.gz
```

Descarga silenciosa indicando un nombre y ruta de salida específicos (`-so`):

```bash
usuario@debian:/tmp/prueba$ curl -so /tmp/rar.tar.gz https://d.winrar.es/d/97z1713015469/hrYvljKNPEqbS2FjdvSpsQ/rarlinux-x64-700.tar.gz
usuario@debian:/tmp/prueba$ ls /tmp/
rar.tar.gz
```
