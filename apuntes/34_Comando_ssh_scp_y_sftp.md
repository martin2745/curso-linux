# Comando ssh, scp y sftp

## Índice

1. [Funcionamiento de SSH y establecimiento de conexión](#1-funcionamiento-de-ssh-y-establecimiento-de-conexión)
   1. [Three-way handshake](#11-three-way-handshake)
   2. [SSH-TRANS](#12-ssh-trans)
   3. [Intercambio de claves (SSH_MSG_KEXINIT)](#13-intercambio-de-claves-sshmsgkexinit)
   4. [Fingerprint del servidor](#14-fingerprint-del-servidor)
   5. [Generación de la clave de sesión](#15-generación-de-la-clave-de-sesión)
2. [Comandos para instalar el servidor SSH en Debian](#2-comandos-para-instalar-el-servidor-ssh-en-debian)
3. [ssh](#3-ssh)
   1. [StrictHostKeyChecking](#31-stricthostkeychecking)
   2. [Redirección gráfica por SSH](#32-redirección-gráfica-por-ssh)
   3. [Comando SSH + contraseña](#33-comando-ssh--contraseña)
   4. [Cifrado asimétrico](#34-cifrado-asimétrico)
   5. [Práctica guiada: conexión por clave desde Windows a una máquina virtual](#35-práctica-guiada-conexión-por-clave-desde-windows-a-una-máquina-virtual)
   6. [Diferencia entre known_hosts y authorized_keys](#36-diferencia-entre-knownhosts-y-authorizedkeys)
4. [scp](#4-scp)
   1. [scp de máquina A a B indicado desde máquina C](#41-scp-de-máquina-a-a-b-indicado-desde-máquina-c)
   2. [Ejemplos de uso curiosos y cuestiones a considerar](#42-ejemplos-de-uso-curiosos-y-cuestiones-a-considerar)
5. [Fichero de configuración del cliente (~/.ssh/config)](#5-fichero-de-configuración-del-cliente-sshconfig)
6. [Endurecimiento del servidor SSH](#6-endurecimiento-del-servidor-ssh)
7. [Túneles SSH y reenvío de puertos](#7-túneles-ssh-y-reenvío-de-puertos)
   1. [Reenvío local (`-L`)](#71-reenvío-local--l)
   2. [Reenvío remoto (`-R`)](#72-reenvío-remoto--r)
   3. [Reenvío dinámico (`-D`): un proxy SOCKS](#73-reenvío-dinámico--d-un-proxy-socks)
   4. [Opciones útiles para túneles](#74-opciones-útiles-para-túneles)
8. [Resumen: ssh, scp y sftp](#8-resumen-ssh-scp-y-sftp)
   1. [ssh](#81-ssh)
   2. [scp](#82-scp)
   3. [sftp](#83-sftp)
9. [Práctica: los retos Bandit](#9-práctica-los-retos-bandit)
10. [Uso de PuTTY como cliente SSH en Windows](#10-uso-de-putty-como-cliente-ssh-en-windows)
    1. [Instalación](#101-instalación)
    2. [Primera conexión paso a paso](#102-primera-conexión-paso-a-paso)
    3. [Guardar sesiones para no repetir datos](#103-guardar-sesiones-para-no-repetir-datos)
    4. [Ajustes recomendados](#104-ajustes-recomendados)
    5. [Autenticación por clave con PuTTYgen](#105-autenticación-por-clave-con-puttygen)
    6. [Pageant: el agente de claves](#106-pageant-el-agente-de-claves)
    7. [Transferencia de ficheros: pscp y psftp](#107-transferencia-de-ficheros-pscp-y-psftp)
    8. [El verdadero potencial: túneles SSH (reenvío de puertos)](#108-el-verdadero-potencial-túneles-ssh-reenvío-de-puertos)
    9. [Alternativa moderna: el cliente ssh de Windows](#109-alternativa-moderna-el-cliente-ssh-de-windows)

---


## 1. Funcionamiento de SSH y establecimiento de conexión

Protocolo SSH (Secure Shell) es un protocolo que garantiza la confidencialidad, integridad y autenticación en las comunicaciones. Su uso más común es como **túnel seguro** protegiendo contra ataques como el rastreo de paquetes. Opera sobre el puerto TCP 22 y está disponible en la mayoría de los sistemas operativos. SSH emplea un sistema criptográfico híbrido (simétrico y asimétrico) y se utiliza ampliamente para:

- Administración remota segura.
- Transferencia de archivos mediante SCP (secure copy protocol) y SFTP (secure file transfer protocol).
- Reenvío de puertos, permitiendo su uso como una VPN ligera para acceder a recursos de forma segura.

![proceso](../imagenes/recursos/SSH%20establecimiento%20de%20conexión/proceso.png)

![00](../imagenes/recursos/SSH%20establecimiento%20de%20conexión/00.png)

El proceso de conexión SSH anteriormente mostrado no es más que un conjunto de pasos que podemos ver a continuación junto a una breve explicación.

### 1.1 Three-way handshake

![01](../imagenes/recursos/SSH%20establecimiento%20de%20conexión/1.png)

En un primer momento vemos el establecimiento de la conexión TCP ya que SSH trabaja sobre el protocolo TCP de capa de transporte. Este protocolo lleva a cabo un proceso conocido como three-way handshake, el cual es el mecanismo utilizado para establecer una conexión fiable antes de transferir datos entre dos sistemas. Este proceso consta de tres pasos.

1. **Primer paquete (SYN)**  
   Origen: 198.0.2.4  
   Destino: 198.0.2.7  
   Protocolo: TCP, puerto origen 51538, puerto destino 22 (SSH)  
   Contenido: [SYN]  
   Descripción: La máquina kali actuando como cliente (198.0.2.4) inicia la conexión enviando un segmento TCP con la bandera SYN (Synchronize) para solicitar la sincronización de números de secuencia.

2. **Segundo paquete (SYN-ACK)**  
   Origen: 198.0.2.7  
   Destino: 198.0.2.4  
   Protocolo: TCP, puerto origen 22, puerto destino 51538  
   Contenido: [SYN, ACK]  
   Descripción: El servidor (198.0.2.7) responde con un segmento que tiene activas las banderas SYN y ACK. Reconoce la recepción del SYN del cliente (ACK) y envía su propio SYN para solicitar sincronización en sentido contrario.

3. **Tercer paquete (ACK)**  
   Origen: 198.0.2.4  
   Destino: 198.0.2.7  
   Protocolo: TCP, puerto origen 51538, puerto destino 22  
   Contenido: [ACK]  
   Descripción: El cliente (198.0.2.4) termina el proceso enviando un segmento con la bandera ACK, confirmando la recepción del SYN-ACK del servidor y completando así el establecimiento de la conexión.

### 1.2 SSH-TRANS

![02](../imagenes/recursos/SSH%20establecimiento%20de%20conexión/2.png)
![03](../imagenes/recursos/SSH%20establecimiento%20de%20conexión/3.png)

A continuación, se lleva a cabo protocolo SSH-TRANS donde se realiza el intercambio de versiones de protocolo; el servidor envía su clave pública, su versión del protocolo y la del sistema operativo. El cliente verifica la autenticidad del servidor (autenticación del servidor con criptografía asimétrica).

Podemos ver en las dos imágenes anteriores cómo cliente y servidor intercambian información sobre los sistemas operativos:

**OpenSSH_9.9p1 Debian-3:** Representa OpenSSH versión 9.9p1, una versión moderna y mucho más segura, con nuevas funciones, mejoras de rendimiento y, sobre todo, parches de seguridad recientes, empaquetada para una versión más actual de Debian, la cual corresponde con nuestra máquina Kali.

**OpenSSH_6.0p1 Debian-4+deb7u6:** Representa el software OpenSSH versión 6.0p1, que es una versión antigua, empaquetada para el sistema Debian 7, la cual corresponde con nuestra máquina Snort. Usar una versión antigua puede significar menos características, soporte de algoritmos criptográficos hoy desfasados y más riesgos de vulnerabilidades históricas.

### 1.3 Intercambio de claves (SSH_MSG_KEXINIT)

![04](../imagenes/recursos/SSH%20establecimiento%20de%20conexión/4.png)
![05](../imagenes/recursos/SSH%20establecimiento%20de%20conexión/5.png)

**Intercambio de claves (SSH_MSG_KEXINIT):** Comienza la negociación de los parámetros criptográficos de la conexión. Cada lado envía una lista de los algoritmos compatibles en el orden de preferencia del cliente (el cliente es quien elige).

Al final de esta negociación, cliente y servidor acuerdan:

- **Algoritmos de intercambio de claves (kex_algorithms)**: Estos métodos permiten negociar y compartir de forma segura una clave secreta entre cliente y servidor. Ejemplos son "sntrup761x25519-sha512" y "curve25519-sha256", que usan criptografía de curva elíptica y funciones hash para establecer una clave común sin exponerla.
- **Algoritmos de clave de host del servidor (server_host_key_algorithms)**: Se usan para autenticar la identidad del servidor mediante la verificación de su clave pública. Incluyen métodos como "ssh-ed25519-cert-v01" y "ecdsa-sha2-nistp256-cert-v01".
- **Algoritmos de cifrado (encryption_algorithms_client_to_server y server_to_client)**: Se usan para cifrar la comunicación una vez establecida la conexión segura. Por ejemplo, "chacha20-poly1305@openssh.com" proporciona cifrado y autenticación AEAD rápido y seguro. En este caso
- **Algoritmos MAC (mac_algorithms_client_to_server y server_to_client)**: Garantizan la integridad y autenticidad de origen de los datos transmitidos, evitando manipulación. Ejemplos son "umac-64-etm@openssh.com" y "hmac-sha2-256-etm@openssh.com".
- **Algoritmos de compresión (compression_algorithms_client_to_server y server_to_client)**: Opcionalmente comprimen los datos para optimizar la transferencia, usando opciones como "none" o "zlib@openssh.com".

### 1.4 Fingerprint del servidor

![06](../imagenes/recursos/SSH%20establecimiento%20de%20conexión/6.png)

![07](../imagenes/recursos/SSH%20establecimiento%20de%20conexión/7.png)

En la imagen, la sección que aparece bajo "KEX host key (type: ecdsa-sha2-nistp256)" muestra la clave pública del servidor que se transmite durante el mensaje de respuesta al intercambio de claves "Elliptic Curve Diffie-Hellman Key Exchange Reply".

Esta clave pública, representada como una larga secuencia hexadecimal, es recibida por el cliente y es la que se utiliza para calcular el fingerprint del servidor. El fingerprint es un hash, habitualmente SHA256 o MD5, generado a partir de esa clave pública; sirve como identificador único del servidor y es almacenado en el archivo ~/.ssh/known_hosts del cliente para futuras comprobaciones de autenticidad y para prevenir ataques de suplantación en próximas conexiones.

![08](../imagenes/recursos/SSH%20establecimiento%20de%20conexión/8.png)

### 1.5 Generación de la clave de sesión

![09](../imagenes/recursos/SSH%20establecimiento%20de%20conexión/9.png)

Generalmente se emplea un grupo de «Diffie-Hellman», algoritmo asimétrico que permite a ambos extremos generar una clave de sesión simétrica a partir de valores públicos y privados.

A partir de este momento, comenzaremos a cifrar todos los datos con las nuevas claves de sesión que ambos hemos generado gracias a Diffie-Hellman.  
Esta clave se anuncia en el mensaje **SSH_MSG_NEWKEYS** y se usa para establecer el canal seguro SSH. A partir de ese momento, comienza la autenticación del cliente, y toda la comunicación se cifra con el algoritmo simétrico negociado y la clave generada.

**Protocolo SSH-AUTH**  
Protocolo de autenticación: el cliente envía el mensaje **SSH_USERAUTH_REQUEST** para autenticarse. Si tiene éxito, el proceso finaliza.  
La autenticación puede hacerse por contraseña (no recomendada), clave pública o Kerberos. En el caso de usar contraseña, esta se transmite en texto claro, aunque protegida criptográficamente por el protocolo de la capa de transporte SSH-TRANS.

**Protocolo SSH-CONN**  
Se ejecuta sobre el protocolo de transporte SSH. Una vez creado el túnel, los datos se intercambian de forma segura.  
El protocolo de conexión permite multiplexar varios canales lógicos y establecer el reenvío de puertos, que es una función clave de SSH que convierte conexiones TCP inseguras en túneles cifrados.  
Esto garantiza que la comunicación entre cliente y servidor esté protegida contra interceptaciones o manipulaciones.

## 2. Comandos para instalar el servidor SSH en Debian

Para instalar y configurar un servidor SSH en Debian, sigue estos pasos básicos desde la terminal:

**1. Actualiza los repositorios:**

```bash
sudo apt update
```

**2. Instala el servidor SSH (paquete openssh-server):**

```bash
sudo apt install openssh-server
```

**3. Verifica que el servicio SSH esté activo:**

```bash
sudo systemctl status ssh
```

**4. (Opcional) Inicia, habilita y reinicia el servicio SSH para que arranque automáticamente:**

```bash
sudo systemctl start ssh
sudo systemctl enable ssh
sudo systemctl restart ssh
```

## 3. ssh

El cliente (comando ssh) posee una configuración predeterminada que podemos modificar. El orden de prioridad de esa configuración es:

- Opciones invocadas desde la línea de comandos al ejecutar el propio comando ssh con el parámetro `-o`
- Opciones invocadas a través del archivo perteneciente a cada usuario situado en la ruta `~/.ssh/config`
- Opciones invocadas a través del archivo de configuración global del sistema en `/etc/ssh/ssh_config`

> **Nota:** por otra parte, existe el archivo `/etc/ssh/sshd_config` donde se establece la configuración del servidor.

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

### 3.1 StrictHostKeyChecking

La primera vez que nos conectamos a un servidor se realiza una pregunta:

```bash
The authenticity of host '192.168.100.3 (192.168.100.3)' can't be established.
ED25519 key fingerprint is SHA256:Ei+jyMSuP40ZKrFLQGIugsjpiOeCu7MvxpJjSl4caEc.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

En caso de aceptar se creará en el cliente una carpeta oculta `.ssh` con los archivos `known_hosts` y `known_hosts.old`.

- `Archivo known_hosts`: Este archivo se crea para almacenar las claves públicas (no los fingerprints) de los servidores SSH a los que te conectas. Sirve como una base de datos para verificar que el servidor es el mismo en futuras conexiones, evitando ataques como man-in-the-middle.
- `Archivo known_hosts.old`: Es una copia de seguridad del archivo known_hosts, creada automáticamente cuando se modifica el original (por ejemplo, al actualizar o eliminar entradas). Esto permite restaurar información en caso de errores.
- `Fingerprint`: Es un hash generado a partir de la clave pública del servidor. Se muestra la primera vez que te conectas para que confirmes la autenticidad del servidor. No se guarda directamente en known_hosts, ahí se almacena un cálculo resultante de este y otros datos como la clave pública del servidor.

Por otra parte existe el parámetro `StrictHostKeyChecking` en SSH (Secure Shell) se utiliza para definir cómo el cliente SSH trata las claves de host al conectarse a un servidor por primera vez o cuando la clave del servidor cambia. Esta directiva es importante para evitar ataques de tipo "man-in-the-middle" (MITM), donde un atacante podría interceptar la conexión y hacerse pasar por el servidor legítimo. A continuación se definen cada uno de los valores que puedes asignar a `StrictHostKeyChecking`:

1. **ask**:

   - **Descripción**: Cuando se establece en `ask`, el cliente SSH pedirá confirmación al usuario si la clave del host del servidor no está en el archivo `known_hosts` o si la clave del servidor ha cambiado. Añade la Host Key del servidor SSH.
   - **Ejemplo de uso**: `StrictHostKeyChecking ask`

2. **yes**:

   - **Descripción**: Si se establece en `yes`, el cliente SSH rechazará automáticamente la conexión si la clave del host del servidor no está en el archivo `known_hosts` o si la clave del servidor ha cambiado. Nunca añade la Host Key del servidor SSH.
   - **Ejemplo de uso**: `StrictHostKeyChecking yes`

3. **no**:
   - **Descripción**: Cuando se establece en `no`, el cliente SSH aceptará automáticamente la clave del host del servidor sin pedir confirmación, incluso si la clave del servidor no está en el archivo `known_hosts` o si la clave ha cambiado. Añade la Host Key del servidor SSH.
   - **Ejemplo de uso**: `StrictHostKeyChecking no`

#### Verificar el fingerprint antes de aceptar la primera conexión

La seguridad de la primera conexión no la aporta SSH, sino el usuario. Cuando el cliente muestra el fingerprint y pregunta si continuar, responder `yes` a ciegas equivale a fiarse de un desconocido: para hacerlo bien hay que **obtener el fingerprint auténtico del servidor por un canal distinto** al de la propia conexión (fuera de banda) y compararlo antes de aceptar.

En nuestro laboratorio, donde el servidor es una máquina virtual a la que tenemos acceso directo por su consola, basta con entrar en ella (no por SSH) y pedirle su huella:

```bash
usuario@servidor:~$ ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
256 SHA256:3tIVYNy+hQ+hwK+HD+ToWa+/a4HgFPwfVFNWn9ldz+g root@servidor (ED25519)
```

Ese `SHA256:...` debe coincidir **carácter a carácter** con el que muestra el cliente al conectar. Si coinciden, el servidor es auténtico y se responde `yes`; si no, se responde `no` y no se establece la conexión.

> **Importante:** La comparación debe hacerse entre huellas del **mismo tipo de clave**. Un servidor tiene varias claves de host a la vez (RSA, ECDSA, Ed25519), así que hay que asegurarse de comparar la Ed25519 del cliente contra la Ed25519 del servidor, y no contra otra. Para ver todas de golpe en el servidor: `for k in /etc/ssh/ssh_host_*_key.pub; do ssh-keygen -lf "$k"; done`.

> **Nota:** Fuera del laboratorio, cuando no se tiene acceso directo a la máquina, el fingerprint legítimo se consigue por la vía de confianza que corresponda: la salida de consola de arranque en un servidor de un proveedor cloud, o pidiéndoselo al administrador que lo instaló por un medio seguro. En infraestructuras grandes puede automatizarse publicando la huella en un registro DNS firmado (SSHFP) y conectando con `ssh -o VerifyHostKeyDNS=yes servidor`.

Una vez guardada la clave, también se puede comprobar en cualquier momento que la entrada del `known_hosts` sigue correspondiendo con la del servidor. La opción `-F` (mayúscula) de `ssh-keygen` busca una entrada por su nombre de host, y combinada con `-l` muestra su fingerprint:

```bash
usuario@debian:~$ ssh-keygen -lF "[localhost]:2222"
# Host [localhost]:2222 found: line 4
[localhost]:2222 ED25519 SHA256:3tIVYNy+hQ+hwK+HD+ToWa+/a4HgFPwfVFNWn9ldz+g
```

Ese fingerprint debe coincidir con el que devuelve `ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub` en el servidor. Es exactamente la comprobación que SSH hace de forma automática en cada conexión posterior a la primera.

> **Nota:** Si en lugar del fingerprint se quiere cotejar la clave completa, se omite la `-l`: `ssh-keygen -F "[localhost]:2222"` imprime la línea del `known_hosts` con la clave en Base64, que debe ser idéntica a la parte `AAAA...` del fichero `/etc/ssh/ssh_host_ed25519_key.pub` del servidor.

Ejemplos de uso:

```bash
ssh -o StrictHostKeyChecking=no -o Port=9999 -l usuario 192.168.120.100
```

```bash
ssh -o StrictHostKeyChecking=no -p 9999 usuario@192.168.120.100
```

### 3.2 Redirección gráfica por SSH

El siguiente comando permitirá que nos conectemos por ssh y lanzará la aplicación xeyes en el cliente.

```bash
ssh -X usuario@192.168.120.101 xeyes
```

Existen una serie de variables que tienen que editarse en el servidor ssh para poder realizar este proceso. La configuración del servidor está en la ruta ` /etc/ssh/sshd_config`:

```bash
cat -n /etc/ssh/sshd_config | grep X11
    90  X11Forwarding yes
    91  X11DisplayOffset 10
    92  X11UseLocalhost yes
```

`X11Forwarding`: Directiva que determina si la redirección gráfica es posible mediante conexiones SSH. Solo puede tomar 2 valores: yes/no.

- `X11Forwarding no`: es el valor por defecto. Deshabilita la redirección gráfica del servidor SSH.
- `X11Forwarding yes`: Habilita la redirección gráfica del servidor SSH.

`X11DisplayOffset`: Directiva que determina el número del display donde espera el servidor gráfico. Por defecto es 10, para evitar interferencias con servidores X11 reales.

- `X11DisplayOffset 10`: es el valor por defecto. Indica el número de display donde espera el servidor gráfico para conexiones SSH.
- `X11DisplayOffset 100`: Indica el número de display 100 donde espera el servidor gráfico para conexiones SSH.

`X11UseLocalhost`: Directiva que determina si la redirección gráfica es posible en la dirección loopback o en cualquier dirección:

- `X11UseLocalhost yes`: es el valor por defecto. Permite la redirección gráfica a la dirección loopback y define la variable de entorno DISPLAY a localhost, lo cual previene conexiones remotas no permitidas al display.
- `X11UseLocalhost no`: Habilita la redirección gráfica a todas las interfaces de red.

### 3.3 Comando SSH + contraseña

Previamente se tendrá que instalar `sshpass` para poder hacer uso de esta utilidad. Una vez instalada podemos realizar la conexión en un único paso.

```bash
sshpass -p 'abc123.' ssh usuario@192.168.120.101
```

### 3.4 Cifrado asimétrico

Una conexión usando el protocolo SSH es de por sí segura (más segura que una conexión no cifrada, como telnet) pero la autenticación por contraseña presenta un inconveniente. Aunque la contraseña viaja cifrada por el túnel y no puede ser interceptada en la red, sigue siendo un secreto que el atacante puede intentar **adivinar**: mientras el servidor acepte contraseñas, queda abierta la posibilidad de ataques de fuerza bruta que prueban miles de combinaciones. Una contraseña fuerte limita el riesgo, pero no lo elimina.

Ante este desafío con SSH se creó un mecanismo de autentificación basado en desafío y en criptografía asimétrica. El cliente cuenta con una clave privada. La clave pública correspondiente se configura en todos los usuarios de servidores remotos que se van a autenticar con la misma clave privada. Ya en el proceso de autenticación el cliente envía información sobre su clave pública al servidor. El servidor busca si para el usuario requerido se ha instalado pública del cliente. Si la encuentra, se envía un desafío al cliente que consiste en un valor aleatorio cifrado con la clave pública del cliente. El cliente, para completar la autenticación satisfactoriamente, debe descifrar el desafío con su clave privada y devolver el valor al servidor. El servidor comprobará si el desafío se ha resuelto correctamente y permitirá el inicio de sesión si así ha sido.

Bajo este esquema de autenticación, un par de claves (pública/privada) permite la autentificación en todos los servidores. Como el desafío es aleatorio, un ataque de fuerza bruta es mucho más difícil. Estas son las principales ventajas de este mecanismo de autentificación. Generamos en el cliente el par de claves pública/privada en la ruta `~/.ssh/id_rsa`.

En primer lugar, el usuario creará su identidad digital generando el par de claves privada-pública. Como ya se explicó en la **criptografía asimétrica**, la clave privada debe mantenerse segura a toda costa, mientras que la pública puede distribuirse. La clave privada puede protegerse mediante una _passphrase_ (frase de contraseña), lo que significa que, al usarla, habrá que introducir dicha contraseña. Es importante señalar que, al escribir la _passphrase_, el texto no será visible en pantalla.

**Advertencia clave**:

- Si olvidas la _passphrase_, la clave privada no podrá utilizarse, ya que no se podrá descifrar. El cifrado que hace seguro el sistema SSH también hace que la clave sea irrecuperable. La solución en este caso sería generar una nueva clave y distribuir la nueva clave pública en los equipos remotos.

#### Uso de claves con y sin _passphrase_:

- **Con _passphrase_**: Es la opción más segura, ideal para uso personal.
- **Sin _passphrase_**: Útil para scripts automatizados, ya que no requiere intervención manual.

#### Comando `ssh-keygen`:

Para generar el par de claves, se utiliza el comando `ssh-keygen` con las siguientes opciones principales:

- **`-t `**: Especifica el tipo de clave (`ed25519`, `rsa`, `ecdsa`, etc.).
- **`-b `**: Define el tamaño de la clave (ejemplo: 4096 bits).
  - _Nota_: Estas claves solo se usan para autenticación, por lo que aumentar su tamaño no afectará al rendimiento de la CPU durante transferencias SSH.
- **`-C ""`**: Añade un comentario para identificar la clave (ejemplo: "clave_servidor").
- **`-f `**: Especifica la ruta y nombre de los archivos de claves (ejemplo: `~/.ssh/clave_personal`).

> **Recuerda:** Aunque los ejemplos de este documento usan claves **RSA** por ser las más extendidas históricamente, hoy la recomendación es generar claves **Ed25519**, con `ssh-keygen -t ed25519`. Son más cortas, más rápidas de verificar y criptográficamente más robustas que una RSA de tamaño equivalente. Solo conviene seguir usando RSA (de 4096 bits) si hay que conectarse a servidores muy antiguos que no admitan Ed25519.

#### Ejemplo de uso sin passphrase

```bash
ssh-keygen -t rsa -b 4096 -C "clave_para_servidor" -f ~/.ssh/clave_servidor
```

Este comando generará una clave RSA de 4096 bits con un comentario identificativo y la guardará en `~/.ssh/clave_servidor`.

```bash
┌──(kali㉿kaliA)-[~]
└─$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/home/kali/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
...
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

> **Advertencia:** Los permisos de estos ficheros en el servidor son **críticos** y su configuración incorrecta es la causa más frecuente de que la autenticación por clave "no funcione" sin dar ningún error claro. El servidor SSH se niega a fiarse de un `authorized_keys` que otros usuarios pudieran haber manipulado, así que si los permisos son demasiado abiertos **ignora la clave en silencio** y vuelve a pedir la contraseña. Los valores correctos son:
>
> ```bash
> kali@kali:~$ chmod 700 ~/.ssh
> kali@kali:~$ chmod 600 ~/.ssh/authorized_keys
> ```
>
> Es decir, el directorio `~/.ssh` accesible solo por su dueño (`700`) y el fichero `authorized_keys` legible y escribible solo por él (`600`). La herramienta `ssh-copy-id` los ajusta correctamente por sí sola; el problema surge al copiar la clave a mano.

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

> **Nota:** En algunas veces podemos hacer el proceso inverso de conectarnos a un servidor haciendo uso de la clave privada para lo que se usa `ssh -i ~/.ssh/id_rsa usuario@servidor_remoto`.

#### Ejemplo de uso con passphrase

Si hubieramos introducido un _passphrase_ se nos hubiera pedido a la hora de hacer ssh tal y como se ve en este ejemplo. Como dijimos el _passphrase_ en SSH es una contraseña opcional que se utiliza para proteger tu clave privada. Su utilidad principal es añadir una capa extra de seguridad: aunque alguien obtenga acceso a tu ordenador y copie tu clave privada, no podrá usarla para autenticarse en servidores remotos sin conocer la _passphrase_. En este tendremos dos máquinas, una máquina cliente con el usuarioA y otra máquina servidor a la que nos conectamos con el usuarioB.

El usuarioA en la máquina cliente genera el par de claves con el passphrase, comparte la clave y se conecta a máquinaB.

```bash
usuarioA@debian:~$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/usuarioA/.ssh/id_rsa):
Created directory '/home/usuarioA/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
...

usuarioA@debian:~$ ssh-copy-id -i .ssh/id_rsa.pub usuarioB@192.168.100.3
...
Now try logging into the machine, with:   "ssh 'usuarioB@192.168.100.3'"
and check to make sure that only the key(s) you wanted were added.

usuarioA@debian:~$ ssh usuarioB@192.168.100.3
Enter passphrase for key '/home/usuarioA/.ssh/id_rsa':
...

usuarioB@debian:~$ whoami
usuarioB
```

En el servidor, para el usuarioB, se crea la ruta `~/.ssh/authorized_keys` con la información de la clave **pública** compartida por el usuarioA (nunca la privada, que jamás sale de la máquina cliente).

```bash
usuarioB@debian:~$ cat .ssh/authorized_keys
ssh-rsa AAAAB...m10= usuarioA@usuario
```

#### Uso de ssh-agent

**ssh-agent** es un manejador de claves para SSH, es decir, mantiene las passphrases privadas en memoria, descifradas y listas para usarse. Esto nos facilita el hecho de utilizar dichas claves sin necesidad de cargarlas y descifrarlas (en el caso de que hayamos seteado una passphrase) cada vez que vayamos a usarlas. Principalmente aporta:

- **Seguridad**: utilizar una passphrase para la clave es más seguro que utilizar solamente una password, más si alguien se hace con nuestra computadora. De hecho sería conveniente establecer una passphrase a la hora de generar la clave privada.
- **Comodidad**: A nivel práctico, _ssh-agent_ nos permite no tener que volver a introducir la passphrase cada vez que usamos la clave privada. Puede parecer contradictorio establecer una passphrase para añadir seguridad y luego usar un mecanismo que la almacene en memoria, evitando tener que introducirla repetidamente. Sin embargo, esto tiene sentido en escenarios como Ansible, donde un nodo central realiza tareas en cientos de máquinas dependientes. No usar passphrase es poco seguro, pero tener que introducirla en cada conexión puede ser muy engorroso. Por eso, se utiliza _ssh-agent_, que ofrece un equilibrio entre seguridad y comodidad.

Desde el punto de vista del servidor SSH, el protocolo funciona de la siguiente manera (muy breve y resumido):

- El cliente le da su clave pública.
- El servidor genera un mensaje denominado Key Challenge, y lo envía al cliente para realizar la verificación de identidad.
- El cliente usa la clave privada para realizar la verificación, y responde al servidor.
- El servidor constata la veracidad del Key Challenge del cliente.
- El servidor ahora sabe que el cliente es quien dice ser y establece el túnel.
- Luego de esto se generan claves simétricas efímeras para el intercambio de tráfico cifrado.

Los principales comandos a emplear son los siguientes.

El comando `eval $(ssh-agent)` se usa para iniciar el agente SSH (ssh-agent) y configurar el entorno para que las claves SSH puedan utilizarse sin necesidad de ingresar la contraseña en cada conexión. Para detener su funcionamiento se hace uso del comando `eval $(ssh-agent -k)`.

```bash
eval $(ssh-agent)
eval $(ssh-agent -k)
```

Ahora cuando se ejecuta `eval $(ssh-agent)` se pedira el password del certificado que se guradara en la variable ssh-agent. Podemos establecer el tiempo que queremos que se guarde o que sea de forma continua hasta detener el uso con `eval $(ssh-agent -k)`.

```bash
ssh-add -t 1800 # 1800 seconds
ssh-add -t 45m # 45 minutes
ssh-add -t 3h42 # 3 hours 42 minutes

##Nuestro laboratorio este comando me pide el pass de la llave privada y la guarda en el ssh-agent:
ssh-add /root/.ssh/id_rsa
ssh-add -t 45m /root/.ssh/id_rsa # 45 minutes
ssh-add -t 2m /root/.ssh/id_rsa # 2 minutes
```

A continuación recogemos el procedimiento de _ssh-agent_ en el excenario de usuarioA y usuarioB.
En usuarioA generamos el par de claves y compartimos la clave pública con el servidor.

```bash
usuarioA@debian:~$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/usuarioA/.ssh/id_rsa):
Created directory '/home/usuarioA/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
...

usuarioA@debian:~$ ssh-copy-id -i .ssh/id_rsa.pub usuarioB@192.168.100.3
Number of key(s) added: 1
...
```

Ejecutamos el comando `eval $(ssh-agent)` para realizar el procedimiento, decimos que queremos que se almacene el passphrase por tiempo indefinido y realizamos la conexión. A continuación detenemos el procedimiento con `eval $(ssh-agent -k)`. Tambien podríamos realizar este procedimiento por un tiempo determinado.

```bash
usuarioA@debian:~$ eval $(ssh-agent)
Agent pid 5934

usuarioA@debian:~$ ssh-add .ssh/id_rsa
Enter passphrase for .ssh/id_rsa:
Identity added: .ssh/id_rsa (usuarioA@usuario)

usuarioA@debian:~$ ssh usuarioB@192.168.100.3
...

usuarioB@debian:~$ whoami
usuarioB
```

```bash
usuarioA@debian:~$ eval $(ssh-agent -k)
Agent pid 5934 killed

usuarioA@debian:~$ ssh usuarioB@192.168.100.3
Enter passphrase for key '/home/usuarioA/.ssh/id_rsa':

usuarioB@debian:~$ whoami
usuarioB
```

Como punto final supongamos que tenemos un conjunto de máquinas que dependen de nuestro par de claves y necesitamos cambiar el passphrase y no queremos volver a generar un nuevo par de claves, podemos solucionar esto de la siguiente forma. En resumen:

- Si tu clave privada actual no tiene contraseña, puedes añadirle una.
- Si ya tiene una contraseña, puedes cambiarla o eliminarla.

Permite poner clave o cambiar una clave al certificado privado.

```bash
ssh-keygen -p -f <ruta al fichero de la clave privada id_rsa>
```

Estas opciones permiten lo siguiente:

- -p: Indica que quieres cambiar el passphrase.
- -f: Especifica el archivo de clave privada que quieres modificar (por ejemplo ~/.ssh/id_rsa).

```bash
usuarioA@debian:~$ ssh-keygen -p -f .ssh/id_rsa
Enter old passphrase:
Key has comment 'usuarioA@usuario'
Enter new passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved with the new passphrase.
```

### 3.5 Práctica guiada: conexión por clave desde Windows a una máquina virtual

Los ejemplos anteriores usan dos máquinas Linux. En la práctica es muy frecuente administrar desde un **Windows** una **máquina virtual** Linux, y ese escenario tiene un par de particularidades que causan mucha confusión al empezar. Esta sección lo resuelve paso a paso.

El escenario es el habitual en el aula: un cliente **Windows 11**, y como servidor una **VM de VirtualBox en modo NAT** con una regla de **reenvío de puertos** que envía el puerto `2222` del equipo Windows al puerto `22` de la VM. Por eso, desde Windows, el servidor se alcanza como `localhost:2222`. El objetivo es entrar sin escribir la contraseña cada vez.

#### La idea que hay que tener clara antes de empezar

Es la fuente de casi todos los tropiezos, así que conviene fijarla:

> **El par de claves se genera en el equipo desde el que te conectas (Windows), no en el servidor.** La clave **privada se queda siempre en Windows** y no sale de ahí; solo la clave **pública** viaja al servidor.

Sirve la analogía del candado y la llave:

- **Clave pública** = un **candado**. No es secreto, se reparte. Se **coloca en la puerta del servidor** (dentro de `~/.ssh/authorized_keys`).
- **Clave privada** = la **llave**. Es secreta, **se queda en el cliente** (Windows).

Para entrar sin contraseña hacen falta las dos cosas: la llave en tu bolsillo (Windows) y el candado puesto en la puerta (el servidor). Tener una copia suelta del candado (el fichero `.pub`) en el cliente no abre nada.

| Pieza | Se genera en | Debe quedar en | Función |
|---|---|---|---|
| Clave privada (`id_ed25519`) | Windows | **Windows** | La llave. Nunca se mueve. |
| Clave pública (`id_ed25519.pub`) | Windows | El **servidor**, en `~/.ssh/authorized_keys` | El candado. Se copia una vez. |

> **Advertencia:** El error más común es generar el par **en la VM** pensando que "las claves van en el servidor". Si se hace así, la llave (la privada) queda en el sitio equivocado y no sirve para conectarse desde Windows. Ante la duda, se empieza de cero generando el par en Windows, como se explica a continuación.

#### Paso 1: generar el par de claves en Windows

Windows 10 y 11 incluyen el cliente OpenSSH, de modo que `ssh` y `ssh-keygen` funcionan directamente en **PowerShell**. Se genera el par con:

```powershell
PS C:\Users\usuario> ssh-keygen -t ed25519 -C "Clave para el servidor desde Windows"
```

El programa hace tres preguntas:

- **`Enter file in which to save the key`**: se pulsa **Intro** para aceptar la ruta por defecto (`C:\Users\usuario\.ssh\id_ed25519`).
- **`Enter passphrase`**: la frase de contraseña que protege la clave. Se trata en el apartado siguiente; para una primera prueba se puede dejar vacía pulsando **Intro**.
- **`Enter same passphrase again`**: se repite (o **Intro** de nuevo si se dejó vacía).

El resultado son **dos ficheros** nuevos en `C:\Users\usuario\.ssh\`:

| Fichero | Qué es |
|---|---|
| `id_ed25519` | La clave **privada** (la llave). Se queda en Windows. |
| `id_ed25519.pub` | La clave **pública** (el candado). Es la que se copiará al servidor. |

#### La passphrase: qué es y si conviene ponerla

La **passphrase** es una contraseña que **cifra la clave privada en el disco**. Si se le pone, el fichero `id_ed25519` queda protegido: aunque alguien consiga ese fichero, no puede usarlo sin conocer la passphrase. Siguiendo la analogía, es la **caja fuerte con combinación donde se guarda la llave**.

Es importante no confundirla con la contraseña del usuario del servidor, porque son cosas totalmente distintas:

| | Contraseña del usuario (del servidor) | Passphrase de la clave |
|---|---|---|
| Qué protege | La cuenta de usuario en la VM | El fichero de clave privada en Windows |
| Dónde vive | En el servidor | Solo en tu equipo; **nunca viaja** |
| ¿La conoce el servidor? | Sí | **No.** El servidor ni se entera de que la clave tiene passphrase |

El detalle clave es que la passphrase **no viaja a ningún sitio** y se resuelve **en el cliente**, antes de contactar con el servidor. Es una capa de seguridad **añadida** sobre la llave, no un sustituto de nada.

| | Sin passphrase | Con passphrase |
|---|---|---|
| Comodidad | Entra sola | Hay que introducirla |
| Seguridad | Si roban el fichero de la llave, entran en el servidor | Si roban el fichero, no pueden usarlo |
| Recomendada para | Automatización (`cron`, `rsync`), laboratorio de aula | Claves personales, portátiles, equipos compartidos |

> **Advertencia:** La passphrase **no se puede recuperar**. Si se olvida, la clave privada queda inservible y hay que generar un par nuevo y volver a copiar la pública al servidor. Es el comportamiento buscado: sin ella, la llave no se puede descifrar.

> **Nota:** Poner passphrase no obliga a teclearla en cada conexión. El **agente** de claves la pide una sola vez por sesión y mantiene la llave descifrada en memoria el resto del tiempo. En Windows se activa arrancando el servicio `ssh-agent` (como administrador, `Start-Service ssh-agent`) y añadiendo la clave con `ssh-add`, tal como se detalla al final de esta sección.

#### Paso 2: copiar la clave pública al servidor

Ahora hay que colocar el candado (`id_ed25519.pub`) en la puerta de la VM, es decir, añadirlo a su fichero `~/.ssh/authorized_keys`.

> **Nota:** En Linux esto se haría con `ssh-copy-id`, pero **el cliente OpenSSH de Windows no incluye esa herramienta**. Por eso en PowerShell se hace de forma manual con el comando siguiente, que es exactamente el equivalente: coge la clave pública, la añade a `authorized_keys` del servidor y ajusta los permisos.

```powershell
PS C:\Users\usuario> type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh -p 2222 usuario@localhost "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
usuario@localhost's password:
```

Este comando **pedirá la contraseña del usuario**, y esta es **la última vez** que hará falta. El motivo es que esa conexión todavía se autentica por contraseña, porque en ese instante la clave aún no está instalada en el servidor; y es precisamente esa conexión la que la deja puesta. Desglosado:

| Parte | Qué hace | Dónde |
|---|---|---|
| `type ...\id_ed25519.pub` | Muestra el contenido de la clave pública. | Windows |
| `\|` | Envía esa clave como entrada al comando siguiente. | Windows |
| `ssh -p 2222 usuario@localhost "..."` | Ejecuta en la VM lo que va entre comillas. | VM |
| `mkdir -p ~/.ssh && chmod 700 ~/.ssh` | Crea la carpeta `.ssh` con permisos correctos. | VM |
| `cat >> ~/.ssh/authorized_keys` | Añade la clave recibida al final de `authorized_keys`. | VM |
| `chmod 600 ~/.ssh/authorized_keys` | Ajusta los permisos del fichero. | VM |

#### Paso 3: conectarse sin contraseña

```powershell
PS C:\Users\usuario> ssh -p 2222 usuario@localhost
```

Ahora debe entrar **sin pedir la contraseña**. No hace falta indicar la clave con `-i`, porque `ssh` busca `id_ed25519` por su nombre de forma automática.

La razón de que ya no pida contraseña es que se cumplen a la vez las dos condiciones: el servidor tiene tu candado (en `authorized_keys`) y tu cliente tiene la llave (`id_ed25519`). En cada conexión, el servidor lanza un **reto** que solo la clave privada puede resolver; el cliente lo responde con la llave y el servidor lo verifica con el candado. Todo ello de forma automática e instantánea, sin escribir nada.

#### Comodidades finales

**Un alias para no repetir puerto ni usuario.** En el fichero `C:\Users\usuario\.ssh\config` (créalo si no existe) se puede definir:

```text
Host servidor
    HostName localhost
    Port 2222
    User usuario
    IdentityFile ~/.ssh/id_ed25519
```

A partir de ahí basta con `ssh servidor`, y el alias lo aprovechan también `scp` y `sftp`.

**El agente, si pusiste passphrase.** Para introducirla una sola vez por sesión en lugar de en cada conexión:

```powershell
PS C:\Users\usuario> Start-Service ssh-agent          # una vez, como administrador
PS C:\Users\usuario> ssh-add $env:USERPROFILE\.ssh\id_ed25519
```

#### Errores frecuentes

- **Sigue pidiendo la contraseña tras el Paso 2.** Casi siempre es por permisos en la VM: `~/.ssh` debe ser `700` y `~/.ssh/authorized_keys` debe ser `600`. El comando del Paso 2 ya los ajusta, pero si la clave se copió a mano conviene revisarlos. Si la tubería del Paso 2 diera problemas de codificación, la alternativa infalible es mostrar la pública con `Get-Content` y pegarla a mano al final de `~/.ssh/authorized_keys` en la VM.
- **Descargar el `.pub` al cliente no autentica nada.** Copiar un fichero `.pub` al equipo Windows no tiene ningún efecto sobre el acceso: la pública solo cumple su función cuando está en el `authorized_keys` del **servidor**, y quien autentica es la **privada** que ya está en el cliente.
- **Confundir la passphrase con la contraseña del servidor.** Si al conectar te piden algo tras poner claves, fíjate en el texto: `Enter passphrase for key` es tu passphrase (local, descifra la llave); `usuario@localhost's password` es la contraseña de la cuenta (señal de que la clave todavía no está bien instalada).

### 3.6 Diferencia entre known_hosts y authorized_keys

A lo largo de esta sección han aparecido dos ficheros que se confunden constantemente, porque los dos guardan **claves públicas** y los dos sirven para **autenticar**. La diferencia es que cumplen funciones **opuestas** y viven en **lados opuestos** de la conexión: el `known_hosts` se ha visto en el apartado 3.1 (verificación del servidor mediante su *fingerprint*) y el `authorized_keys` en los apartados 3.4 y 3.5 (acceso del usuario mediante su clave).

| | `known_hosts` | `authorized_keys` |
|---|---|---|
| ¿Dónde está? | En el **cliente** (`~/.ssh/known_hosts`) | En el **servidor** (`~/.ssh/authorized_keys` del usuario) |
| ¿Qué claves guarda? | Las públicas de los **servidores** a los que el cliente se ha conectado | Las públicas de los **usuarios** a los que el servidor permite entrar |
| ¿Quién verifica a quién? | El **cliente** comprueba que el **servidor** es auténtico | El **servidor** comprueba que el **cliente** está autorizado |
| Responde a la pregunta | "¿Confío en este servidor?" | "¿Dejo entrar a este usuario sin contraseña?" |
| ¿Cómo se rellena? | Automáticamente, al aceptar `yes` en la primera conexión | Manualmente, al copiar la clave pública (con `ssh-copy-id` o el método equivalente) |

#### Las dos mitades de una verificación mutua

Ambos ficheros son las dos caras de una misma moneda: en SSH, cliente y servidor se verifican **el uno al otro**, y cada uno se apoya en su propio fichero.

- El **servidor** demuestra su identidad al cliente, que la comprueba contra su `known_hosts` (es el *fingerprint* del apartado 3.1).
- El **cliente** demuestra su identidad al servidor, que la comprueba contra su `authorized_keys` (es el acceso por clave del apartado 3.5).

La clave para no confundirlos es entender que en juego hay **dos pares de claves distintos**:

| Par de claves | Se genera en | Su clave pública se guarda en | Sirve para verificar al |
|---|---|---|---|
| **Del host** (propio del servidor) | El servidor, al instalar OpenSSH | El `known_hosts` del cliente | **Servidor** |
| **De usuario** (propio de quien se conecta) | El cliente, con `ssh-keygen` | El `authorized_keys` del servidor | **Cliente** |

Con la analogía del candado y la llave usada en el apartado 3.5:

- El `known_hosts` guarda el **candado del servidor**, que el cliente usa para reconocerlo y evitar que se lo suplanten.
- El `authorized_keys` guarda **el candado del usuario**, que el servidor usa para reconocerlo y dejarlo pasar.

> **Recuerda:** En una frase, **`known_hosts` protege al cliente de servidores falsos, y `authorized_keys` permite al servidor reconocer clientes legítimos**. Los dos usan claves públicas, pero uno mira "hacia fuera" (yo verifico al servidor) y el otro "hacia dentro" (el servidor me verifica a mí).

## 4. scp

### 4.1 scp de máquina A a B indicado desde máquina C

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

### 4.2 Ejemplos de uso curiosos y cuestiones a considerar

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

## 5. Fichero de configuración del cliente (~/.ssh/config)

Escribir cada vez el usuario, el puerto y la ruta de la clave resulta tedioso cuando se administran varios servidores. El fichero `~/.ssh/config` permite guardar esos parámetros bajo un alias y conectarse con una sola palabra.

```bash
# ~/.ssh/config
Host web
    HostName 192.168.33.10
    User admin
    Port 2222
    IdentityFile ~/.ssh/id_ed25519_web

Host *.curso.local
    User operador
    ForwardX11 yes
```

Con esa configuración, `ssh web` equivale a `ssh -p 2222 -i ~/.ssh/id_ed25519_web admin@192.168.33.10`. El alias también lo aprovechan `scp`, `sftp` y `rsync`, de modo que `scp fichero web:/tmp/` funciona sin repetir nada.

| Directiva | Función |
|---|---|
| `Host` | Alias que se teclea al conectar. Admite comodines (`*`, `?`). |
| `HostName` | Dirección o nombre real del servidor. |
| `User` | Usuario con el que conectar. |
| `Port` | Puerto del servicio SSH. |
| `IdentityFile` | Clave privada que se usará para este servidor. |
| `ProxyJump` | Servidor intermedio a través del cual saltar para alcanzar el destino. |
| `ServerAliveInterval` | Segundos entre señales que mantienen viva la conexión, para que no se corte por inactividad. Un valor de `30` suele ser suficiente. |
| `Compression` | Con valor `yes`, comprime el tráfico. Útil en enlaces lentos. |

> **Nota:** `ProxyJump` (o la opción `-J` en la línea de órdenes) resuelve el caso habitual de tener que atravesar un servidor puente para llegar a una máquina interna: `ssh -J puente interno` abre la conexión final en un solo paso, sin necesidad de conectarse primero al puente y desde ahí al destino.

> **Recuerda:** La directiva `ServerAliveInterval` resuelve una molestia muy habitual: que una sesión SSH se cierre sola con el mensaje `broken pipe` tras unos minutos sin teclear, por culpa de cortafuegos o *routers* que descartan las conexiones inactivas. Ponerla en `~/.ssh/config` para todos los servidores evita el problema de una vez:
>
> ```bash
> Host *
>     ServerAliveInterval 30
> ```

---

## 6. Endurecimiento del servidor SSH

El servicio SSH es, por su propia naturaleza, uno de los principales objetivos de ataque de un servidor expuesto a Internet, que recibe intentos de acceso automatizados de forma constante. Su configuración reside en `/etc/ssh/sshd_config` y conviene revisar al menos estas directivas:

| Directiva | Valor recomendado | Motivo |
|---|---|---|
| `PermitRootLogin` | `no` | Impide el acceso directo como `root`. Obliga a entrar con un usuario normal y escalar después con `sudo`, lo que deja rastro en `/var/log/auth.log`. |
| `PasswordAuthentication` | `no` | Desactiva las contraseñas y exige autenticación por clave, inmune a los ataques de fuerza bruta. |
| `Port` | distinto de `22` | Cambiarlo no aporta seguridad real, pero reduce drásticamente el ruido de los escaneos automatizados. |
| `AllowUsers` / `AllowGroups` | la lista necesaria | Restringe quién puede conectarse, en lugar de permitir a cualquier cuenta del sistema. |
| `X11Forwarding` | `no` salvo que se use | Reduce la superficie de ataque desactivando la redirección gráfica. |

> **Advertencia:** Antes de reiniciar `sshd` tras cambiar su configuración, conviene validarla con `sshd -t`, que detecta errores de sintaxis. Un fallo aquí puede dejar el servicio sin arrancar y, en un servidor remoto, cerrar la única vía de acceso. Por el mismo motivo, es prudente **mantener abierta la sesión actual** y comprobar el acceso desde una segunda terminal antes de cerrarla:
>
> ```bash
> root@debian:~# sshd -t && systemctl restart ssh
> ```

> **Recuerda:** Tras deshabilitar `PasswordAuthentication` es imprescindible haber copiado antes la clave pública al servidor con `ssh-copy-id usuario@servidor`. De lo contrario, al reiniciar el servicio se pierde el único método de acceso que quedaba.

---

## 7. Túneles SSH y reenvío de puertos

La sección 1 adelantaba que SSH puede usarse como "una VPN ligera". Esa capacidad son los **túneles SSH** o **reenvío de puertos** (*port forwarding*): la conexión cifrada que ya hemos establecido con un servidor se aprovecha para transportar **otro** tráfico de red por dentro, de forma segura. Es una de las funciones más potentes de SSH y, a la vez, una de las menos conocidas, porque en línea de comandos se activa con una sola opción que pasa desapercibida.

El problema que resuelve se entiende con un caso muy habitual: un servidor tiene una base de datos, un panel de administración o cualquier servicio que, **por seguridad, solo escucha en `localhost`** y no es accesible desde la red. Un túnel permite alcanzar ese servicio interno desde nuestro equipo, a través del canal cifrado de SSH, sin necesidad de exponerlo a la red ni de montar una VPN completa.

Hay tres modalidades, que se corresponden con tres opciones del comando `ssh`:

| Opción | Nombre | Qué hace |
|---|---|---|
| `-L` | Reenvío **local** | Un puerto de **mi equipo** se conecta, por el túnel, a un servicio accesible desde el servidor. |
| `-R` | Reenvío **remoto** | Un puerto del **servidor** se conecta, por el túnel, a un servicio de mi equipo. |
| `-D` | Reenvío **dinámico** | Convierte SSH en un **proxy SOCKS**: todo el tráfico que se le envíe sale a la red por el servidor. |

### 7.1 Reenvío local (`-L`)

Es el más utilizado. La sintaxis es `ssh -L puerto_local:destino:puerto_destino usuario@servidor`, donde el `destino` se interpreta **desde el punto de vista del servidor**.

Retomando el ejemplo de una base de datos MySQL que solo escucha en el `localhost` del servidor (puerto 3306):

```bash
usuario@debian:~$ ssh -L 3306:localhost:3306 usuario@192.168.1.10
```

Mientras esa conexión SSH permanezca abierta, cualquier programa de **nuestro** equipo que se conecte a `localhost:3306` estará hablando en realidad, a través del túnel cifrado, con el MySQL interno del servidor. Para el programa cliente es indistinguible de tener la base de datos en la propia máquina.

El `destino` no tiene por qué ser el propio servidor: puede ser una **tercera máquina** alcanzable desde él pero no desde nosotros. Este es el patrón del servidor puente:

```bash
usuario@debian:~$ ssh -L 8080:servidor-interno:80 usuario@puente
```

Aquí el puente es la única máquina accesible, y el túnel nos da acceso al puerto 80 de `servidor-interno`, que vive en la red interna, escribiendo `http://localhost:8080` en nuestro navegador.

> **Nota:** Por defecto, el puerto local que abre `-L` solo escucha en el `localhost` de nuestro equipo, de modo que únicamente nosotros podemos usar el túnel. Es lo deseable casi siempre. Si se quisiera compartir el túnel con otros equipos de la red local, se antepondría una dirección: `ssh -L 0.0.0.0:8080:servidor-interno:80 ...`, algo que conviene hacer con cuidado por sus implicaciones de seguridad.

### 7.2 Reenvío remoto (`-R`)

Es el inverso del anterior: abre un puerto en el **servidor** que redirige hacia un servicio de **nuestro** equipo. La sintaxis es `ssh -R puerto_remoto:destino_local:puerto_local usuario@servidor`.

Sirve, por ejemplo, para que un servidor que no puede conectarse a nuestra máquina (porque estamos detrás de un router doméstico) pueda alcanzar temporalmente un servicio que tenemos levantado en local:

```bash
usuario@debian:~$ ssh -R 9000:localhost:3000 usuario@servidor.publico
```

Con esto, quien se conecte al puerto 9000 del servidor público llegará, por el túnel, al servicio que corre en el puerto 3000 de nuestro equipo.

### 7.3 Reenvío dinámico (`-D`): un proxy SOCKS

El túnel dinámico es el más versátil. En lugar de reenviar un puerto concreto a un destino fijo, convierte a SSH en un **proxy SOCKS** que decide el destino sobre la marcha según lo que le pida cada aplicación:

```bash
usuario@debian:~$ ssh -D 1080 usuario@servidor
```

A partir de ahí, si se configura un navegador (u otra aplicación) para usar `localhost:1080` como proxy SOCKS, **toda su navegación** saldrá cifrada por el túnel y aparecerá en internet con la IP del servidor. Es la forma más sencilla de acceder de forma segura a los recursos internos de una red remota, o de proteger el tráfico cuando se está en una red no confiable.

### 7.4 Opciones útiles para túneles

Cuando solo interesa el túnel y no una terminal, se combinan dos opciones ya vistas en el resumen de la sección siguiente:

| Opción | Efecto |
|---|---|
| `-N` | No ejecuta ningún comando ni abre terminal; solo mantiene el túnel. |
| `-f` | Envía SSH a segundo plano tras autenticarse. |

La combinación habitual para levantar un túnel "en silencio" que se quede de fondo es `-fN`:

```bash
usuario@debian:~$ ssh -fN -L 3306:localhost:3306 usuario@192.168.1.10
```

> **Recuerda:** Un túnel solo existe mientras vive la conexión SSH que lo transporta. Al cerrar esa conexión (o el terminal, si no se usó `-f`), el túnel desaparece y el puerto local deja de funcionar. Para localizar y cerrar un túnel lanzado con `-fN`, se busca su proceso con `pgrep -a ssh` y se termina con `kill` (documento 22).

> **Nota:** Todo lo anterior se hace en línea de comandos, pero es exactamente lo que la sección dedicada a PuTTY configura de forma gráfica en `Connection > SSH > Tunnels`. Ver el mismo túnel montado de las dos formas, por comando y por interfaz, ayuda a entender que no son cosas distintas: PuTTY solo traduce estos parámetros a una ventana.

---

## 8. Resumen: ssh, scp y sftp

OpenSSH proporciona en un mismo paquete el servicio (`sshd`) y los clientes de los tres protocolos que comparten el transporte seguro de SSH. Conviene tener clara la función de cada uno:

### 8.1 ssh

_ssh_ (Secure Shell) es un protocolo y herramienta en Linux y otros sistemas operativos que permite realizar conexiones remotas seguras a otros sistemas. SSH cifra la conexión, protegiendo la transferencia de datos y la comunicación, lo que lo convierte en la opción preferida para administración remota de servidores, ejecución de comandos remotos, transferencia de archivos segura, y más.

```bash
ssh usuario@maquina.curso.local
ssh operador@192.168.1.5
ssh root@192.168.1.5
ssh 192.168.33.150
ssh -p 52341 juan@192.168.70.99
```

Opciones comunes de ssh:

| Parámetro | Definición |
|-----------|------------|
| `-i` | Especifica un archivo de clave privada para la conexión. |
| `-N` | No ejecuta ningún comando; solo establece la conexión (útil para túneles). |
| `-T` | Deshabilita la asignación de pseudo-terminal (para ejecutar comandos simples). |
| `-f` | Envía la conexión al background después de la autenticación (útil para túneles persistentes). |
| `-v` | Activa el modo de depuración (verboroso), útil para solucionar problemas de conexión. |
| `-p puerto` | Indica el número de puerto al que se debe conectar. |

### 8.2 scp

_scp_ (Secure Copy Protocol) es una herramienta de línea de comandos en Linux y Unix que permite copiar archivos y directorios entre un sistema local y un servidor remoto, o entre dos servidores remotos, utilizando una conexión segura mediante SSH. scp cifra los datos en tránsito, protegiendo la transferencia de archivos frente a accesos no autorizados.

- scp /root/algo.txt operador@192.168.70.99:/home/operador

Para que funcione la orden primero tenemos que colocar el puerto antes del fichero a copiar:

```bash
scp  -P 52341 algo.txt  operador@192.168.70.99:/home/operador
scp  -p -P 52341 algo.txt   192.168.70.99:/home/operador
```

Esto no funcionaria:

```bash
scp algo.txt -P 52341   operador@192.168.70.99:/home/operador
```

Donde Ejemplos-scrpts es un directorio:

```bash
scp -r Ejemplos-scrpts vagrant@192.168.33.10:/tmp
```

Opciones comunes de scp:

| Parámetro | Definición |
|-----------|------------|
| `-r` | Copia directorios de manera recursiva. |
| `-P` | Especifica el puerto SSH a utilizar. |
| `-C` | Habilita la compresión para acelerar la transferencia (útil para archivos grandes). |
| `-i` | Especifica un archivo de clave privada diferente para la autenticación. |
| `-v` | Activa el modo verboroso para obtener información adicional sobre la transferencia (útil para depuración). |
| `-p` | Preserva los permisos, marcas de tiempo y la propiedad del archivo o directorio al copiarlo al destino. Esto es útil cuando deseas mantener la integridad de los atributos del archivo original, como la hora de creación y modificación, permisos y el propietario. |

### 8.3 sftp

_SFTP_ (SSH File Transfer Protocol) es un protocolo de transferencia de archivos que utiliza una conexión segura mediante SSH. A diferencia de FTP, SFTP cifra tanto la autenticación como la transmisión de datos, lo que lo hace adecuado para transferencias de archivos seguras en redes inseguras.

```bash
sftp usuario@servidor
sftp -o Port=52341 juan@192.168.70.99
```

Opciones comunes de SFTP:

| Parámetro | Definición |
|-----------|------------|
| `-i ruta/a/clave` | Usa una clave SSH específica para la autenticación. |
| `-b archivo` | Ejecuta un conjunto de comandos desde un archivo de texto. |
| `-C` | Activa la compresión durante la transferencia para archivos grandes |
| `-o Port=52341` | Especifica el puerto en el que el servidor SSH escucha las conexiones. Esto es útil cuando el servidor SSH no está en el puerto predeterminado (22). |

```bash
usuarioA@debian:~$ sftp usuarioB@192.168.100.3
...
sftp> ls
carpeta      fichero.txt  snap
sftp> get -r carpeta/
Fetching /home/usuarioB/carpeta/ to carpeta
Retrieving /home/usuarioB/carpeta
ficheroCarpeta.txt                                                                                                                                                             100%   60     5.0KB/s   00:00
sftp> get fichero.txt
Fetching /home/usuarioB/fichero.txt to fichero.txt
fichero.txt                                                                                                                                                                    100%   60    10.3KB/s   00:00
sftp> exit

usuarioA@debian:~$ ls -l
total 12
drwxrwxr-x 2 usuarioA usuarioA 4096 may 15 10:45 carpeta
-rw-rw-r-- 1 usuarioA usuarioA   60 may 15 10:45 fichero.txt
drwx------ 3 usuarioA usuarioA 4096 may 15 10:38 snap
```

---

## 9. Práctica: los retos Bandit

Para practicar SSH y los comandos básicos de la línea de órdenes de forma guiada, el *wargame* **OverTheWire Bandit** es un recurso excelente. Su resolución completa, de los niveles 0 a 33, se recoge en un documento aparte de estos apuntes: [Retos de SSH: OverTheWire Bandit](41_Retos_Bandit_OverTheWire.md).

---

## 10. Uso de PuTTY como cliente SSH en Windows

Todo lo visto hasta aquí se ha hecho desde una terminal de Linux, donde el cliente `ssh` viene de serie. Pero en muchos entornos reales el equipo desde el que administramos es un **Windows**, y ahí la herramienta clásica para conectarse por SSH es **PuTTY**: un cliente gratuito, ligero y que no necesita instalación. Aprender a manejarlo es útil porque es lo que encontraremos en la mayoría de las empresas, y porque su interfaz gráfica hace visibles y accesibles funciones de SSH que en línea de comandos pasan desapercibidas, como los túneles.

PuTTY no es un único programa, sino una **suite** de varias utilidades que conviene conocer desde el principio:

| Programa | Para qué sirve | Equivalente en Linux |
|---|---|---|
| `putty.exe` | El cliente de terminal SSH. Es el programa principal. | `ssh` |
| `puttygen.exe` | Genera y convierte pares de claves pública/privada. | `ssh-keygen` |
| `pageant.exe` | Guarda las claves descifradas en memoria (agente). | `ssh-agent` |
| `pscp.exe` | Copia ficheros por SSH desde la línea de órdenes de Windows. | `scp` |
| `psftp.exe` | Sesión interactiva de transferencia de ficheros. | `sftp` |

> **Nota:** Todo lo que se explica en este apartado se apoya en los conceptos ya vistos: PuTTY no inventa nada nuevo, sino que pone una interfaz gráfica sobre el mismo protocolo SSH. El aviso de la clave del host es el `StrictHostKeyChecking` de la sección 3.1, las claves de PuTTYgen son las de la sección 3.4, y Pageant es el `ssh-agent`. Conviene tenerlo presente para reconocer cada pieza.

### 10.1 Instalación

PuTTY se descarga desde su página oficial, `https://www.putty.org`, que redirige al sitio del autor. Hay dos formas de obtenerlo:

- **El instalador `.msi`** (recomendado para el aula): instala toda la suite (PuTTY, PuTTYgen, Pageant, pscp y psftp) y la añade al menú de inicio.
- **El ejecutable suelto `putty.exe`**: no necesita instalación, se ejecuta con doble clic y se puede llevar en un pendrive. Útil, pero no incluye el resto de utilidades.

> **Advertencia:** PuTTY debe descargarse **siempre** de su web oficial. Es una herramienta tan popular que abundan las copias falsas en sitios de terceros y anuncios de buscadores, algunas modificadas para robar las credenciales que se teclean. Es un descuido con consecuencias graves: si el cliente SSH está troyanizado, todas las contraseñas de los servidores que administremos quedan comprometidas.

### 10.2 Primera conexión paso a paso

Al abrir `putty.exe` aparece la ventana de configuración, organizada en un árbol de categorías a la izquierda (`Category`). Para una primera conexión sencilla:

1. En la categoría inicial, **`Session`**, escribir en el campo **`Host Name (or IP address)`** la dirección del servidor, por ejemplo `192.168.1.10`.
2. Comprobar que en **`Port`** figura `22` y que el tipo de conexión (`Connection type`) es **`SSH`**.
3. Pulsar el botón **`Open`** en la parte inferior.

La primera vez que se conecta a un servidor, PuTTY muestra una advertencia de seguridad (`PuTTY Security Alert`) con la huella (*fingerprint*) de la clave del servidor y pregunta si confiamos en él:

- **`Accept`**: acepta y **guarda** la clave para futuras conexiones. Es lo que se elige la primera vez.
- **`Connect Once`**: acepta solo para esta sesión, sin guardarla.
- **`Cancel`**: cancela la conexión.

> **Recuerda:** Esa advertencia es exactamente el mecanismo de la sección 3.1: PuTTY guarda las claves aceptadas en el registro de Windows (en lugar del fichero `~/.ssh/known_hosts` de Linux), y volverá a avisar de forma llamativa si la clave del servidor cambia, lo que podría indicar un ataque de intermediario. Aceptar a ciegas ese segundo aviso es justo lo que no se debe hacer.

Tras aceptar, se abre la terminal negra de PuTTY, que pide el usuario (`login as:`) y la contraseña. A partir de ahí, la sesión funciona igual que cualquier terminal Linux de las vistas en estos apuntes.

> **Nota:** Al pegar en la terminal de PuTTY se usa el **clic derecho del ratón** (o `Shift + Insert`), no `Ctrl + V`. Y para copiar basta con **seleccionar** el texto con el ratón: se copia automáticamente, sin necesidad de `Ctrl + C`.

### 10.3 Guardar sesiones para no repetir datos

Teclear la dirección, el puerto y el usuario en cada conexión es tedioso. PuTTY permite **guardar sesiones** con toda su configuración, que es el equivalente gráfico del fichero `~/.ssh/config` de la sección 5.

1. Rellenar los datos de la conexión en **`Session`** (host, puerto).
2. Conviene fijar también el usuario para no escribirlo cada vez: ir a **`Connection > Data`** y poner el nombre en **`Auto-login username`**.
3. Volver a **`Session`**, escribir un nombre descriptivo en el cuadro **`Saved Sessions`** (por ejemplo `servidor-web`) y pulsar **`Save`**.

A partir de entonces, para conectarse basta con hacer **doble clic** sobre el nombre guardado en la lista. Se pueden guardar tantas sesiones como servidores administremos.

### 10.4 Ajustes recomendados

Dos ajustes que merece la pena configurar y guardar en cada sesión:

- **Evitar desconexiones por inactividad.** En **`Connection`**, poner en **`Seconds between keepalives`** un valor como `30`. Esto envía tráfico cada 30 segundos para que la conexión no se corte cuando se deja de teclear un rato. Es el equivalente a `ServerAliveInterval` en Linux.
- **Mejorar la legibilidad.** En **`Window > Appearance`** se puede cambiar el tipo y tamaño de letra, y en **`Window`** ampliar el número de líneas de historial (`Lines of scrollback`) para poder desplazarse hacia atrás y ver salidas largas.

> **Importante:** Cualquier cambio en las categorías (`Connection`, `Window`, etc.) hay que guardarlo **volviendo a `Session` y pulsando `Save`** sobre la sesión correspondiente. Si se cierra PuTTY sin guardar, los ajustes se pierden. Es el error más habitual al empezar.

### 10.5 Autenticación por clave con PuTTYgen

En la sección 3.4 vimos cómo autenticarse con un par de claves en lugar de con contraseña. En Windows, ese par de claves se genera con **PuTTYgen**, teniendo en cuenta que PuTTY usa un formato propio de clave privada, con extensión **`.ppk`** (*PuTTY Private Key*), distinto del formato de OpenSSH.

Para generar el par de claves:

1. Abrir **`puttygen.exe`**.
2. En **`Type of key to generate`**, elegir **`EdDSA`** (algoritmo Ed25519, el recomendado hoy) o `RSA` con al menos `4096` bits.
3. Pulsar **`Generate`** y mover el ratón sobre el área en blanco: ese movimiento aleatorio genera la entropía necesaria para la clave.
4. Escribir una **`Key passphrase`** (frase de contraseña) para proteger la clave privada, tal como se explicó en la sección 3.4.
5. Pulsar **`Save private key`** para guardar el fichero `.ppk` en un lugar seguro del equipo.

El recuadro superior de PuTTYgen, etiquetado **`Public key for pasting into OpenSSH authorized_keys file`**, contiene la **clave pública** en el formato exacto que espera Linux. Ese texto es el que hay que copiar y añadir al fichero `~/.ssh/authorized_keys` del usuario en el servidor (sección 3.4), por ejemplo así, ya conectados por contraseña:

```bash
usuario@debian:~$ mkdir -p ~/.ssh && chmod 700 ~/.ssh
usuario@debian:~$ echo "ssh-ed25519 AAAA...la-clave-publica... usuario@windows" >> ~/.ssh/authorized_keys
usuario@debian:~$ chmod 600 ~/.ssh/authorized_keys
```

Una vez instalada la clave pública en el servidor, se le indica a PuTTY que use la clave privada al conectar: en **`Connection > SSH > Auth > Credentials`**, en el campo **`Private key file for authentication`**, seleccionar el fichero `.ppk` guardado. Conviene guardar la sesión después (apartado 9.3) para no repetirlo.

> **Advertencia:** Los permisos en el servidor son **críticos** y son una fuente de fallos silenciosos muy habitual. El directorio `~/.ssh` debe tener permisos `700` y el fichero `authorized_keys` debe tener `600`. Si son más abiertos, el servidor SSH **ignora la clave sin dar ninguna explicación** (por seguridad, se niega a fiarse de ficheros que otros usuarios podrían haber manipulado) y vuelve a pedir la contraseña, dejando al alumno sin entender por qué su clave "no funciona".

> **Advertencia:** PuTTY **no admite las claves privadas en el formato de OpenSSH**, que es precisamente el que genera `ssh-keygen`. Si se intenta cargar en PuTTY una clave `id_ed25519` (o `id_rsa`) creada con `ssh-keygen`, la conexión falla con un mensaje como el siguiente y PuTTY vuelve a pedir la contraseña del usuario:
>
> ```text
> Unable to use key file "C:\Users\usuario\.ssh\id_ed25519" (OpenSSH SSH-2 private key (new format))
> ```
>
> Según de dónde venga la clave, hay dos caminos para resolverlo:
>
> - **Si el par ya se generó con `ssh-keygen`** (por ejemplo siguiendo el apartado 3.5), no hay que rehacer nada en el servidor: basta con **convertir** la clave privada al formato `.ppk`. En PuTTYgen se hace con `Conversions > Import key`, se selecciona la clave de OpenSSH (`C:\Users\usuario\.ssh\id_ed25519`), se introduce su passphrase y se pulsa `Save private key`. Es la **misma** clave, solo cambia el formato del fichero, así que la pública que ya está en el `authorized_keys` del servidor sigue siendo válida.
> - **Si se empieza de cero pensando en usar PuTTY**, es más directo **generar el par en PuTTYgen** (los pasos 1 a 5 de este apartado): nace ya en formato `.ppk` y solo hay que copiar su clave pública al `authorized_keys` del servidor.

> **Nota:** El cliente `ssh` de PowerShell, en cambio, sí lee directamente las claves generadas con `ssh-keygen`, sin ninguna conversión. El formato `.ppk` solo lo necesitan PuTTY y sus utilidades `pscp` y `psftp`.

### 10.6 Pageant: el agente de claves

Si la clave privada tiene *passphrase*, PuTTY la pedirá en cada conexión. Para introducirla una sola vez y que quede disponible en memoria está **Pageant**, el equivalente al `ssh-agent` de la sección 3.4.

1. Abrir **`pageant.exe`**. Queda residente en el área de notificación de Windows (junto al reloj), con un icono de un ordenador con sombrero.
2. Hacer clic derecho sobre el icono y elegir **`Add Key`**.
3. Seleccionar el fichero `.ppk` e introducir la *passphrase* una vez.

A partir de ese momento, PuTTY (y también `pscp` y `psftp`) usarán la clave sin volver a pedir la contraseña, mientras Pageant siga abierto. Para que esté siempre disponible se puede añadir Pageant al inicio de Windows, indicándole que cargue la clave automáticamente.

### 10.7 Transferencia de ficheros: pscp y psftp

La suite incluye los equivalentes de `scp` y `sftp` para usarlos desde la línea de órdenes de Windows (`cmd` o PowerShell). La sintaxis es casi idéntica a la de sus hermanos de Linux vistos en las secciones 4 y 8.

**`pscp`** copia ficheros de forma directa, igual que `scp`:

```bash
# Subir un fichero del PC Windows al servidor
pscp C:\datos\informe.pdf usuario@192.168.1.10:/home/usuario/

# Descargar un fichero del servidor al PC Windows
pscp usuario@192.168.1.10:/var/log/syslog C:\temp\

# Copiar una carpeta completa (recursivo)
pscp -r C:\proyecto usuario@192.168.1.10:/home/usuario/
```

**`psftp`** abre una sesión interactiva para navegar y transferir, igual que `sftp`:

```bash
C:\> psftp usuario@192.168.1.10
psftp> ls              # lista el directorio remoto
psftp> lls             # lista el directorio LOCAL (la l inicial = local)
psftp> cd /var/www     # cambia de directorio en el servidor
psftp> lcd C:\web      # cambia de directorio en el PC local
psftp> put pagina.html # sube un fichero
psftp> get backup.tar  # descarga un fichero
psftp> bye             # cierra la sesion
```

> **Recuerda:** La diferencia clave de una sesión `sftp`/`psftp` es que se trabaja con **dos directorios a la vez**: el remoto y el local. Los comandos normales (`ls`, `cd`) actúan sobre el servidor, y los mismos precedidos de `l` (`lls`, `lcd`) actúan sobre el equipo local. `put` sube y `get` descarga.

### 10.8 El verdadero potencial: túneles SSH (reenvío de puertos)

Aquí es donde PuTTY deja de ser "un programa para abrir una terminal negra" y muestra por qué SSH es una herramienta tan potente. Un **túnel SSH** aprovecha la conexión cifrada ya establecida para transportar **otro** tráfico de red por dentro, de forma segura. Es la función que la sección 1 anunciaba como "una VPN ligera".

La idea se entiende mejor con un problema concreto muy habitual: un servidor tiene una base de datos MySQL o un panel de administración que, **por seguridad, solo escucha en `localhost`** y no es accesible desde la red. ¿Cómo lo administramos desde nuestro PC sin exponerlo a internet? Con un túnel: le decimos a SSH que un puerto de **nuestro** equipo se conecte, a través del túnel cifrado, con ese servicio interno del servidor.

Hay tres tipos de túnel, y conviene distinguirlos:

| Tipo | Qué hace | Ejemplo de uso |
|---|---|---|
| **Local** (`-L`) | Un puerto de **mi PC** se conecta a un servicio accesible desde el servidor. | Acceder a la base de datos interna del servidor como si estuviera en mi máquina. |
| **Remoto** (`-R`) | Un puerto del **servidor** se conecta a un servicio de mi PC. | Exponer temporalmente un servicio de mi equipo hacia el servidor. |
| **Dinámico** (`-D`) | Convierte SSH en un **proxy SOCKS**: todo el tráfico que se le envíe sale por el servidor. | Navegar por internet como si estuviéramos físicamente en la red del servidor. |

**Cómo se crea un túnel local en PuTTY**, paso a paso, para el ejemplo de la base de datos MySQL (puerto 3306) que solo escucha en el `localhost` del servidor:

1. Cargar la sesión del servidor (o rellenar sus datos en `Session`).
2. Ir a la categoría **`Connection > SSH > Tunnels`**.
3. En **`Source port`** escribir un puerto libre de nuestro PC, por ejemplo `3306`.
4. En **`Destination`** escribir el destino **visto desde el servidor**: `localhost:3306`.
5. Dejar marcadas las opciones **`Local`** y **`Auto`**, y pulsar **`Add`**. La regla aparecerá en la lista como `L3306 localhost:3306`.
6. Volver a **`Session`**, guardar la sesión y pulsar **`Open`** para conectar.

Mientras la ventana de PuTTY siga abierta, cualquier programa de nuestro PC que se conecte a `localhost:3306` estará hablando en realidad, a través del túnel cifrado, con el MySQL interno del servidor. El equivalente en línea de comandos de Linux de todo esto sería una sola orden:

```bash
usuario@debian:~$ ssh -L 3306:localhost:3306 usuario@192.168.1.10
```

> **Nota:** El túnel **dinámico** (`-D`) es el más versátil. Configurando en PuTTY un `Source port` (por ejemplo `1080`) con la opción **`Dynamic`** marcada, PuTTY se convierte en un proxy SOCKS. Si después se configura el navegador para usar `localhost:1080` como proxy SOCKS, toda la navegación saldrá cifrada por el servidor y aparecerá en internet con la IP de este. Es una forma sencilla de acceder de forma segura a recursos internos de una red o de saltarse restricciones de la red local desde la que nos conectamos.

> **Recuerda:** Un túnel solo vive mientras la conexión SSH que lo transporta está abierta. Al cerrar PuTTY, el túnel desaparece. Es la mejor manera de que los alumnos "descubran el potencial" de SSH: comprobar en vivo que un servicio inaccesible desde la red se vuelve accesible a través del túnel, y deja de serlo al cerrar la sesión.

### 10.9 Alternativa moderna: el cliente ssh de Windows

Conviene que los alumnos sepan que, desde Windows 10, el sistema incluye de fábrica un **cliente OpenSSH nativo**, el mismo `ssh` que en Linux, ejecutable desde `cmd` o PowerShell. Para una conexión rápida ya no es imprescindible PuTTY:

```bash
C:\> ssh usuario@192.168.1.10
C:\> scp C:\datos\informe.pdf usuario@192.168.1.10:/home/usuario/
```

> **Nota:** El cliente integrado de Windows usa los mismos ficheros y sintaxis que en Linux (`%USERPROFILE%\.ssh\`, con `config`, `known_hosts` y claves en formato OpenSSH), de modo que todo lo aprendido en las secciones anteriores se aplica igual. PuTTY sigue siendo muy útil por su gestión visual de sesiones y, sobre todo, de túneles, pero para el uso diario básico el `ssh` nativo suele ser más cómodo para quien ya conoce la línea de comandos.
