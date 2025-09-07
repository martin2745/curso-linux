# Comando wget y curl

## wget

Es una herramienta de línea de comandos que permite la descarga de archivos desde servidores remotos a través de HTTP, HTTPS y FTP. Es útil para descargar archivos de Internet de forma sencilla y automatizada.

- `-O`: Especifica el nombre del archivo de salida.
- `-q`: Ejecución silenciosa, sin mensajes de progreso.
- `-P`: Especifica el directorio de destino para guardar el archivo.
- `-c`: Continuar descargas interrumpidas.
- `-r`: Descarga recursiva, sigue enlaces dentro de la página.

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

```bash
usuario@debian:/tmp/pr$ wget -q https://d.winrar.es/d/97z1713015469/hrYvljKNPEqbS2FjdvSpsQ/rarlinux-x64-700.tar.gz

usuario@debian:/tmp/pr$ ls
rarlinux-x64-700.tar.gz
```

```bash
usuario@debian:/tmp/prueba$ wget -qO /tmp/rar.tar.gz https://d.winrar.es/d/97z1713015469/hrYvljKNPEqbS2FjdvSpsQ/rarlinux-x64-700.tar.gz
usuario@debian:/tmp/prueba$ ls /tmp/
rar.tar.gz
```

## curl

Es una herramienta de línea de comandos para transferir datos desde o hacia un servidor, utilizando uno de los protocolos compatibles, como HTTP, HTTPS, FTP, etc. Es muy versátil y admite una amplia gama de funciones y protocolos.

- `-o`: Especifica el nombre del archivo de salida.
- `-s`: Ejecución silenciosa, sin mensajes de progreso.
- `-O`: Descargar y guardar usando el nombre del archivo remoto.
- `-C`: Continuar descargas interrumpidas.
- `-L`: Seguir redirecciones.

```bash
usuario@debian:/tmp/pr$ curl -O https://d.winrar.es/d/97z1713015469/hrYvljKNPEqbS2FjdvSpsQ/rarlinux-x64-700.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   169  100   169    0     0   1264      0 --:--:-- --:--:-- --:--:--  1261
usuario@debian:/tmp/pr$ curl -sO https://d.winrar.es/d/97z1713015469/hrYvljKNPEqbS2FjdvSpsQ/rarlinux-x64-700.tar.gz
usuario@debian:/tmp/pr$ ls
rarlinux-x64-700.tar.gz
```

```bash
usuario@debian:/tmp/prueba$ curl -so /tmp/rar.tar.gz https://d.winrar.es/d/97z1713015469/hrYvljKNPEqbS2FjdvSpsQ/rarlinux-x64-700.tar.gz
usuario@debian:/tmp/prueba$ ls /tmp/
rar.tar.gz
```
