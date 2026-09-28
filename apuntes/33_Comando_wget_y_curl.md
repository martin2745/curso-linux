# Comando wget y curl

## Índice

1. [Comando wget](#1-comando-wget)
   1. [Parámetros de wget](#11-parámetros-de-wget)
   2. [Ejemplos de wget](#12-ejemplos-de-wget)
2. [Comando curl](#2-comando-curl)
   1. [Parámetros de curl](#21-parámetros-de-curl)
   2. [Ejemplos de curl](#22-ejemplos-de-curl)
3. [wget frente a curl: dónde y con qué nombre se guarda](#3-wget-frente-a-curl-dónde-y-con-qué-nombre-se-guarda)

---

## 1. Comando wget

Es una herramienta de línea de comandos que permite la descarga de archivos desde servidores remotos a través de HTTP, HTTPS y FTP. Es muy útil para descargar archivos de Internet de forma sencilla y automatizada.

### 1.1 Parámetros de wget

| Parámetro | Definición |
|-----------|------------|
| `-O` | Especifica el nombre del archivo de salida. |
| `-q` | Ejecución silenciosa, sin mensajes de progreso ni verbosidad. |
| `-P` | Especifica el directorio de destino para guardar el archivo. |
| `-c` | Continúa descargas interrumpidas (resume). |
| `-r` | Descarga recursiva, sigue enlaces dentro de la página. |
| `-N` | Solo descarga si la copia remota es más reciente que la local. |
| `-b` | Ejecuta la descarga en segundo plano y registra el avance en `wget-log`. |
| `-i fichero` | Lee del fichero indicado la lista de URL a descargar, una por línea. |
| `--limit-rate=200k` | Limita el ancho de banda empleado, para no saturar la línea. |
| `-t N` | Número de reintentos ante fallos. `-t 0` reintenta de forma indefinida. |
| `--mirror` | Atajo de `-r -N -l inf --no-remove-listing` para replicar un sitio completo. |
| `--no-check-certificate` | Ignora los errores de validación del certificado TLS. |

> **Advertencia:** `--no-check-certificate` desactiva precisamente la comprobación que garantiza que se está hablando con el servidor legítimo y no con un intermediario. Puede ser razonable en un laboratorio con certificados autofirmados, pero nunca debe convertirse en costumbre ni aparecer en un script de producción. El equivalente en `curl` es `-k`, y merece la misma reserva.

> **Nota:** Por defecto, `wget` guarda el fichero en el **directorio actual** y con el **mismo nombre** que tiene en el servidor. Para cambiar dónde y con qué nombre se guarda hay dos opciones que conviene no confundir:
>
> - `-P /ruta/` elige **solo el directorio** de destino y conserva el nombre remoto.
> - `-O /ruta/nombre` elige la **ruta y el nombre** completos del fichero de salida.
>
> Si se combinan ambas, `-O` tiene prioridad y `-P` se ignora.

### 1.2 Ejemplos de wget

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

Descarga a un directorio concreto conservando el nombre remoto (`-P`):

```bash
usuario@debian:~$ wget -P /var/tmp/descargas https://d.winrar.es/d/97z1713015469/hrYvljKNPEqbS2FjdvSpsQ/rarlinux-x64-700.tar.gz
usuario@debian:~$ ls /var/tmp/descargas
rarlinux-x64-700.tar.gz
```

Descarga eligiendo a la vez la ruta y el nombre del fichero de destino (`-O`):

```bash
usuario@debian:~$ wget -O /var/tmp/descargas/winrar.tar.gz https://d.winrar.es/d/97z1713015469/hrYvljKNPEqbS2FjdvSpsQ/rarlinux-x64-700.tar.gz
usuario@debian:~$ ls /var/tmp/descargas
winrar.tar.gz
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

### 2.1 Parámetros de curl

| Parámetro | Definición |
|-----------|------------|
| `-o` | Especifica el nombre y ruta del archivo de salida. |
| `-O` | Descarga y guarda el archivo utilizando su nombre original remoto. |
| `-s` | Ejecución silenciosa, oculta mensajes de progreso. |
| `-C -` | Continúa descargas interrumpidas. |
| `-L` | Sigue redirecciones HTTP (código 3XX) de forma automática. |
| `-I` | Solicita únicamente las cabeceras de la respuesta (petición `HEAD`). |
| `-v` | Muestra todo el diálogo con el servidor, cabeceras incluidas. Imprescindible para depurar. |
| `--fail` | Devuelve un código de error si el servidor responde con un código HTTP de fallo, en lugar de descargar la página de error. |
| `-X MÉTODO` | Emplea el método HTTP indicado (`POST`, `PUT`, `DELETE`...). |
| `-d DATOS` | Envía datos en el cuerpo de la petición. Implica `POST`. |
| `-H 'Cabecera: valor'` | Añade una cabecera personalizada, como `Content-Type` o `Authorization`. |
| `-u usuario:clave` | Autenticación HTTP básica. |
| `-k` | No valida el certificado TLS. Equivale a `--no-check-certificate` de `wget`. |
| `-w '%{http_code}'` | Imprime al terminar el dato indicado, como el código de respuesta o el tiempo total. |

Dos usos de `curl` que no tienen equivalente cómodo en `wget`:

```bash
usuario@debian:~$ curl -I https://deb.debian.org
HTTP/2 200
content-type: text/html
last-modified: Tue, 16 Sep 2026 11:02:31 GMT

usuario@debian:~$ curl -s -o /dev/null -w '%{http_code}\n' https://deb.debian.org
200
```

> **Recuerda:** La segunda orden es el idiom habitual para **comprobar desde un script si un servicio web responde**: descarta el contenido enviándolo a `/dev/null`, silencia la barra de progreso con `-s` e imprime únicamente el código de estado HTTP.

> **Advertencia:** Al usar `-u usuario:clave` o `-H 'Authorization: ...'`, la contraseña queda escrita en la línea de órdenes y por tanto visible en `ps aux` para cualquier usuario de la máquina, además de quedar registrada en `~/.bash_history`. Para credenciales reales conviene usar `-u usuario` a secas, que las solicita de forma interactiva, o el fichero `~/.netrc` con permisos `600`.

> **Nota:** A diferencia de `wget`, `curl` **no guarda nada en disco por defecto**: vuelca el contenido descargado por la salida estándar, es decir, lo muestra en la pantalla. Para escribirlo en un fichero hay que indicarlo siempre, con `-O` (usa el nombre remoto) o con `-o /ruta/nombre` (usa el nombre que se elija). Volcar la descarga a pantalla resulta útil, en cambio, para leer directamente un fichero de texto corto o la respuesta de una API sin dejar rastro en el disco.

### 2.2 Ejemplos de curl

Descarga conservando el nombre original (`-O`):

```bash
usuario@debian:/tmp/pr$ curl -O https://d.winrar.es/d/97z1713015469/hrYvljKNPEqbS2FjdvSpsQ/rarlinux-x64-700.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   169  100   169    0     0   1264      0 --:--:-- --:--:-- --:--:--  1261
```

> **Advertencia:** Conviene fijarse en la cifra: se han descargado **169 bytes**, cuando el fichero mide 713 KB según el ejemplo de `wget` de la sección anterior. La descarga no ha fallado ni ha dado error, sencillamente el servidor ha respondido con una **redirección** y `curl`, a diferencia de `wget`, no la sigue salvo que se le indique. Esos 169 bytes son la breve página HTML del `301` o `302`, guardada con el nombre del fichero que se esperaba.
>
> Es el fallo más habitual con `curl` y resulta especialmente traicionero porque el código de salida es `0` y todo parece haber ido bien, hasta que se intenta descomprimir el resultado. La solución es añadir `-L`:
>
> ```bash
> usuario@debian:/tmp/pr$ curl -LO https://ejemplo.org/fichero.tar.gz
> ```
>
> Y para que un fallo HTTP se traduzca de verdad en un código de error, conviene añadir también `--fail`. Sin él, una página de error 404 se descarga tan campante como si fuera el contenido pedido.

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

---

## 3. wget frente a curl: dónde y con qué nombre se guarda

Ambas herramientas descargan ficheros, pero usan **convenios de nombres opuestos**, y ahí está el error más frecuente al decidir dónde y con qué nombre se guarda la descarga. Esta tabla resume las combinaciones habituales:

| Qué se quiere | wget | curl |
|---|---|---|
| Guardar con el nombre remoto, en el directorio actual | `wget URL` | `curl -O URL` |
| Guardar en otro directorio, conservando el nombre remoto | `wget -P /ruta/ URL` | `curl --output-dir /ruta/ -O URL` |
| Guardar con la ruta y el nombre que yo elijo | `wget -O /ruta/nombre URL` | `curl -o /ruta/nombre URL` |
| Mostrar por pantalla sin guardar en disco | `wget -O - URL` | `curl URL` |

> **Importante:** Cuidado con las mayúsculas, porque `wget` y `curl` las usan **al revés**:
>
> - En `curl`, la minúscula `-o` significa "*output* con el nombre que yo indico", y la mayúscula `-O` significa "el nombre *Original* remoto".
> - En `wget` es justo al contrario: la mayúscula `-O` es la que sirve para dar el nombre que uno elige.
>
> Confundirlas es la equivocación más habitual, tanto en los exámenes como en la práctica: `curl -O /ruta/nombre` no guarda el fichero con ese nombre, sino que intenta usar `/ruta/nombre` como si fuera una URL y falla.

> **Nota:** La opción `--output-dir` de `curl` requiere una versión 7.73 (año 2020) o posterior, que es la que traen Debian y Ubuntu actuales. En versiones más antiguas, para elegir el directorio hay que dar la ruta completa con `-o /ruta/nombre`.
