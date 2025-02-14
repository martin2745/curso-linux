# Comando ssh y scp

## ssh

El cliente (comando ssh) posee una configuración predeterminada que podemos modificar. El orden de prioridad de esa configuración es:

- Opciones invocadas desde la línea de comandos al ejecutar el propio comando ssh con el parámetro `-o`
- Opciones invocadas a través del archivo perteneciente a cada usuario situado en la ruta `~/.ssh/config`
- Opciones invocadas a través del archivo de configuración global del sistema en `/etc/ssh/ssh_config`

Una vez que nos hemos conectado por ssh en el cliente se crea la carpeta `.ssh/known_hosts` con las claves públicas de los servidores a los que te has conectado anteriormente a través de SSH. Estas claves públicas se utilizan para verificar la identidad del servidor cuando te conectas nuevamente, asegurando que no haya ningún intento de suplantación de identidad (ataque de tipo "Man-in-the-middle").

Comando ssh:

```bash
ssh [-p port] user@hostname [command] || ssh [-p port] -l user hostname [command]
```

Comando scp:

```bash
scp [-P port] user@hostname:remote_path local_path #Copiar ficheros
scp -r [-P port] user@hostname:remote_path local_path #Copiar directorios recursivamente
scp [-P port] local_path user@hostname:remote_path #Copiar ficheros
scp -r [-P port] local_path user@hostname:remote_path #Copiar directorios recursivamente
```

Para comprobar el estado del servicio ssh pondemos hacer uso del comando `nc` (netcat) con las opciones `-v`: verbose y `-z`: nos devuelve el PROMPT del sistema.

```bash
nc -vz localhost 22
```

### StrickHostKeyChecking

El parámetro `StrictHostKeyChecking` en SSH (Secure Shell) se utiliza para definir cómo el cliente SSH trata las claves de host al conectarse a un servidor por primera vez o cuando la clave del servidor cambia. Esta directiva es importante para evitar ataques de tipo "man-in-the-middle" (MITM), donde un atacante podría interceptar la conexión y hacerse pasar por el servidor legítimo. A continuación se definen cada uno de los valores que puedes asignar a `StrictHostKeyChecking`:

1. **ask**:

   - **Descripción**: Cuando se establece en `ask`, el cliente SSH pedirá confirmación al usuario si la clave del host del servidor no está en el archivo `known_hosts` o si la clave del servidor ha cambiado. Añade la Host Key del servidor SSH.
   - **Ejemplo de uso**: `StrictHostKeyChecking ask`

2. **yes**:

   - **Descripción**: Si se establece en `yes`, el cliente SSH rechazará automáticamente la conexión si la clave del host del servidor no está en el archivo `known_hosts` o si la clave del servidor ha cambiado. Nunca añade la Host Key del servidor SSH.
   - **Ejemplo de uso**: `StrictHostKeyChecking yes`

3. **no**:
   - **Descripción**: Cuando se establece en `no`, el cliente SSH aceptará automáticamente la clave del host del servidor sin pedir confirmación, incluso si la clave del servidor no está en el archivo `known_hosts` o si la clave ha cambiado. Añade la Host Key del servidor SSH.
   - **Ejemplo de uso**: `StrictHostKeyChecking no`

Ejemplos de uso:

```bash
ssh -o StrictHostKeyChecking=no -o Port=9999 -l kali 192.168.120.100
```

```bash
ssh -o StrictHostKeyChecking=no -p 9999 kali@192.168.120.100
```

### Redirección gráfica por SSH

El siguiente comando permitirá que nos conectemos por ssh y lanzará el navegador firefox en el cliente.

```bash
ssh -X si@192.168.120.101 firefox
```

`X11Forwarding` ➜ Directiva que determina si la redirección gráfica es posible mediante conexiones SSH. Solo puede tomar 2 valores: yes/no.

- X11Forwarding no ➜ es el valor por defecto. Deshabilita la redirección gráfica del servidor SSH.

- X11Forwarding yes ➜ Habilita la redirección gráfica del servidor SSH.

`X11DisplayOffset` ➜ Directiva que determina el número del display donde espera el servidor gráfico. Por defecto es 10, para evitar interferencias con servidores X11 reales.

- X11DisplayOffset 10 ➜ es el valor por defecto. Indica el número de display donde espera el servidor gráfico para conexiones SSH.

- X11DisplayOffset 100 ➜ Indica el número de display 100 donde espera el servidor gráfico para conexiones SSH.

- X11Forwarding yes ➜ Habilita la redirección gráfica del servidor SSH.

`X11UseLocalhost` ➜ Directiva que determina si la redirección gráfica es posible en la dirección loopback o en cualquier dirección:

- X11UseLocalhost yes ➜ es el valor por defecto. Permite la redirección gráfica a la dirección loopback y define la variable de entorno DISPLAY a localhost, lo cual previene conexiones remotas no permitidas al display.

- X11UseLocalhost no ➜ Habilita la redirección gráfica a todas las interfaces de red.

### Comando SSH + contraseña

Previamente se tendrá que instalar `sshpass` para poder hacer uso de esta utilidad. Una vez instalada podemos realizar la conexión en un único paso.

```bash
sshpass -p 'abc123.' ssh si@192.168.120.101
```

### Cifrado asimétrico

Generamos en el cliente el par de claves pública/privada en la ruta `~/.ssh/id_rsa`.

```bash
┌──(kali㉿kaliA)-[~]
└─$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/home/kali/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/kali/.ssh/id_rsa
Your public key has been saved in /home/kali/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:gckghzEyGS3QmomEnguTbWDkP6p0BH4e8/VMWrzUbb0 kali@kali
The key's randomart image is:
+---[RSA 3072]----+
|O*+oo            |
|*=++ o o         |
|=@.   + .        |
|Xo=     ... . .  |
|.+.B   .S= . o . |
| .= = . B . .   .|
| o o . . +     E |
|o .              |
|.                |
+----[SHA256]-----+
```

- Debemos elegir el directorio donde guardar las claves y el nombre de estas. Pulsamos Enter para dejar por defecto el directorio .ssh/ y el nombre id_rsa dentro del HOME del usuario: /home/kali.
- Passphrase nulo. Si aquí ponemos una contraseña, frase o similar, cuando queramos conectarnos al Servidor SSH en vez de pedir la contraseña del usuario de la conexión pedirá esta passphrase, pero como cuando queremos conectarnos queremos hacerlo de forma directa sin petición de contraseña o passphrase, entonces pulsamos 2 veces Enter para que la conexión se haga sin contraseña.
- Clave pública y privada creadas. Fingerprint. Se crearon en el directorio anteriormente indicado la clave privada id_rsa y la clave pública id_rsa.pub. También se creó el fingerprint de la clave pública, es decir, la identificación inequívoca de la clave pública correspondiente al usuario kali de este equipo.

Ahora tenemos que enviar la clave pública al servidor.

```bash
┌──(kali㉿kaliA)-[~]
└─$ ssh-copy-id -i .ssh/id_rsa.pub kali@192.168.120.101
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: ".ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
kali@192.168.120.101's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'kali@192.168.120.101'"
and check to make sure that only the key(s) you wanted were added.
```

Si miramos, en el servidor, se ha creado una nueva carpeta con el contenido de la clave pública de kaliA en la ruta `.ssh/authorized_keys`.

```bash
┌──(kali㉿kaliB)-[~]
└─$ cat .ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8NlAcBQldgqvIBdeR3D9cpdSiLiL9PrPmgjDSWgGoxshi3bKCcwvmXrjCF75fxo/rqVtY8Wi2m9CX2CeVLeY7VZ6jdG7GMwBUpI+EBDKn5IqWoq+Ha6Tx7x6qNrfEWeoyyEL7HcnBt0jDiDsbD/rs/7wMCWyF2Z+ayUEy5+VWWZ7xr7ogBIJpOvmJ/Eiuu/z98ohHlRoaL6kmG01wzpss+nJZdzlgLn0sRFp4/zzn+aO9L6XDEu1gDhekIm5TRpmszhpIyM7eGEpAl1NsqgZlZyf8VY30FtAqPNKqig4SxLPGQxlrQrzHBeeJo//U0E5p4VEjMlKQXh8GVyJ1llSBGZZfd31pzJYX8D1FvYOHqrMsITGjNupN+4cn4eun6lrNTw1lxO6ppYbX1RGdTwEpe1/WPmVWnYY0FihX6tuIKFNEaoFSqvU0hWRhRXAw6sASWShd6lIWaq+W8HWNvXhSxsJUdEqVyeoCz9Mf4TzhM7pH3h8NzsEDJoUbZkDy5ik= kali@kali
```

Si hacemos una conexión entre kaliA hacia kaliB veremos como no se nos pide la contraseña.

```bash
┌──(kali㉿kaliA)-[~]
└─$ ssh kali@192.168.120.101
Linux kali 6.5.0-kali3-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.5.6-1kali1 (2023-10-09) x86_64

The programs included with the Kali GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Kali GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Sun Jun  9 13:47:01 2024 from 10.0.2.2
┌──(kali㉿kaliB)-[~]
└─$ whoami
kali
```

Si hubieramos introducido un `Passphrase` se nos hubiera pedido a la hora de hacer ssh tal y como se ve en este ejemplo.

```bash
┌──(kali㉿kaliA)-[~]
└─$ ssh kali@192.168.120.101
Enter passphrase for key '/home/kali/.ssh/id_rsa':
Linux kali 6.5.0-kali3-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.5.6-1kali1 (2023-10-09) x86_64

The programs included with the Kali GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Kali GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Sun Jun  9 13:48:45 2024 from 192.168.120.100
┌──(kali㉿kaliB)-[~]
└─$ whoami
kali
```

## scp

### scp de máquina A -> B indicado desde máquina C

Vamos a hacer uso en este escenario de tres máquinas kaliA, kaliB y kaliC. Desde kaliC vamos a indicar a máquina A que tiene que hacer un scp de una carpeta /prueba que contiene 5 ficheros.

Lo primero de todo será crear los ficheros con una petición ssh desde máquina C hacia A (C->A).

```bash
┌──(kali㉿kaliC)-[~]
└─$ ssh kali@192.168.120.100 'mkdir prueba && for i in $(seq 1 5); do echo "Soy fichero${i}.txt" > prueba/fichero${i}.txt; done && ls prueba/'
kali@192.168.120.100's password:
fichero1.txt
fichero2.txt
fichero3.txt
fichero4.txt
fichero5.txt
```

Ahora vamos a hacer un scp del contenido de `prueba/` de máquina A hacia máquina B. La orde se enviará desde máquina C hacia máquina A (C->A->B).

```bash
┌──(kali㉿kaliC)-[~]
└─$ scp -r kali@192.168.120.100:~/prueba kali@192.168.120.101:/tmp
kali@192.168.120.101's password:
kali@192.168.120.100's password:
fichero5.txt                                        100%   17     6.6KB/s   00:00
fichero4.txt                                        100%   17     6.6KB/s   00:00
fichero3.txt                                        100%   17     5.7KB/s   00:00
fichero2.txt                                        100%   17     5.4KB/s   00:00
fichero1.txt                                        100%   17     6.4KB/s   00:00
```

```bash
┌──(kali㉿kaliB)-[~]
└─$ ls /tmp/prueba/*
/tmp/prueba/fichero1.txt  /tmp/prueba/fichero3.txt  /tmp/prueba/fichero5.txt
/tmp/prueba/fichero2.txt  /tmp/prueba/fichero4.txt
```

### Ejemplos de uso curiosos y cuestiones a considerar

```bash
scp -r ~/cousas root@192.168.100.20:
```

Se añade directamente la información en el `/home` del usuario sin poner la ruta.

```bash
scp -r ~/cousas 192.168.100.20:
```

Si no indicamos el nombre se utiliza el de la consola actual.

```bash
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED! @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ECDSA key sent by the remote host is
17:4A:50:91:36:cb:ca:3d:24:db:60:0e:af:00:9b:c9.
Please contact your system administrator.
Add correct host key in /root/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in /root/.ssh/known_hosts:7
Password authentication is disabled to avoid man-in-the-middle attacks.
Keyboard-interactive authentication is disabled to avoid man-in-the-middle attacks.
Permission denied (publickey,password).
```

Se nos indica que el problema está la entrada 7 del archivo `/root/.ssh/known_hosts`.

```bash
ssh -p 8733 user1@192.168.100.20 df -h && ls /tmp
```

Este caso es incorrecto ya que el comando `df -h` se ejecutaría en el servidor pero el `ls /tmp` se lanzaría en el cliente si la conexión es exitosa por lo que tendríamos que poner entre comillas los dos comandos para no tener errores.

### Retos de SSH

Como web para prácticar tenemos los retos de [ssh de bandit](https://overthewire.org/wargames/bandit/bandit0.html)

#### bandit0 --> bandit1

```bash
bandit0@bandit:~$ ls -l
total 4
-rw-r----- 1 bandit1 bandit0 438 Sep 19 07:08 readme

bandit0@bandit:~$ cat readme
Congratulations on your first steps into the bandit game!!
Please make sure you have read the rules at https://overthewire.org/rules/
If you are following a course, workshop, walkthrough or other educational activity,
please inform the instructor about the rules as well and encourage them to
contribute to the OverTheWire community so we can keep these games free!

The password you are looking for is: ZjLjTmM6FvvyRnrb2rfNWOZOTa6ip5If
```

#### bandit1 --> bandit2

```bash
bandit1@bandit:~$ ls -l
total 4
-rw-r----- 1 bandit2 bandit1 33 Sep 19 07:08 -

bandit1@bandit:~$ cat ./-
263JGJPfgU6LtdEvgfWU1XP5yac29mFx

bandit1@bandit:~$ cat $(pwd)/-
263JGJPfgU6LtdEvgfWU1XP5yac29mFx
```

#### bandit2 --> bandit3

```bash
bandit2@bandit:~$ ls -l
total 4
-rw-r----- 1 bandit3 bandit2 33 Sep 19 07:08 spaces in this filename

bandit2@bandit:~$ cat spaces\ in\ this\ filename
MNk8KNH3Usiio41PRUEoDFPqfxLPlSmx

bandit2@bandit:~$ cat "spaces in this filename"
MNk8KNH3Usiio41PRUEoDFPqfxLPlSmx

bandit2@bandit:~$ cat $(pwd)/*
MNk8KNH3Usiio41PRUEoDFPqfxLPlSmx

bandit2@bandit:~$ cat *
MNk8KNH3Usiio41PRUEoDFPqfxLPlSmx

bandit2@bandit:~$ cat $(pwd)/s*
MNk8KNH3Usiio41PRUEoDFPqfxLPlSmx

bandit2@bandit:~$ cat s*
MNk8KNH3Usiio41PRUEoDFPqfxLPlSmx
```

#### bandit3 --> bandit4

```bash
bandit3@bandit:~$ ls -la inhere/
total 12
drwxr-xr-x 2 root    root    4096 Sep 19 07:08 .
drwxr-xr-x 3 root    root    4096 Sep 19 07:08 ..
-rw-r----- 1 bandit4 bandit3   33 Sep 19 07:08 ...Hiding-From-You

bandit3@bandit:~$ file $(pwd)/inhere/...*
/home/bandit3/inhere/...Hiding-From-You: ASCII text

bandit3@bandit:~$ cat $(pwd)/inhere/...*
2WmrDFRmJIq3IPxneAaMGhap0pFhF3NJ

bandit3@bandit:~$ find . -type f | grep Hid | xargs cat
2WmrDFRmJIq3IPxneAaMGhap0pFhF3NJ

bandit3@bandit:~$ find . -type f | grep -vE 'bash|profile' | xargs cat
2WmrDFRmJIq3IPxneAaMGhap0pFhF3NJ
```

#### bandit4 --> bandit5

```bash
bandit4@bandit:~$ find . | grep inhere | xargs file
./inhere:         directory
./inhere/-file08: data
./inhere/-file02: data
./inhere/-file09: data
./inhere/-file01: data
./inhere/-file00: data
./inhere/-file05: data
./inhere/-file07: ASCII text
./inhere/-file03: data
./inhere/-file06: data
./inhere/-file04: data

bandit4@bandit:~$ find inhere/ | xargs file | grep "07" | awk -F ":" '{print $1}' | xargs cat
4oQYVPkxZOOEOO5pTW81FB8j8lxXGUQw
```

#### bandit5 --> bandit6

```bash
bandit5@bandit:~$ find . -type f -readable ! -executable -size 1033c | xargs cat
HWasnPhtq9AVKe0dmk45nxy20cvUa6EG
```

#### bandit6 --> bandit7

```bash
bandit6@bandit:~$ find / -type f -user bandit7 -group bandit6 -size 33c 2>/dev/null | xargs cat
morbNTDkSW6jIlUc0ymOdMaLnOlFVAaj
```

#### bandit7 --> bandit8

```bash
bandit7@bandit:~$ ls -l
total 4088
-rw-r----- 1 bandit8 bandit7 4184396 Sep 19 07:08 data.txt

bandit7@bandit:~$ cat data.txt | grep millionth | awk '{print $NF}'
dfwvzFQi4mU0wfNbFOe9RoWskMLg7eEc

bandit7@bandit:~$ cat data.txt | grep millionth | awk '{print $N2}'
millionth       dfwvzFQi4mU0wfNbFOe9RoWskMLg7eEc

bandit7@bandit:~$ cat data.txt | grep millionth | tr -s '\t' ' ' | cut -d ' ' -f2
dfwvzFQi4mU0wfNbFOe9RoWskMLg7eEc

bandit7@bandit:~$ cat data.txt | grep millionth | xargs | cut -d ' ' -f2
dfwvzFQi4mU0wfNbFOe9RoWskMLg7eEc

bandit7@bandit:~$ cat data.txt | grep millionth | sed 's/\t/ /g' | cut -d ' ' -f2
dfwvzFQi4mU0wfNbFOe9RoWskMLg7eEc 
```

#### bandit8 --> bandit9

```bash
bandit8@bandit:~$ sort data.txt | uniq -u
4CKMh1JI91bUIZZPXDqGanal4xvAg0JM
```

#### bandit8 --> bandit9

```bash
bandit8@bandit:~$ sort data.txt | uniq -u
4CKMh1JI91bUIZZPXDqGanal4xvAg0JM
```

#### bandit9 --> bandit10

```bash
bandit9@bandit:~$ strings data.txt | grep "===" | tail -n1 | awk '{print $NF}'
FGUW5ilLVJrxX9kMYMmlN4MgbpfMiqey
```

#### bandit10 --> bandit11

```bash
bandit10@bandit:~$ cat data.txt
VGhlIHBhc3N3b3JkIGlzIGR0UjE3M2ZaS2IwUlJzREZTR3NnMlJXbnBOVmozcVJyCg==

bandit10@bandit:~$ echo "Vamos a transformar el mensaje a base64" | base64
VmFtb3MgYSB0cmFuc2Zvcm1hciBlbCBtZW5zYWplIGEgYmFzZTY0Cg==

bandit10@bandit:~$ cat data.txt | base64 -d
The password is dtR173fZKb0RRsDFSGsg2RWnpNVj3qRr

bandit10@bandit:~$ cat data.txt | base64 -d | awk '{print $NF}'
dtR173fZKb0RRsDFSGsg2RWnpNVj3qRr
```

#### bandit11 --> bandit12

```bash
bandit11@bandit:~$ cat data.txt
Gur cnffjbeq vf 7k16JArUVv5LxVuJfsSVdbbtaHGlw9D4

bandit11@bandit:~$ cat data.txt | tr '[G-ZA-Fg-za-f]' '[T-ZA-St-za-s]'
The password is 7x16WNeHIi5YkIhWsfFIqoognUTyj9Q4

bandit11@bandit:~$ cat data.txt | tr '[A-Za-z]' '[N-ZA-Mn-za-m]'
The password is 7x16WNeHIi5YkIhWsfFIqoognUTyj9Q4
```

#### bandit12 --> bandit13

```bash
┌──(kali㉿kali)-[/tmp]
└─$ cat /etc/hosts
127.0.0.1       localhost
127.0.1.1       kali.acarballeira.local kali

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

┌──(kali㉿kali)-[/tmp]
└─$ cat /etc/hosts | xxd
00000000: 3132 372e 302e 302e 3109 6c6f 6361 6c68  127.0.0.1.localh
00000010: 6f73 740a 3132 372e 302e 312e 3109 6b61  ost.127.0.1.1.ka
00000020: 6c69 2e61 6361 7262 616c 6c65 6972 612e  li.acarballeira.
00000030: 6c6f 6361 6c09 6b61 6c69 0a0a 2320 5468  local.kali..# Th
00000040: 6520 666f 6c6c 6f77 696e 6720 6c69 6e65  e following line
00000050: 7320 6172 6520 6465 7369 7261 626c 6520  s are desirable
00000060: 666f 7220 4950 7636 2063 6170 6162 6c65  for IPv6 capable
00000070: 2068 6f73 7473 0a3a 3a31 2020 2020 206c   hosts.::1     l
00000080: 6f63 616c 686f 7374 2069 7036 2d6c 6f63  ocalhost ip6-loc
00000090: 616c 686f 7374 2069 7036 2d6c 6f6f 7062  alhost ip6-loopb
000000a0: 6163 6b0a 6666 3032 3a3a 3120 6970 362d  ack.ff02::1 ip6-
000000b0: 616c 6c6e 6f64 6573 0a66 6630 323a 3a32  allnodes.ff02::2
000000c0: 2069 7036 2d61 6c6c 726f 7574 6572 730a   ip6-allrouters.

┌──(kali㉿kali)-[/tmp]
└─$ cat /etc/hosts | xxd -ps
3132372e302e302e31096c6f63616c686f73740a3132372e302e312e3109
6b616c692e6163617262616c6c656972612e6c6f63616c096b616c690a0a
232054686520666f6c6c6f77696e67206c696e6573206172652064657369
7261626c6520666f7220495076362063617061626c6520686f7374730a3a
3a3120202020206c6f63616c686f7374206970362d6c6f63616c686f7374
206970362d6c6f6f706261636b0a666630323a3a31206970362d616c6c6e
6f6465730a666630323a3a32206970362d616c6c726f75746572730a

┌──(kali㉿kali)-[/tmp]
└─$ cat /etc/hosts | xxd -ps | xargs | tr -d ' '
3132372e302e302e31096c6f63616c686f73740a3132372e302e312e31096b616c692e6163617262616c6c656972612e6c6f63616c096b616c690a0a232054686520666f6c6c6f77696e67206c696e65732061726520646573697261626c6520666f7220495076362063617061626c6520686f7374730a3a3a3120202020206c6f63616c686f7374206970362d6c6f63616c686f7374206970362d6c6f6f706261636b0a666630323a3a31206970362d616c6c6e6f6465730a666630323a3a32206970362d616c6c726f75746572730a

┌──(kali㉿kali)-[/tmp]
└─$ cat /etc/hosts | xxd -ps | xargs | tr -d ' ' > intermedio.txt

┌──(kali㉿kali)-[/tmp]
└─$ cat intermedio.txt | xxd -ps -r
127.0.0.1       localhost
127.0.1.1       kali.acarballeira.local kali

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

- **`-ps`**: Muestra el contenido en formato hexadecimal "plain", es decir, solo los valores hexadecimales, sin direcciones ni representación ASCII.
- **`-r`**: Realiza la operación inversa, es decir, convierte de vuelta un archivo o una cadena en formato hexadecimal a su formato original (en este caso, texto ASCII).

_*Nota*_: Para este ejercicio hago uso de una máquina kali que me permita instalar mis propias herramientas y hacer uso de `7z` para descomprimir. Para podemos utilizar scp para poder tener en nuestra máquina la información.

- `7z l data`: Muestra el tipo de archivo comprimido y que encierra en su interior.
- `7z x data`: Permite descomprimir el archivo con independencia de que tipo de comprimido sea.
- `7z a archivo.7z archivo1.txt archivo2.txt` o `7z a directorioComprimir.7z /home/kali/directorioComprimir`: Permite comprimir archivos o directorios.

```bash
┌──(kali㉿kali)-[/tmp]
└─$ scp -P 2220 bandit12@bandit.labs.overthewire.org:~/data.txt data.txt
                         _                     _ _ _
                        | |__   __ _ _ __   __| (_) |_
                        | '_ \ / _` | '_ \ / _` | | __|
                        | |_) | (_| | | | | (_| | | |_
                        |_.__/ \__,_|_| |_|\__,_|_|\__|


                      This is an OverTheWire game server.
            More information on http://www.overthewire.org/wargames

bandit12@bandit.labs.overthewire.org's password:
data.txt                                        100% 2583    20.1KB/s   00:00

┌──(kali㉿kali)-[/tmp]
└─$ cat data.txt
00000000: 1f8b 0808 dfcd eb66 0203 6461 7461 322e  .......f..data2.
00000010: 6269 6e00 013e 02c1 fd42 5a68 3931 4159  bin..>...BZh91AY
00000020: 2653 59ca 83b2 c100 0017 7fff dff3 f4a7  &SY.............
00000030: fc9f fefe f2f3 cffe f5ff ffdd bf7e 5bfe  .............~[.
00000040: faff dfbe 97aa 6fff f0de edf7 b001 3b56  ......o.......;V
00000050: 0400 0034 d000 0000 0069 a1a1 a000 0343  ...4.....i.....C
00000060: 4686 4341 a680 068d 1a69 a0d0 0068 d1a0  F.CA.....i...h..
00000070: 1906 1193 0433 5193 d4c6 5103 4646 9a34  .....3Q...Q.FF.4
00000080: 0000 d320 0680 0003 264d 0346 8683 d21a  ... ....&M.F....
00000090: 0686 8064 3400 0189 a683 4fd5 0190 001e  ...d4.....O.....
000000a0: 9034 d188 0343 0e9a 0c40 69a0 0626 4686  .4...C...@i..&F.
000000b0: 8340 0310 d340 3469 a680 6800 0006 8d0d  .@...@4i..h.....
000000c0: 0068 0608 0d1a 64d3 469a 1a68 c9a6 8030  .h....d.F..h...0
000000d0: 9a68 6801 8101 3204 012a ca60 51e8 1cac  .hh...2..*.`Q...
000000e0: 532f 0b84 d4d0 5db8 4e88 e127 2921 4c8e  S/....].N..')!L.
000000f0: b8e6 084c e5db 0835 ff85 4ffc 115a 0d0c  ...L...5..O..Z..
00000100: c33d 6714 0121 5762 5e0c dbf1 aef9 b6a7  .=g..!Wb^.......
00000110: 23a6 1d7b 0e06 4214 01dd d539 af76 f0b4  #..{..B....9.v..
00000120: a22f 744a b61f a393 3c06 4e98 376f dc23  ./tJ....<.N.7o.#
00000130: 45b1 5f23 0d8f 640b 3534 de29 4195 a7c6  E._#..d.54.)A...
00000140: de0c 744f d408 4a51 dad3 e208 189b 0823  ..tO..JQ.......#
00000150: 9fcc 9c81 e58c 9461 9dae ce4a 4284 1706  .......a...JB...
00000160: 61a3 7f7d 1336 8322 cd59 e2b5 9f51 8d99  a..}.6.".Y...Q..
00000170: c300 2a9d dd30 68f4 f9f6 7db6 93ea ed9a  ..*..0h...}.....
00000180: dd7c 891a 1221 0926 97ea 6e05 9522 91f1  .|...!.&..n.."..
00000190: 7bd3 0ba4 4719 6f37 0c36 0f61 02ae dea9  {...G.o7.6.a....
000001a0: b52f fc46 9792 3898 b953 36c4 c247 ceb1  ./.F..8..S6..G..
000001b0: 8a53 379f 4831 52a3 41e9 fa26 9d6c 28f4  .S7.H1R.A..&.l(.
000001c0: 24ea e394 651d cb5c a96c d505 d986 da22  $...e..\.l....."
000001d0: 47f4 d58b 589d 567a 920b 858e a95c 63c1  G...X.Vz.....\c.
000001e0: 2509 612c 5364 8e7d 2402 808e 9b60 02b4  %.a,Sd.}$....`..
000001f0: 13c7 be0a 1ae3 1400 4796 4370 efc0 9b43  ........G.Cp...C
00000200: a4cb 882a 4aae 4b81 abf7 1c14 67f7 8a34  ...*J.K.....g..4
00000210: 0867 e5b6 1df6 b0e8 8023 6d1c 416a 28d0  .g.......#m.Aj(.
00000220: c460 1604 bba3 2e52 297d 8788 4e30 e1f9  .`.....R)}..N0..
00000230: 2646 8f5d 3062 2628 c94e 904b 6754 3891  &F.]0b&(.N.KgT8.
00000240: 421f 4a9f 9feb 2ec9 83e2 c20f fc5d c914  B.J..........]..
00000250: e142 432a 0ecb 0459 1b15 923e 0200 00    .BC*...Y...>...

┌──(kali㉿kali)-[/tmp]
└─$ cat data.txt | xxd -r
���fdata2.bin>��BZh91AY&SYʃ�����������������ݿ~[���߾��o������;V4�i��

┌──(kali㉿kali)-[/tmp]
└─$ cat data.txt | xxd -r > data

┌──(kali㉿kali)-[/tmp]
└─$ file data
data: gzip compressed data, was "data2.bin", last modified: Thu Sep 19 07:08:15 2024, max compression, from Unix, original size modulo 2^32 574

┌──(kali㉿kali)-[/tmp]
└─$ 7z l data

7-Zip 24.08 (x64) : Copyright (c) 1999-2024 Igor Pavlov : 2024-08-11
 64-bit locale=C.UTF-8 Threads:2 OPEN_MAX:1024

Scanning the drive for archives:
1 file, 607 bytes (1 KiB)

Listing archive: data

--
Path = data
Type = gzip
Headers Size = 20

   Date      Time    Attr         Size   Compressed  Name
------------------- ----- ------------ ------------  ------------------------
2024-09-19 08:08:15 .....          574          607  data2.bin
------------------- ----- ------------ ------------  ------------------------
2024-09-19 08:08:15                574          607  1 files

┌──(kali㉿kali)-[/tmp]
└─$ 7z x data

7-Zip 24.08 (x64) : Copyright (c) 1999-2024 Igor Pavlov : 2024-08-11
 64-bit locale=C.UTF-8 Threads:2 OPEN_MAX:1024

Scanning the drive for archives:
1 file, 607 bytes (1 KiB)

Extracting archive: data
--
Path = data
Type = gzip
Headers Size = 20

Everything is Ok

Size:       574
Compressed: 607

┌──(kali㉿kali)-[/tmp]
└─$ 7z l data2.bin

### Continuamos descomprimiendo archivos

┌──(kali㉿kali)-[/tmp]
└─$ cat data9.bin
The password is FO5dwFsc0cbaIiH0h8J2eUks2vdTDwAn
```

Realmente, lo correcto sería hacer un script de bash que automatice el proceso.

```bash
#!/bin/bash

primer_archivo=$1
nombre_archivo_descomprimido="$(7z l ${primer_archivo} | tail -n 3 | head -n 1 | awk '{print $NF}')"

7z x ${primer_archivo} &>/dev/null

while [ ${nombre_archivo_descomprimido} ]; do
        echo -e "\n[+] Nuevo archivo descomprimido ${nombre_archivo_descomprimido}"
        7z x ${nombre_archivo_descomprimido} &>/dev/null
        nombre_archivo_descomprimido="$(7z l ${nombre_archivo_descomprimido} 2>/dev/null | tail -n 3 | head -n 1 | awk '{print $NF}')"
done
```

```bash
┌──(kali㉿kali)-[/tmp]
└─$ ls -l data*
-rw-rw-r-- 1 kali kali  607 Feb 14 14:30 data
-rw-r----- 1 kali kali 2583 Feb 14 14:28 data.txt

┌──(kali㉿kali)-[/tmp]
└─$ bash decompressor.sh data

[+] Nuevo archivo descomprimido data2.bin

[+] Nuevo archivo descomprimido data2

[+] Nuevo archivo descomprimido data4.bin

[+] Nuevo archivo descomprimido data5.bin

[+] Nuevo archivo descomprimido data6.bin

[+] Nuevo archivo descomprimido data6

[+] Nuevo archivo descomprimido data8.bin

[+] Nuevo archivo descomprimido data9.bin

┌──(kali㉿kali)-[/tmp]
└─$ ls -l data*
-rw-rw-r-- 1 kali kali   607 Feb 14 14:30 data
-rw-r----- 1 kali kali  2583 Feb 14 14:28 data.txt
-rw-rw-r-- 1 kali kali   432 Sep 19 09:08 data2
-rw-rw-r-- 1 kali kali   574 Sep 19 09:08 data2.bin
-rw-rw-r-- 1 kali kali 20480 Sep 19 09:08 data4.bin
-rw-r--r-- 1 kali kali 10240 Sep 19 09:08 data5.bin
-rw-rw-r-- 1 kali kali 10240 Sep 19 09:08 data6
-rw-r--r-- 1 kali kali   221 Sep 19 09:08 data6.bin
-rw-r--r-- 1 kali kali    79 Sep 19 09:08 data8.bin
-rw-rw-r-- 1 kali kali    49 Sep 19 09:08 data9.bin

┌──(kali㉿kali)-[/tmp]
└─$ cat data9.bin
The password is FO5dwFsc0cbaIiH0h8J2eUks2vdTDwAn
```