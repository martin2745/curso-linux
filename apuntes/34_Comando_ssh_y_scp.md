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
