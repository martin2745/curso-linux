# Apache como Servidor Web

**Apache** es un software de servidor web gratuito y de código abierto que recibe solicitudes de navegadores y entrega contenido web (páginas, imágenes, archivos) mediante el protocolo HTTP/HTTPS.

- **Características principales:**
  - Multiplataforma: Funciona en Linux, Windows, macOS y otros sistemas operativos.
  - Modular: Arquitectura basada en módulos que permiten habilitar funcionalidades adicionales como seguridad, caché, reescritura de URLs, autenticación, etc.
  - Personalizable: Configuración flexible mediante archivos como `.htaccess`.
  - Soporta HTTP/1.1 y HTTP/2.
  - Facilita alojamiento de múltiples sitios web con VirtualHosts en una misma dirección IP.
  - Compatible con lenguajes como PHP, Perl, Python.
  - Incluye módulos para seguridad (ej. mod_security), compresión y balanceo de carga.
- **Funcionamiento básico:** Atiende las peticiones HTTP enviadas por roots a través de un navegador y responde con los recursos solicitados, garantizando una comunicación segura y eficiente entre cliente y servidor.

- **Modelo Cliente/Servidor en Servicios Web**: El servicio web está basado en el modelo cliente/servidor. Sus componentes principales son:
- **Recursos y aplicaciones**: Son los documentos, imágenes, sonidos, vídeos y aplicaciones en línea a los que podemos acceder a través de los servidores web. Estos recursos están conectados mediante hipervínculos escritos en lenguajes como el **HTML** (Hyper Text Markup Language).
- **Direcciones web**: Cadenas de caracteres que identifican los recursos de manera inequívoca y nos permiten acceder a ellos. Se llaman **URIs** o **URLs**.
- **Clientes web, clientes HTTP o navegadores**: Permiten a los usuarios acceder a los recursos disponibles en los servidores web. Establecen conexiones con los servidores, dialogan con ellos y presentan la información recibida a los usuarios.
- **Servidores web o servidores HTTP**: Atienden las peticiones de los clientes y envían los recursos solicitados. Normalmente almacenan los recursos en su propio sistema de archivos.
- **Proxies web**: Software que actúa como intermediario entre un servidor web y un cliente, con la finalidad de optimizar y controlar el acceso a Internet, balancear la carga, incrementar la seguridad, etc.
- **Protocolo HTTP**: Define las reglas por las que dialogan servidores y clientes. Utiliza el protocolo TCP a nivel de transporte. HTTP es un protocolo inseguro, motivo por el que surge HTTPS.
- **Lenguajes de marcas**: HTML, XHTML, XML son lenguajes que permiten crear documentos o páginas web, incluyendo hipervínculos, en un formato interpretable por los navegadores.  
  JSON es también un lenguaje de marcas muy usado actualmente para intercambiar datos entre clientes y servidores web.
- **Otras tecnologías web**: Existen muchas otras tecnologías utilizadas para desarrollar aplicaciones web: **CSS, CGI, PHP, ASP, CFM, JSP, .NET, AJAX, Javascript, XQuery, Xpath, XSL,** etc.

## Configuración básica

Para instalar **Apache** ejecutamos el siguiente comando en una distribución debian.

```bash
root@debian:~$ sudo apt update && sudo apt install -y apache2
...
```

Vemos que el servicio está en ejecución.

```bash
root@debian:~$ systemctl status apache2
● apache2.service - The Apache HTTP Server
     Loaded: loaded (/lib/systemd/system/apache2.service; enabled; preset: enabled)
     Active: active (running) since Wed 2025-09-10 17:40:17 CEST; 4min 37s ago
       Docs: https://httpd.apache.org/docs/2.4/
   Main PID: 2938 (apache2)
      Tasks: 55 (limit: 4620)
     Memory: 17.6M
        CPU: 110ms
     CGroup: /system.slice/apache2.service
             ├─2938 /usr/sbin/apache2 -k start
             ├─2939 /usr/sbin/apache2 -k start
             └─2940 /usr/sbin/apache2 -k start
```

Si nos fijamos en los procesos en ejecución podemos ver que el que ejecuta el servicio es **www-data** y se ejecuta sobre el puerto 80.

```bash
root@debian:~$ ps -aux | grep apache
root        2938  0.0  0.1   6568  4736 ?        Ss   17:40   0:00 /usr/sbin/apache2 -k start
www-data    2939  0.0  0.2 1998940 11040 ?       Sl   17:40   0:00 /usr/sbin/apache2 -k start
www-data    2940  0.0  0.2 1933404 11040 ?       Sl   17:40   0:00 /usr/sbin/apache2 -k start
www-data    3020  0.0  0.0   3412   168 ?        Ss   17:40   0:00 /usr/bin/htcacheclean -d 120 -p /var/cache/apache2/mod_cache_disk -l 300M -n
root     3081  0.0  0.0   6356  2056 pts/0    S+   17:46   0:00 grep apache

root@debian:~$ ss -putan | grep 80
tcp   LISTEN 0      511                   *:80               *:*
```

Si nosotros vemos el contenido en un navegador en la ip y puerto correspondiente veremos la página de muestra de Apache que está definida en la ruta `/var/www/html/index.html`.

### Puerto de escucha y direccionamiento

En `/etc/apache2` se encuentra la configuración del servidor Apache.

```bash
root@debian:~$ ls -l /etc/apache2
total 80
-rw-r--r-- 1 root root  7178 jul 29 22:18 apache2.conf
drwxr-xr-x 2 root root  4096 sep 10 17:40 conf-available
drwxr-xr-x 2 root root  4096 sep 10 17:40 conf-enabled
-rw-r--r-- 1 root root  1782 jul 29 22:18 envvars
-rw-r--r-- 1 root root 31063 jul 17 17:59 magic
drwxr-xr-x 2 root root 12288 sep 10 17:40 mods-available
drwxr-xr-x 2 root root  4096 sep 10 17:40 mods-enabled
-rw-r--r-- 1 root root   274 jul 29 22:18 ports.conf
drwxr-xr-x 2 root root  4096 sep 10 17:40 sites-available
drwxr-xr-x 2 root root  4096 sep 10 17:40 sites-enabled
```

La explicación de cada archivo incluido en el directorio /etc/apache2 es la siguiente:

- **apache2.conf:** El archivo principal de configuración de Apache2. Contiene toda la configuración global.
- **conf-available:** Este directorio contiene archivos de configuración disponibles. Todos los archivos que en versiones anteriores estaban en /etc/apache2/conf.d deberían moverse a /etc/apache2/conf-available.
- **conf-enabled:** Mantiene enlaces simbólicos a los archivos en /etc/apache2/conf-available. Cuando un archivo de configuración está enlazado mediante un enlace simbólico, estará activo la siguiente vez que se reinicie Apache.
- **envvars:** Archivo con variables de entorno y sus valores.
- **mods-available:** Este directorio contiene archivos de configuración para cargar módulos y configurarlos. Sin embargo, no todos los módulos tienen archivos de configuración específicos.
- **mods-enabled:** Mantiene enlaces simbólicos a los archivos en /etc/apache2/mods-available. Cuando un archivo de configuración de módulo está enlazado mediante un enlace simbólico será activado después del siguiente reinicio de Apache.
- **ports.conf:** Aloja las directivas que determinan los puertos TCP en los que Apache escucha y atiende peticiones.
- **sites-available:** Este directorio tiene los archivos de configuración de los Hosts Virtuales de Apache. Los Hosts Virtuales permiten que Apache esté configurado para múltiples sitios con configuraciones separadas.
- **sites-enabled:** Al igual que mods-enabled, sites-enabled contiene enlaces simbólicos a archivos dentro de /etc/apache2/sites-available. De manera similar, cuando se crea un enlace simbólico el sitio virtual estará activo una vez se reinicie Apache.
- **magic:** Instrucciones para determinar los tipos MIME basándose en los primeros bytes de cada archivo.

_*Nota*_: Diferencia entre módulo y configuración.

Un **módulo** es una extensión que añade funcionalidades específicas al servidor web, como soporte para distintos tipos de contenido, autenticación, compresión, etc. Los módulos se pueden cargar o descargar para ampliar o reducir las capacidades de Apache.

Una **configuración** (archivo de configuración) define cómo se comporta Apache y sus módulos, especificando parámetros, reglas, y opciones para el funcionamiento del servidor y de los módulos cargados.

Cuando se inicia el demonio HTTP, este se enlaza a alguna dirección IP y puerto del equipo local y espera por peticiones de clientes. Por defecto, escucha en todas las direcciones del equipo. Sin embargo, puede ser necesario indicarle que escuche en puertos específicos o solo en alguna dirección o en una combinación de ambos. Con frecuencia, todo esto se combina con la propiedad de _Host Virtual_, que determina cómo el demonio httpd responde a las diferentes direcciones, nombres de equipo y puertos.

La directiva **Listen** le indica al servidor que acepte peticiones solo en alguno(s) puerto(s) específico(s) o en combinaciones de direcciones y puertos. Si únicamente se especifica una directiva **Listen**, el servidor escucha peticiones en ese puerto en todas sus direcciones. Si se especifica una dirección IP junto con el puerto, atenderá peticiones en ese puerto e interfaz. Se pueden definir múltiples directivas **Listen** junto con puertos y direcciones. El servidor atenderá peticiones en cualquiera de ellos.

```bash
root@debian:~$ cat /etc/apache2/ports.conf
# If you just change the port or add more ports here, you will likely also
# have to change the VirtualHost statement in
# /etc/apache2/sites-enabled/000-default.conf

Listen 80

<IfModule ssl_module>
        Listen 443
</IfModule>

<IfModule mod_gnutls.c>
        Listen 443
</IfModule>
```

Podemos modificar la información de este fichero. Por ejemplo, para hacer que el servidor acepte peticiones en los puertos 80 y 8000 en todas sus interfaces de red utilizaremos:

```bash
Listen 80
Listen 8080
```

Para hacer que el servidor acepte conexiones en el puerto 80 para una interfaz y en el 8000 para otra, usaremos:

```bash
Listen 192.0.2.1:80
Listen 192.0.2.5:8000
```

Las direcciones IPv6 deben ir encerradas entre corchetes, como en el siguiente ejemplo:

```bash
Listen [2001:db8::a00:20ff:fea7:ccea]:80
```

### Virtual Hosts

Virtual Host se refiere a la posibilidad de ejecutar en nuestro Apache varios sitios web (como ejemplo1.com y ejemplo2.com). Los Virtual Hosts pueden ser basados en IP, lo que quiere decir que se tienen diferentes direcciones IP para cada sitio, o basados en nombre, que significa que hay múltiples sitios web en la misma dirección. El hecho de que se ejecuten en la misma máquina física no es perceptible para el usuario final.

#### Hosts Virtuales basados en nombres

Con los hosts virtuales basados en nombres, el servidor depende de que el cliente reporte el nombre del host como parte de sus cabeceras HTTP. De esta manera, varios hosts diferentes pueden compartir la misma dirección IP.

Configurar hosts virtuales basados en nombres es más sencillo, ya que es necesario configurar el servidor DNS para que cada nombre apunte a la dirección correcta, y luego configurar el servidor web Apache para que reconozca los diferentes nombres. El hosting virtual basado en nombres también es una ayuda frente a la escasez de direcciones IP, por lo que debería usarse siempre a menos que se requiera explícitamente hosting virtual basado en direcciones IP.

Es importante reconocer que el primer paso para la resolución en hosting virtual basado en nombres es la resolución de direcciones IP. Esta resolución basada en nombres solo elige el host virtual más adecuado una vez reducidos los candidatos basados en la dirección IP coincidente. Usar un (\*) para la dirección IP en todas las directivas <VirtualHost> hace que esa mapeo basado en la dirección IP sea irrelevante.

Cuando llega una petición, el servidor busca la directiva <VirtualHost> que mejor coincida (la más específica) basada en la dirección IP y en el puerto especificado en la petición. Si hay más de un virtual host que coincide con la combinación de dirección IP y puerto, Apache compara las directivas ServerName y ServerAlias con el nombre de servidor presente en la petición.

Si no se encuentra ninguna directiva ServerName o ServerAlias en el conjunto de hosts virtuales que contienen la combinación de dirección IP y número de puerto que mejor encaje, entonces el primer host virtual en ser listado que encaje será empleado.

El primer paso para crear un bloque <VirtualHost> es crear uno para cada host diferente que se quiere alojar en el servidor. Dentro de cada bloque <VirtualHost> se necesita al menos una directiva ServerName para designar qué host virtual se sirve, y también una directiva DocumentRoot que indique en qué lugar del sistema de ficheros reside el contenido para ese virtual host. A continuación mostramos un ejemplo:

```bash
<VirtualHost *:80>
    ServerName www.ejemplo1.com
    ServerAlias ejemplo1.com
    DocumentRoot "/var/www/ejemplo1"
</VirtualHost>

<VirtualHost *:80>
    ServerName www.ejemplo2.com
    ServerAlias ejemplo2.com
    DocumentRoot "/var/www/ejemplo2"
</VirtualHost>
```

Supongamos ahora lo siguiente, vamos a crear dos sitios web sencillos con el siguiente código HTML en `/var/www/ejemplo2.com`:

```html
<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <title>Ejemplo1.com</title>
  </head>
  <body>
    Soy ejemplo1.com
  </body>
</html>
```

```bash
root@debian:~# nano /var/www/ejemplo1
root@debian:~# nano /var/www/ejemplo2
root@debian: cd /var/www
root@debian:/var/www# tree
.
├── ejemplo1
│   └── index.html
├── ejemplo2
│   └── index.html
└── html
    └── index.html
```

_*Nota:*_ Hacemos lo mismo para ejemplo2.com.

A continuación modificamos el archivo `/etc/apache2/ports.conf` con la información de los Virtual Hosts.

```bash
root@debian:~# cat /etc/apache2/ports.conf
# If you just change the port or add more ports here, you will likely also
# have to change the VirtualHost statement in
# /etc/apache2/sites-enabled/000-default.conf

Listen 80

<VirtualHost *:80>
    ServerName www.ejemplo1.com
    ServerAlias ejemplo1.com
    DocumentRoot "/var/www/ejemplo1"
</VirtualHost>

<VirtualHost *:80>
    ServerName www.ejemplo2.com
    ServerAlias ejemplo2.com
    DocumentRoot "/var/www/ejemplo2"
</VirtualHost>

<IfModule ssl_module>
        Listen 443
</IfModule>

<IfModule mod_gnutls.c>
        Listen 443
</IfModule>

root@debian:~# systemctl restart apache2
```

_*Nota*_: En el caso de estos apuntes, hacemos uso de una MV debian en VirtualBox con un adaptador Nat y mapeamos el puerto 3000 al puerto 80 de la máquina. Por este motivo tendremos que en el navegador introducir la siguiente ruta: http://ejemplo1.com:3000/ y http://ejemplo2.com:3000/
_*Nota 2*_: Al no existir resolución de DNS entre ejemplo1.com y la IP 127.0.0.1 tenemos las opciones de editar los ficheros `/etc/hosts` de nuestro anfitrion si estamos en un equipo linux o el fichero `C:\Windows\System32\drivers\etc\hosts` si estamos en un equipo Windows.
_*Nota 3*_: Es posible que la caché del navegador mantenga información de búsquedas anteriores y de problemas a la hora de hacer estos ejercicios, es recomendable eliminar los datos de caché.

#### Hosts Virtuales basados en nombres

El virtual hosting basado en direcciones IP es un método para aplicar diferentes directivas basadas en la dirección IP y puerto en el que se recibe la petición. De esta manera se sirven diferentes sitios y en diferentes puertos e interfaces de red. En muchos casos, el uso de virtual hosts basados en nombre es más conveniente, porque permite a muchos hosts virtuales compartir una misma dirección/puerto. La frase basado en direcciones IP indica que el servidor debe tener diferentes combinaciones dirección IP/puerto para cada host. Esto puede conseguirse en una máquina teniendo varias interfaces físicas o usando interfaces de red virtuales, que son soportadas por los sistemas operativos modernos, y/o usando múltiples números de puerto.

En este caso, en lugar de un adaptador Nat vamos a hacer uso de un puente o bridge, por el cual, la máquina virtual tiene una IP en la red, como si fuera otro equipo físico.

```bash
root@debian:~# ip -c a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute
       valid_lft forever preferred_lft forever
2: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:be:df:87 brd ff:ff:ff:ff:ff:ff
    inet 10.158.120.83/24 brd 10.158.120.255 scope global dynamic noprefixroute enp0s8
       valid_lft 3249sec preferred_lft 3249sec
    inet6 fe80::a00:27ff:febe:df87/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

Vamos en este caso a darle otra IP a la interfaz _enp0s8_ para poder modificar el fichero `/etc/apache/ports.conf`, esta vez en función de la IP.

```bash
root@debian:~# ip a a 10.158.120.84/24 dev enp0s8
```

A continuación, vamos a editar el archivo para tener un Virtual Host accesible para cada IP.

```bash
root@debian:~# cat /etc/apache2/ports.conf
# If you just change the port or add more ports here, you will likely also
# have to change the VirtualHost statement in
# /etc/apache2/sites-enabled/000-default.conf

Listen 80
Listen 3000

<VirtualHost 10.158.120.83:80>
    ServerAdmin  webmaster@www.ejemplo1.com
    DocumentRoot "/var/www/ejemplo1"
</VirtualHost>

<VirtualHost 10.158.120.84:3000>
    ServerAdmin webmaster@www.ejemplo2.com
    DocumentRoot "/var/www/ejemplo2"
</VirtualHost>

<IfModule ssl_module>
        Listen 443
</IfModule>

<IfModule mod_gnutls.c>
        Listen 443
</IfModule>
```

En este punto, podemos acceder a los sitios haciendo uso de las rutas `http://10.158.120.83/` y `http://10.158.120.84:3000/`.

### Contextos

Los contextos indican dónde se permite establecer una directiva. Es una lista separada por comas de los siguientes valores:

- server config: Esto significa que la directiva puede ser utilizada en los archivos de configuración de Apache (por ejemplo, apache2.conf), pero no dentro de los contenedores <VirtualHost> o <Directory>. Tampoco se permite en los archivos .htaccess.
- virtual host: Este contexto significa que una directiva puede aparecer dentro de un contexto <VirtualHost> que se encuentre en cualquier archivo de configuración.
- directory: Una directiva válida en este contexto puede emplearse dentro de contenedores <Directory>, <Location>, <Files>, <If> y <Proxy> en los archivos de configuración, sujetos a las restricciones descritas en la sección de configuración.
- .htaccess: Si una directiva es válida en este contexto, significa que puede aparecer en un archivo de configuración de directorio denominado .htaccess. Estos pueden no ser procesados dependiendo de las directivas de anulación activas.

Cada directiva únicamente es válida dentro de su contexto. Si se intenta utilizar fuera del contexto designado, aparecerá un error de configuración que puede ocasionar que el servidor maneje incorrectamente peticiones en dicho contexto o que simplemente no funcione (por ejemplo, impidiendo que se inicie).

Las ubicaciones de una directiva son el resultado de una operación booleana de todos los contextos válidos. En otras palabras, si una directiva está marcada como válida dentro de server config y .htaccess, puede utilizarse tanto en el archivo apache2.conf como en ficheros .htaccess, pero no dentro de <Directory> o <VirtualHost>.

### Directivas

#### Listen

La directiva **Listen** le indica al servidor que acepte peticiones solo en uno o varios puertos específicos, o en combinaciones de direcciones y puertos.  
Si únicamente se especifica una directiva **Listen**, el servidor escuchará en ese puerto en todas sus direcciones.  
Si se especifica una dirección IP junto con el puerto, atenderá las peticiones en ese puerto e interfaz.  
Se pueden definir múltiples directivas **Listen** con distintos puertos y direcciones. El servidor aceptará conexiones en todos ellos.

Por ejemplo, para que el servidor acepte peticiones en los puertos 80 y 8000 en todas sus interfaces de red, se usará:

```bash
Listen 80
Listen 8000
```

Para que el servidor acepte conexiones en el puerto 80 para una interfaz y en el 8000 para otra, se empleará:

```bash
Listen 192.0.2.1:80
Listen 192.0.2.5:8000
```

Las direcciones IPv6 deben escribirse entre corchetes como en este ejemplo:

```bash
Listen [2001:db8::a00:20ff:fea7:ccea]:80
```

Si se usa cifrado SSL y el módulo [translate:ssl] está activo, también se debe habilitar el puerto 443:

```bash
<IfModule ssl_module>
  Listen 443
</IfModule>
```

#### VirtualHosts

Un **Virtual Host** es una técnica que permite a un servidor web Apache alojar múltiples sitios web en una sola máquina física. Existen dos tipos de Virtual Hosts:

- **Basados en nombre:** Varios sitios web comparten la misma dirección IP, y Apache distingue los sitios según el nombre del host que el cliente indica en la petición HTTP.
- **Basados en dirección IP:** Cada sitio web tiene una dirección IP diferente, y Apache sirve los sitios según la IP y puerto en que recibe la solicitud.

Esta técnica facilita aprovechar mejor los recursos del servidor y administrar múltiples sitios en el mismo servidor sin que el usuario final note la diferencia.

Apache incluye por defecto una configuración sencilla con un solo VirtualHost por defecto, definido en el archivo `/etc/apache2/sites-available/000-default.conf`. Este actúa como sitio estándar o "catch-all" si no se encuentra otro VirtualHost que coincida con la URL solicitada.

Las directivas que se definen dentro de un VirtualHost solo aplican a ese sitio específico, mientras que las directivas de ámbito global (de servidor) se aplican cuando no están sobreescritas por un VirtualHost.

Para agregar un nuevo sitio se puede copiar y modificar el archivo `000-default.conf` con un nombre nuevo en el mismo directorio.

Esta práctica permite alojar varios sitios en el mismo servidor físico sin que el usuario final note la diferencia.

##### Mejorando nuestros Virtual Hosts

Aunque la forma que hicimos anteriormente posicionando el código en `/etc/apache2/ports.conf` funciona, sería más correcto crear un **sitio** para cada web en especial. De este modo deberiamos seguir los siguientes pasos:

1. El archivo de `ports.conf` quedaría con la siguiente información.

```bash
root@debian:/etc/apache2# cat ports.conf
# If you just change the port or add more ports here, you will likely also
# have to change the VirtualHost statement in
# /etc/apache2/sites-enabled/000-default.conf

Listen 80
Listen 3000
Listen 4000

<IfModule ssl_module>
        Listen 443
</IfModule>

<IfModule mod_gnutls.c>
        Listen 443
</IfModule>
```

2. Crearíamos un archivo para cada sitio web de la siguiente forma.

```bash
root@debian:/etc/apache2# nano sites-available/ejemplo1.conf
root@debian:/etc/apache2# cat sites-available/ejemplo1.conf
<VirtualHost 10.158.120.83:3000>
    ServerName www.ejemplo1.com
    ServerAlias ejemplo1.com
    DocumentRoot /var/www/ejemplo1
</VirtualHost>

root@debian:/etc/apache2# nano sites-available/ejemplo2.conf
root@debian:/etc/apache2# cat sites-available/ejemplo2.conf
<VirtualHost 10.158.120.83:4000>
    ServerName www.ejemplo1.com
    ServerAlias ejemplo1.com
    DocumentRoot /var/www/ejemplo2
</VirtualHost>
```

3. Habilitamos los sitios con el comando **a2ensite** (si quisieramos deshabilitarlo usariamos **a2dissite**) y reiniciamos apache.

```bash
root@debian:/etc/apache2# a2ensite ejemplo1.conf
Enabling site ejemplo1.
To activate the new configuration, you need to run:
  systemctl reload apache2
root@debian:/etc/apache2# a2ensite ejemplo2.conf
Enabling site ejemplo2.
To activate the new configuration, you need to run:
  systemctl reload apache2
root@debian:/etc/apache2# systemctl reload apache
```

_*Nota*_: Como resultado se genera el correspondiente enlace simbólico a la ruta `/etc/apache2/sites-avaliable`.

```bash
root@debian:/etc/apache2# ls -l sites-enabled
total 0
lrwxrwxrwx 1 root root 35 sep 10 17:40 000-default.conf -> ../sites-available/000-default.conf
lrwxrwxrwx 1 root root 32 sep 11 14:56 ejemplo1.conf -> ../sites-available/ejemplo1.conf
lrwxrwxrwx 1 root root 32 sep 11 14:56 ejemplo2.conf -> ../sites-available/ejemplo2.conf
```

#### ServerName, ServerAlias y ServerAdmin

- La directiva **ServerName** establece el nombre del host (hostname) que el servidor (o VirtualHost) usa para identificarse a sí mismo. Se usa (posiblemente junto con ServerAlias) para identificar de forma única un host virtual cuando se emplean hosts virtuales basados en nombres. La directiva ServerName puede aparecer en cualquier lugar dentro de la definición de un servidor. Sin embargo, cada aparición anula la anterior (dentro del servidor). Cuando se usan hosts virtuales basados en nombre, la directiva ServerName dentro de una sección `<VirtualHost>` especifica qué nombre de host debe aparecer en la cabecera “Host:” de una petición.
- La directiva **ServerAlias** establece nombres alternativos para un host para emplear hosts virtuales basados en nombres. ServerAlias puede incluir comodines si es necesario. Para el proceso de ajuste del mejor conjunto de bloques `<VirtualHost>` en hosts virtuales basados en nombres, estos se procesan en orden de aparición en la configuración. Se usa el primer ServerName o ServerAlias sin precedencia de comodines.
- La directiva **ServerAdmin** establece la dirección de contacto que el servidor incluye en los mensajes de error que se devuelven al cliente.

```bash
<VirtualHost *:80>
    ServerName server.ejemplo.com
    ServerAdmin www-admin@ejemplo.com
    ServerAlias server server2.ejemplo.com server2
    ServerAlias *.ejemplo.com
    ...
</VirtualHost>
```

#### DocumentRoot

- Esta directiva establece el directorio desde el cual el servidor HTTP sirve los archivos. A menos que una URL coincida con alguna directiva como Alias, el servidor concatena al camino especificado en la raíz de documentos la URL referenciada para construir la ruta al documento.

```bash
<VirtualHost *:80>
    ServerName www.ejemplo1.com
    ServerAlias ejemplo1.com
    DocumentRoot "/www/ejemplo1/web"
</VirtualHost>
```

Así, un acceso a `http://www.ejemplo.com/index.html` se refiere a `/www/ejemplo1/web/index.html`. Si la ruta al directorio raíz no es absoluta, se asume que es relativa al contenido de la directiva ServerRoot.

**Nota:** El DocumentRoot debería especificarse sin la barra final.

#### Alias

La directiva **Alias** permite que documentos almacenados en el sistema de ficheros local, en una ubicación diferente a `DocumentRoot`, sean accesibles a través de URLs. Las URLs (una vez decodificadas) que comienzan con una ruta de URL serán mapeadas a archivos locales que comienzan con una ruta de directorio. La ruta de URL es sensible a mayúsculas, incluso en sistemas de ficheros que no lo son.

Ejemplo:

```bash
Alias "/image" "/ftp/pub/image"
```

Una petición para `http://ejemplo.com/image/foo.gif` hará que el servidor devuelva el archivo `/ftp/pub/image/foo.gif`. Solo se emparejan trozos completos de ruta, por lo que el ejemplo anterior no emparejaría con la URL `http://ejemplo.com/imagefoo.gif`.

##### Información adicional

Se debe tener cuidado con incluir la barra final (`/`) en la URL, ya que requerirá que exista también al final de la ruta en el sistema de ficheros. Por ejemplo, si se usa:

```bash
Alias "/icons/" "/usr/local/apache/icons
```

Entonces la URL `/icons` no se podrá acceder a través del Alias porque faltaría la barra final. De igual modo, si se omite la barra, también debe omitirse en la ruta del sistema de ficheros.

Es importante saber que probablemente sea necesario especificar secciones `<Directory>` adicionales relacionadas con el destino de los alias. En particular, si se crea un Alias a un directorio fuera de `DocumentRoot`, seguramente se necesita permitir el acceso explícitamente.

Ejemplo completo con autorización:

```bash
Alias "/image" "/ftp/pub/image"
<Directory "/ftp/pub/image">
    Require all granted
</Directory>
```

Vamos pues a realizar la prueba con una imágen.

```bash
root@debian:/# mkdir -p /var/www/ejemplo1/images
```

Almacenamos la imagen en esa dirección.

```bash
root@debian:/# ls -l /var/www/ejemplo1/images/
total 104
-rw-r--r-- 1 root root 102608 sep 11 17:59 coche.png
```

Editamos el Virtual Host.

```bash
root@debian:/etc/apache2# cat sites-available/ejemplo1.conf
<VirtualHost 10.158.120.83:3000>
    ServerName www.ejemplo1.com
    ServerAlias ejemplo1.com
    DocumentRoot /var/www/ejemplo1

    Alias /image /var/www/ejemplo1/images
    <Directory /var/www/ejemplo1/images>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>

root@debian:/etc/apache2# systemctl reload apache2
```

En la ruta `http://10.158.120.83:3000/images/` tenemos la imagen del coche.

#### DirectoryIndex

La directiva **DirectoryIndex** establece la lista de recursos a buscar cuando el cliente solicita el índice de un directorio, es decir, cuando especifica una barra `/` al final del nombre del directorio. Las URL locales son URLs (codificadas con `%`) de documentos relativos al directorio solicitado. Normalmente contienen el nombre de un fichero dentro del directorio. Se pueden poner varias URLs, pero se devolverá la primera que se encuentre. Si ninguna existe, y está activada la directiva **Indexes**, el servidor generará un listado del contenido del directorio.

Ejemplo:

```bash
DirectoryIndex index.html
```

Así, una petición a `http://ejemplo.com/docs/` devolverá `http://ejemplo.com/docs/index.html` si este existe, o un listado del directorio si está activa la opción Indexes, o un mensaje de error.

#### Options

La directiva **Options** controla qué características del servidor están activas en un directorio en particular. Puede tomar el valor `None` (que indica que ninguna opción está habilitada) o una o más de las siguientes opciones:

- `All`: Todas las opciones excepto MultiViews. Este es el valor por defecto.
- `FollowSymLinks`: El servidor seguirá todos los enlaces simbólicos de este directorio. Aunque siga el enlace, no cambiará el nombre de la ruta emparejada dentro de la sección `<Directory>`.
- `Includes`: Permite inclusiones del lado del servidor proporcionadas por el módulo `mod_include`.
- `Indexes`: Si se solicita una URL que mapea a un directorio que no contiene ninguno de los ficheros listados en **DirectoryIndex** (por ejemplo, `index.html`), el módulo `mod_autoindex` devolverá un listado formateado del contenido del directorio.
- `SymLinksIfOwnerMatch`: El servidor solo seguirá el enlace simbólico si los propietarios del enlace y del destino coinciden.

Si se aplican múltiples opciones a un directorio, solo se aplican las más específicas y las otras se ignoran, a menos que todas las opciones estén precedidas por `+` o `-`, en cuyo caso se mezclan.

Ejemplo sin símbolos `+` o `-`:

```bash
<Directory /web/docs>
   Options Indexes FollowSymLinks
</Directory>
<Directory /web/docs/spec>
   Options Includes
</Directory>
```

En este caso, solo se establece `Includes` para `/web/docs/spec`.

Ejemplo con símbolos `+` y `-`:

```bash
<Directory /web/docs>
   Options Indexes FollowSymLinks
</Directory>
<Directory /web/docs/spec>
   Options +Includes -Indexes
</Directory>
```

Aquí se establecen las opciones `FollowSymLinks` e `Includes` para `/web/docs/spec`.

### Las secciones de configuración

El bloque <VirtualHost> da a los administradores la capacidad de modificar el comportamiento del servidor web a nivel de host o dominio.  
Cualquier opción especificada en un <VirtualHost> se aplica a todo el dominio. Sin embargo, no permite especificar opciones a nivel de directorio. Por suerte, Apache dispone de otras posibilidades para especificar la configuración.  
Los contenedores más usados son aquellos que permiten cambiar alguna configuración en determinados lugares del sistema de ficheros (a la vista de los discos locales para el sistema operativo) o del espacio web (a la vista del sitio ofrecido por el servidor web tal como lo ve el cliente).

Las directivas <Directory> y <Files>, junto con sus correspondientes contrapartes con expresiones regulares, se aplican directamente a partes del sistema de ficheros.

- Las directivas dentro de una sección <Directory> se aplican a la porción del sistema de ficheros correspondiente al directorio especificado y a todos sus subdirectorios (así como a todos los ficheros en esos directorios). El mismo efecto puede obtenerse usando ficheros .htaccess. Por ejemplo, la siguiente configuración habilita la opción Indexes para el directorio /var/web/dir1 y todos sus subdirectorios:

```apache
<Directory "/var/web/dir1">
    Options +Indexes
</Directory>
```

- Las directivas dentro de una sección <Files> solo se aplican a cualquier fichero con el nombre especificado, sin importar en qué directorio se encuentre. Por ejemplo, estas directivas en el fichero de configuración global niegan el acceso a cualquier fichero llamado private.html dondequiera que esté localizado:

```apache
<Files "private.html">
    Require all denied
</Files>
```

- Para referirse a ficheros en lugares particulares del sistema de ficheros, se pueden combinar las secciones <Files> y <Directory>. Por ejemplo, la siguiente configuración niega el acceso a los ficheros /var/web/dir1/private.html, /var/web/dir1/subdir2/private.html, /var/web/dir1/subdir3/private.html y cualquier otra instancia de private.html que esté bajo el directorio /var/web/dir1/:

```apache
<Directory "/var/web/dir1">
    <Files "private.html">
        Require all denied
    </Files>
</Directory>
```

- Si se necesita un emparejamiento más flexible, cada contenedor tiene su contraparte con expresiones regulares compatibles con Perl: <DirectoryMatch> y <FilesMatch>. Por ejemplo, usando expresiones regulares se puede denegar acceso a distintos tipos de imagen así:

```apache
<FilesMatch "\.(bmp|gif|jpe?g|png)$">
    Require all denied
</FilesMatch>
```

- La directiva <Location> y su contraparte con expresiones regulares <LocationMatch> cambian la configuración para contenido dentro del espacio web. Por ejemplo, esta configuración previene el acceso a cualquier ruta URL que empiece con /private, aplicándose a peticiones como http://yoursite.example.com/private, http://yoursite.example.com/private123 o http://yoursite.example.com/private/dir/file.html, así como cualquier otra petición que comience con /private.

```apache
<LocationMatch "^/private">
    Require all denied
</LocationMatch>
```

- Los ficheros .htaccess ("ficheros de configuración distribuidos") permiten hacer cambios en la configuración a nivel de directorio. Un fichero con directivas de configuración se coloca en un directorio específico y se aplican a ese directorio y a todos sus subdirectorios. Esto descentraliza la administración del servidor web. Cualquier opción especificada en una sección <Directory> puede normalmente especificarse también dentro de un fichero .htaccess.  
  Los ficheros .htaccess son útiles cuando el operador del sitio web tiene acceso para editar archivos en el directorio público del sitio, pero no en los ficheros de configuración global de Apache.

- Lo que se permite poner en ficheros .htaccess está determinado por la directiva AllowOverride, que especifica qué clases de directivas pueden aparecer en .htaccess. Cuando AllowOverride tiene el valor None y AllowOverrideList también es None, se ignoran completamente los ficheros .htaccess. Cuando toma el valor All, se permiten todas las directivas válidas en el contexto .htaccess dentro de esos ficheros.

Este bloque explica de forma clara y ordenada cómo funcionan las secciones de configuración en Apache y sus usos principales para administrar permisos y opciones a nivel de directorio o archivo.

```bash
<Directory "/var/web/dir1">
    Options +Indexes
</Directory>

<Files "private.html">
    Require all denied
</Files>

<Directory "/var/web/dir1">
    <Files "private.html">
        Require all denied
    </Files>
</Directory>

<FilesMatch "\.(bmp|gif|jpe?g|png)$">
    Require all denied
</FilesMatch>

<LocationMatch "^/private">
    Require all denied
</LocationMatch>
```

### Ficheros .htaccess

Los ficheros .htaccess (o "ficheros de configuración distribuidos") ofrecen una vía para hacer cambios en la configuración a nivel de directorio. Un fichero que contiene una o más directivas de configuración se coloca en un directorio en particular, y las directivas se aplican a ese directorio y a todos sus subdirectorios.

Así se descentraliza la administración del servidor web. Cualquier opción especificada en una sección <Directory> puede especificarse, en general, dentro de un fichero .htaccess. Los ficheros .htaccess son muy útiles en los casos en que el operador del sitio web tiene acceso para editar ficheros en el directorio público del sitio, pero no en los ficheros de configuración de Apache.

Lo que se pone en esos ficheros está determinado por el valor de la directiva AllowOverride. Esta directiva especifica, en categorías, qué directivas se les permite aparecer en los ficheros .htaccess. Cuando el servidor encuentra un fichero .htaccess, necesita saber qué directivas declaradas en ese fichero pueden anular o cambiar otras declaradas previamente.

La directiva AllowOverride solo es válida en secciones <Directory> especificadas sin expresiones regulares, y no está permitida en secciones <Location>, <DirectoryMatch> o <Files>.

Cuando esta directiva tiene el valor None y la directiva AllowOverrideList también tiene el valor None, los ficheros .htaccess se ignoran completamente. En ese caso, el servidor ni siquiera intenta leerlos del sistema de ficheros. Cuando toma el valor All, entonces se permite cualquier directiva válida en el contexto .htaccess en los ficheros .htaccess.

El valor de esta directiva puede ser uno de los siguientes para los grupos de directivas indicados:

- AuthConfig: Permite el uso de directivas de autorización (AuthGroupFile, AuthName, AuthType, AuthUserFile, Require, etc.).
- FileInfo: Permite el uso de directivas que controlan tipos de documentos, directivas del módulo mod_rewrite, del módulo mod_alias, y la directiva Action del módulo mod_actions.
- Indexes: Permite el uso de directivas que controlan el indexado y listado de directorios (AddDescription, AddIcon, DefaultIcon, DirectoryIndex, etc.).
- Limit: Permite el uso de directivas que controlan el acceso de hosts (Allow, Deny y Order).
- Nonfatal=[Override|Unknown|All]: Este valor hace que ante valores no permitidos por AllowOverride, los errores que aparezcan en los ficheros .htaccess se traten como no fatales. En lugar de causar un Error Interno del Servidor, las directivas no permitidas o desactivadas se ignoran y se muestra un mensaje de advertencia (warning) en los ficheros de log:
  - Nonfatal=Override trata directivas no permitidas por AllowOverride como no fatales.
  - Nonfatal=Unknown trata directivas no conocidas como no fatales, incluso de módulos no presentes.
  - Nonfatal=All trata ambos casos como no fatales.
- Options[=Option,...]: Permite el uso de directivas que controlan opciones a nivel de directorio (directiva Options). Un signo igual seguido de una lista de opciones separadas por comas sin espacios indica qué opciones en particular se pueden establecer con la directiva Options.

Ejemplo:

```bash
AllowOverride AuthConfig Indexes
```

Si se permite una directiva en los ficheros .htaccess, la documentación oficial de esa directiva tendrá una sección Override especificando qué valor debe tener AllowOverride para que se permita.

Los ficheros .htaccess se procesan para cada petición y se aplican para cada uno de los ficheros en el directorio actual. Las directivas también se aplican en los directorios que hay dentro del directorio procesado en la jerarquía del sistema de ficheros.

A pesar de la potencia y flexibilidad que dan los ficheros .htaccess, también hay desventajas. Si está habilitado su uso, Apache debe comprobar y procesar todas las directivas en esos ficheros en cada petición. Además, Apache debe consultar todos los ficheros .htaccess que hay en los directorios superiores en el sistema de ficheros, lo que puede causar pérdida de rendimiento.

Las opciones establecidas en .htaccess pueden anular opciones establecidas en bloques <Directory>, lo que puede causar confusión y comportamientos no deseados. Toda opción establecida en un fichero .htaccess también puede establecerse en un bloque <Directory>.

Permitir que usuarios sin privilegios modifiquen la configuración del servidor web puede ser un potencial fallo de seguridad. Sin embargo, los valores de AllowOverride pueden mitigar este riesgo considerablemente.

También se puede cambiar el valor de la directiva AccessFileName para especificar otro nombre para buscar estos ficheros, pero si se cambia, hay que usar un bloque <Files> para prevenir accesos no intencionados, lo cual no se recomienda por razones de seguridad.

En el fichero principal de configuración apache2.conf suele aparecer algo así:

```bash
AccessFileName .htaccess

<Files ~ "^\.ht">
    Require all denied
</Files>
```

La primera línea indica a Apache que busque ficheros .htaccess en los directorios de acceso público. La segunda línea indica que se denieguen todas las solicitudes explícitas a ficheros que comiencen por .ht, evitando que visitantes externos accedan a opciones de configuración, como el fichero .htpasswd.

### Módulos

La inclusión de módulos para ampliar la funcionalidad de Apache se realiza con la directiva **LoadModule** seguida del nombre del módulo y el nombre del archivo (o biblioteca) que lo contiene. Se necesitarán tantas directivas **LoadModule** como módulos vayan a ser usados.  
En Debian/Ubuntu, los módulos pueden ser habilitados o deshabilitados con los comandos **a2enmod** y **a2dismod**. El nombre del módulo coincide con el nombre del archivo que lo contiene (sin la extensión . conf).

```bash
a2enmod usertrack
a2dismod usertrack
```

Siempre es obligatorio, al habilitar o deshabilitar módulos, reiniciar el servicio Apache2.

## Control de acceso por equipos

El control de acceso puede hacerse a través de varios módulos. Los más importantes de ellos son `mod_authz_core` y `mod_authz_host`.  
Si se quiere restringir el acceso a porciones de un sitio web basándose en la dirección IP del visitante, la manera más sencilla es usar el módulo `mod_authz_host`.

La directiva `Require` tiene una gran variedad de formas para permitir o denegar acceso a recursos. En conjunto con las directivas de agrupamiento `RequireAll`, `RequireAny` y `RequireNone`, estos requisitos se pueden combinar de innumerables maneras para conseguir la política de acceso deseada.

La forma de usar estas directivas es la siguiente:

```bash
Require host address
Require ip ip.address
```

En la primera, la dirección es un nombre totalmente cualificado (FQDN) o un nombre parcial. También se pueden poner múltiples nombres o direcciones si es necesario.  
En la segunda forma, `ip.address` es una dirección IP, una dirección IP parcial, una pareja dirección de red/máscara o un bloque CIDR. También pueden usarse bloques CIDR.

Ejemplos:

```bash
Require ip 10.1.2.3
Require ip 192.168.1.104 192.168.1.205
Require ip 10.1
Require ip 10.1.0.0/255.255.0.0
Require ip 10.1.0.0/16
Require host ejemplo.org
Require host .net ejemplo.edu
```

Se puede insertar la palabra `not` para negar un requisito particular. En ese caso, como `not` es la negación de un valor, por sí solo no permite ni deniega una petición porque _no verdadero_ no implica _falso_.

Así, para denegar la visita usando una negación, el bloque debe tener al menos un elemento que se evalúe como verdadero o falso. Por ejemplo, si alguien está atacando al servidor y queremos denegarle el acceso, podemos hacerlo así:

```bash
<RequireAll>
   Require all granted
   Require not ip 10.252.46.165
</RequireAll>
```

## Contenedores de autorización

La directiva `Require` comprueba si un determinado usuario puede acceder de acuerdo con un proveedor de autorización y unas restricciones especificadas. El módulo `mod_authz_core` proporciona varios proveedores de autorización, de los cuales los más empleados son:

- `Require all granted`: Acceso incondicional permitido.
- `Require all denied`: Acceso incondicional denegado.

Ambos suelen encontrarse dentro de secciones `<Directory>`.

`<RequireAll>` y `</RequireAll>` también se usan para englobar un grupo de directivas de autorización de las que ninguna puede fallar y al menos una debe cumplirse para que el grupo se evalúe como exitoso. Si ninguna de las directivas dentro de `<RequireAll>` falla, y al menos una se evalúa de forma afirmativa, entonces el bloque se evalúa como exitoso. Si ninguna se evalúa de forma positiva y ninguna falla, el bloque se evalúa como neutral. En todos los demás casos, se evalúa como no exitoso.

`<RequireAny>` y `</RequireAny>` se emplean para englobar un grupo de directivas de autorización de las que al menos una tiene que evaluarse de forma afirmativa para que la directiva `<RequireAny>` sea exitosa. Si una o más directivas contenidas dentro de `<RequireAny>` se evalúan afirmativamente, entonces `<RequireAny>` es exitosa. Si ninguna es exitosa pero ninguna falla, se devuelve un resultado neutral. En los demás casos, la evaluación es negativa. Si se colocan varias directivas `Require` sin ningún agrupamiento, se supone que el agrupamiento implícito que las engloba es `<RequireAny>`.

`<RequireNone>` y `</RequireNone>` se utilizan para englobar grupos de directivas de autorización de las cuales ninguna debe evaluarse de forma positiva para que `<RequireNone>` no falle. Si una o más directivas contenidas dentro de `<RequireNone>` tienen éxito, la directiva `<RequireNone>` falla. En todos los demás casos, el resultado es neutral.  
Así, de la misma forma que la directiva `Require not`, no puede autorizar una petición de forma independiente, ya que nunca devuelve un resultado exitoso. Sin embargo, sí puede emplearse para restringir un conjunto de usuarios que de otro modo tendrían acceso a un recurso.

Los contenedores de autorización `<RequireAll>`, `<RequireAny>` y `<RequireNone>` se pueden combinar entre sí y con la directiva `Require` para construir una lógica de autorización compleja.

## Control de acceso por usuarios

Hay tres tipos de módulos involucrados en los procesos de autenticación y autorización. Es necesario escoger al menos un módulo de cada grupo.

- Tipos de Autenticación (mod_auth_basic y mod_auth_digest)
- Proveedor de autenticación (mod_authn_anon, mod_authn_dbd, mod_authn_dbm, mod_authn_file, mod_authnz_ldap y mod_authn_socache)
- Autorización (mod_authnz_ldap, mod_authz_dbd, mod_authz_dbm, mod_authz_groupfile, mod_authz_host, mod_authz_owner y mod_authz_user)

Además de estos módulos, también están los módulos mod_authn_core y mod_authz_core, que implementan directivas propias comunes a todos los módulos de autenticación.  
También el módulo mod_authnz_ldap ofrece a la vez autenticación y proveedor de autorización. El módulo mod_authz_host ofrece autorización y control de acceso basado en el nombre del equipo, dirección IP o características de la petición, pero no es parte del sistema de proveedores de autenticación.

Las directivas tratadas aquí deben estar dentro de alguna sección de configuración del servidor principal, típicamente en una sección `<Directory>` o en un fichero de configuración de directorio `.htaccess`.

Si se pretende usar ficheros `.htaccess` hay que poner en la directiva `AllowOverride` un valor que permita directivas de autenticación en esos ficheros. Los valores deben ser `AuthConfig` o `All`.

Finalmente, la directiva `Require`, sola o agrupada con `<RequireAll>`, `<RequireAny>` o `<RequireNone>`, indica a qué usuarios se les permite ver el contenido del directorio.

### Autenticación Basic

El módulo `mod_auth_basic` permite el uso de la autenticación HTTP Basic para restringir el acceso comprobando los usuarios en el proveedor indicado.  
Este módulo debe combinarse con un módulo de autenticación, como puede ser `mod_authn_file`, y un módulo de autorización como puede ser `mod_authz_user`.  
Hay que tener en cuenta que la contraseña se envía al servidor codificada con el algoritmo base64, el cual tiene un algoritmo inverso que permite una decodificación sencilla.

Para escoger este módulo es necesario poner el valor `Basic` en la directiva `AuthType`. Esta directiva establece el nombre del dominio (realm) de autorización para un directorio. Este nombre de dominio se le muestra al cliente para que sepa qué nombre de usuario y contraseña debe introducir.  
Si este nombre de dominio contiene espacios debe estar entre comillas dobles. La cadena introducida en la directiva `AuthName` coincide con el mensaje que aparece en el cuadro de diálogo de autenticación en muchos navegadores.

Así, por ejemplo, si un usuario se autenticó en el nombre de dominio “Área restringida”, automáticamente se usará el mismo usuario y contraseña siempre que se indique ese mismo dominio. Así se impide que se le pregunte el usuario y contraseña más de una vez en el mismo dominio. Por supuesto, si cambia el nombre del equipo cliente o su dirección IP, se debe introducir de nuevo la información de login.

Luego, se necesita un proveedor de autenticación. Si se usa `mod_auth_basic` como tipo de autenticación, se debe poner en la directiva `AuthBasicProvider` uno de los siguientes valores: `file` para usar el módulo `mod_authn_file`, `dbm` para usar el módulo `mod_authn_dbm` o `dbd` para el módulo `mod_authn_dbd`.  
Uno de los valores más típicos es `file`. En ese caso se necesita un fichero de texto con los nombres de usuario y contraseñas que sea legible por el usuario con el que corre Apache2. El fichero se crea con el comando `htpasswd` que viene con la instalación de Apache. Para establecer cuál es ese fichero se usa la directiva `AuthUserFile`. Ejemplo:

```bash
# Primera vez - la opción -c para crear el fichero.
htpasswd -c /usr/local/apache/passwd/passwords rbowen

# Para añadir nuevos usuarios después.
htpasswd /usr/local/apache/passwd/passwords joesmith
```

Finalmente, la directiva `Require`, sola o agrupada con `<RequireAll>`, `<RequireAny>` o `<RequireNone>`, indica qué usuarios pueden ver el contenido del directorio. Un ejemplo de configuración puede ser este:

```bash
AuthType Basic
AuthName "Restricted Files"
AuthBasicProvider file
AuthUserFile "/usr/local/apache/passwd/passwords"
Require user rbowen
```

### Autenticación Digest

El módulo `mod_auth_digest` implementa la autenticación HTTP con el algoritmo MD5 para codificar contraseñas, y es una alternativa a `mod_auth_basic` en la que la contraseña no se transmite en texto plano. Sin embargo, esto no supone una mejora de seguridad sobre la autenticación básica, ya que el algoritmo MD5 está roto desde hace años. Por otro lado, el almacenamiento de la contraseña en el servidor es menos seguro con autenticación digest que con autenticación basic. Por ello es mejor usar autenticación basic junto con el módulo `mod_ssl`.

Para escoger este módulo es necesario poner el valor `Digest` en la directiva `AuthType`. Igual que con `mod_auth_basic`, la directiva `AuthName` establece el nombre del dominio (realm) de un directorio. Este nombre se muestra al cliente para indicarle qué usuario y contraseña debe introducir. Además, se usa el comando `htdigest` para crear las contraseñas de los usuarios.

De forma similar al módulo `mod_auth_basic`, es necesario un proveedor de autenticación. La directiva `AuthDigestProvider` debe especificar uno de estos tres valores: file, dbm o dbd, dependiendo del módulo que se vaya a usar.

Si se elige el valor `file`, con la utilidad `htdigest` se puede crear la lista de usuarios. El uso es similar a `htpasswd`, pero además se debe especificar el nombre del dominio en el momento de la creación, y debe coincidir con el indicado en la directiva `AuthName`. Ejemplo:

```bash
# Primera vez - la opción -c para crear el fichero.
htdigest -c /usr/local/apache/passwd/passwords myrealm rbowen

# Para añadir usuarios después.
htdigest /usr/local/apache/passwd/passwords myrealm joesmith
```

Finalmente, la directiva `Require`, sola o agrupada con `<RequireAll>`, `<RequireAny>` o `<RequireNone>`, indica qué usuarios tienen permiso para ver el contenido del directorio. Un ejemplo de configuración puede ser este:

```bash
AuthType Digest
AuthName myrealm
AuthDigestProvider file
AuthUserFile "/usr/local/apache/passwd/passwords"
Require user rbowen
```

Autorización por grupos de usuarios  
Las directivas anteriores solo permiten a una persona (o a varias si se especifica una lista de usuarios) acceder al directorio. En muchos casos, se quiere permitir el acceso a varias personas. Aquí es donde entra la directiva `AuthGroupFile`.

Si queremos que más de una persona pueda acceder, necesitaremos crear un fichero con grupos de usuarios que asocie nombres de grupos con listas de usuarios de cada grupo. El formato de ese fichero es sencillo y se puede crear con cualquier editor. El contenido puede ser como este:

```bash
GroupName: rbowen dpitts sungo rshersey
```

Consiste en una lista de usuarios separada por espacios. Solo queda modificar los archivos `.htaccess` o los bloques `<Directory>` de forma similar a esto:

```bash
AuthType Basic
AuthName "By Invitation Only"
AuthBasicProvider file
AuthUserFile "/usr/local/apache/passwd/passwords"
AuthGroupFile "/usr/local/apache/passwd/groups"
Require group GroupName
```

Ahora, cualquiera que aparezca en la lista `GroupName` y también en el fichero de contraseñas, podrá acceder si introduce la contraseña correcta.

También hay otra manera de permitir que múltiples usuarios puedan acceder, aunque es menos específica. En lugar de crear un grupo de usuarios, se puede usar la siguiente directiva:

```bash
Require valid-user
```

Con esta directiva, cualquiera que aparezca en el fichero de contraseñas y ponga la contraseña correcta podrá acceder.

## Ficheros de log

Para gestionar de manera efectiva un servidor web, es necesario tener retroalimentación sobre la actividad y el rendimiento del servidor, así como de los problemas que pueden ocurrir. El servidor HTTP Apache proporciona una variedad de mecanismos para registrar todo lo que ocurre en el servidor, desde la petición inicial, pasando por el mapeo de la URL, hasta la resolución final de la conexión, incluyendo los errores que pueden ocurrir en el proceso. Además, módulos de terceros pueden ofrecer capacidad de registro o inyectar entradas en los ficheros de log, y también aplicaciones como programas CGI, scripts PHP u otros pueden enviar mensajes al log del servidor.

Cualquier persona que tenga permisos para escribir en el directorio donde el demonio httpd de Apache escribe un fichero de log, puede obtener acceso al UID con el que se inició el servidor, que normalmente no es root. NO se debe dar acceso a los directorios donde se almacenan los ficheros de log sin conocer las posibles implicaciones.

### Log de errores

El registro de log de errores del servidor, cuyo nombre y ubicación se establece con la directiva `ErrorLog`, es el fichero de log más importante. Aquí es donde Apache envía información de diagnóstico y registra cualquier error ocurrido en el procesamiento de las peticiones. Es el primer lugar donde se debe mirar cuando hay un fallo al iniciar el servidor o durante su operación, ya que frecuentemente contiene detalles sobre qué está mal y cómo solucionarlo.

El log de errores habitualmente se escribe en un fichero (normalmente `error.log` en sistemas Unix/Linux). En sistemas Unix es posible hacer que el servidor envíe errores al syslog o los retransmita a otro programa. En Debian, el fichero más común es `/var/log/apache2/error.log`.

Ejemplo:

```bash
ErrorLog /var/log/apache2/myvirtualhost/error.log
```

Si la ruta al fichero no es absoluta, se asume que es relativa al valor de la directiva `ServerRoot`. El formato del log de errores se define con la directiva `ErrorLogFormat`, que permite personalizar los valores que se registran. Si no se establece, se usa un formato por defecto.

Ejemplo de formato por defecto:

```bash
ErrorLogFormat "[%t] [%l] [pid %P] %F: %E: [client %a] %M"
```

Un mensaje típico puede ser:

```bash
[Fri Sep 09 10:42:29.902022 2011] [core:error] [pid 35708:tid 4328636416] [client 72.15.99.187] File does not exist: /usr/local/apache2/htdocs/favicon.ico
```

El primer elemento en la entrada del log es la fecha y hora del mensaje. Luego viene el módulo que produjo el mensaje (`core` en este caso) y el nivel de severidad del error. Después está el ID del proceso (y si aplica, ID del hilo que provocó la condición). Seguidamente, la dirección que realizó la petición y finalmente la descripción detallada del error, que en este caso indica que falta un fichero.

En el log de errores pueden aparecer muchos tipos de mensajes, muchos similares al ejemplo anterior. También puede contener información de depuración de scripts CGI, ya que cualquier texto escrito en `stderr` por un script CGI se copia directamente al fichero de log de errores.

Durante las pruebas, es común monitorizar continuamente el log de errores para detectar problemas. En sistemas Linux esto puede hacerse usando:

```bash
tail -f /var/log/apache2/error_log
```

### Logs de accesos

El fichero de log de accesos registra todas las peticiones procesadas por el servidor. La ubicación y el contenido del fichero de log de accesos se controla con la directiva `CustomLog`. La directiva `LogFormat` puede usarse para simplificar la selección de contenido de los logs. Aquí se describe cómo configurar el servidor para registrar información en el log de accesos.

La directiva `CustomLog`, además del fichero donde se guarda el log, también puede especificar un formato explícito o un alias definido por una directiva `LogFormat` anterior. Si la ruta no es absoluta, se asume que es relativa a la directiva `ServerRoot`.

Ejemplo:

```bash
# CustomLog con nombre de formato
LogFormat "%h %l %u %t \"%r\" %>s %b" common
CustomLog "logs/access_log" common

# CustomLog con cadena de formato explícita
CustomLog "logs/access_log" "%h %l %u %t \"%r\" %>s %b"
```

El formato de los logs de acceso es altamente configurable, definido por una cadena similar a la utilizada en la función `printf()` del lenguaje C.

Se pueden crear múltiples logs de acceso simplemente especificando varias directivas `CustomLog` en la configuración. Por ejemplo, las siguientes directivas crean tres logs de acceso. El primero contiene información básica, mientras que el segundo y tercero registran la página desde la que se llegó y el navegador utilizado por el usuario, respectivamente:

```bash
LogFormat "%h %l %u %t \"%r\" %>s %b" common
CustomLog logs/access_log common
CustomLog logs/referer_log "%{Referer}i -> %U"
CustomLog logs/agent_log "%{User-agent}i"
```

### Hosts Virtuales

Cuando se ejecuta un servidor con varios hosts virtuales, hay varias opciones para manejar los ficheros de logs. Una opción es usar los logs igual que en un servidor individual. Simplemente poniendo las directivas de log fuera de las secciones `<VirtualHost>` en el contexto del servidor principal, se puede registrar todas las peticiones en el mismo log de acceso. Esta técnica no permite una colección de estadísticas por servidor virtual sencilla.

Si las directivas `CustomLog` o `ErrorLog` se establecen dentro de bloques `<VirtualHost>`, entonces todas las peticiones o errores de ese host virtual en particular se registran en un fichero específico para ese host virtual. Cualquier host virtual que no tenga directivas de log usará el log del servidor principal.

Otra opción es añadir información del host virtual en la cadena de formato del log para hacer un log unificado de todos los hosts en un mismo fichero, y luego dividirlos si se necesita. Por ejemplo:

```bash
LogFormat "%v %l %u %t \"%r\" %>s %b" commonvhost
CustomLog logs/access_log commonvhost
```

En este caso, `%v` se usa para registrar el nombre del host virtual que está sirviendo la petición.

## Mensajes de error personalizados

Aunque el servidor HTTP Apache dispone de respuestas genéricas para los códigos de estado HTTP 4xx y 5xx, estas respuestas a veces son un poco concisas, poco informativas y pueden intimidar a los usuarios del sitio. Se pueden proporcionar respuestas personalizadas, que son más amigables, en otro idioma diferente al inglés o más acordes con el diseño del sitio web. Las respuestas personalizadas se pueden definir para cada código de estado HTTP considerado como una condición de error, es decir, para códigos 4xx y 5xx.

También existe un conjunto de valores para que los documentos con mensajes de error puedan personalizarse basándose en los valores de esas variables, usando inclusiones del lado del servidor (Server Side Includes). También se pueden tener condiciones de error gestionadas por un programa CGI o cualquier otro manejador (PHP, mod_perl, etc.) que use esas variables.

Los documentos de error se configuran con la directiva `ErrorDocument`, que puede usarse en contexto global, virtualhost, directorio o en ficheros `.htaccess` si la directiva `AllowOverride` tiene el valor `FileInfo`.

Ejemplos:

```bash
ErrorDocument 500 "Sorry, our script crashed. Oh dear"
ErrorDocument 500 /cgi-bin/crash-recover
ErrorDocument 500 http://error.exemplo.com/server_error
ErrorDocument 404 /errors/not_found.html
ErrorDocument 401 /subscription/how_to_subscribe.html
```

La sintaxis de la directiva `ErrorDocument` es:

```bash
ErrorDocument <código-de-3-dígitos> <acción>
```

Donde la acción puede ser:

- Una URL local a la que redirigir (si la acción empieza con una "/").
- Una URL externa a la que redirigir (si la acción es una URL válida).
- Texto a mostrar (en cualquier otro caso). El texto debe ir entre comillas dobles (") si consta de más de una palabra.

## HTTPS

TLS, o transport layer security, y su predecesor SSL, secure sockets layer, son los protocolos seguros creados para envolver el tráfico normal en una capa de seguridad. Estos protocolos permiten que el tráfico se transmita de forma segura entre las partes remotas sin la posibilidad de que sea interceptado y leído por cualquiera que esté en medio. Son también instrumentos para validar la identidad de dominios y servidores a través de internet estableciendo canales seguros y auténticos mediante una autoridad certificadora.

El soporte de SSL viene de serie con el paquete de Apache2 en Ubuntu/Debian. Solo es necesario habilitar el módulo ssl para emplear todas las ventajas que provee SSL en nuestro sistema.

En este momento podemos pensar en hosts virtuales que soporten conexiones con protocolos http y https, pero no es aconsejable. Es mejor crear un host virtual nuevo que soporte SSL.

Lo esencial que hay que hacer para que HTTPS funcione es tener un par de clave privada y certificado digital. La manera de obtener clave privada y certificado no es relevante. Es posible obtener un certificado digital auto firmado con el siguiente comando:  
openssl req -new -x509 -days 365 -nodes -out meusitio.pem -keyout meusitio.key

Si hacemos eso, tenemos que tener en cuenta que cualquier navegador puede no reconocer el certificado y será necesaria una excepción.

En esta [guía](https://www.digitalocean.com/community/tutorials/how-to-secure-apache-with-let-s-encrypt-on-ubuntu-22-04) podemos obtener un certificado válido para usar con Apache2.

Finalmente, el nuevo host virtual que emplea el protocolo https puede ser como este:

````bash
<VirtualHost *:443>
    ServerName www.exemplo.com

    SSLEngine on
    SSLCertificateFile "/etc/ssl/certs```usitio.pem"
    SSLCertificateKeyFile "/etc/ssl```ivate/meusitio.key"
    ...
</VirtualHost>
````

También podemos desactivar las versiones 2 y 3 de SSL por estar obsoletas con:  
SSLProtocol all -SSLv3

Más información en la documentación oficial de Apache sobre [encriptación](https://httpd.apache.org/docs/2.4/en/ssl/ssl_intro.html).
