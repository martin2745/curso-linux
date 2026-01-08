# **Solución 01: Servidor Web Apache**

### **Comandos Utilizados**

1. Proceso de instalación de Apache.

```bash
root@debian:~# apt update && apt install -y apache2
```

2. Verificación del funcionamiento y escucha de puertos (puerto 80).

```bash
root@debian:~# systemctl status apache2
● apache2.service - The Apache HTTP Server
     Loaded: loaded (/lib/systemd/system/apache2.service; enabled; preset: enabled)
     Active: active (running) since Fri 2025-09-12 06:04:30 CEST; 50s ago
       Docs: https://httpd.apache.org/docs/2.4/
   Main PID: 4355 (apache2)
      Tasks: 55 (limit: 4620)
     Memory: 17.6M
        CPU: 87ms
     CGroup: /system.slice/apache2.service
             ├─4355 /usr/sbin/apache2 -k start
             ├─4356 /usr/sbin/apache2 -k start
             └─4357 /usr/sbin/apache2 -k start

sep 12 06:04:30 debian systemd[1]: Starting apache2.service - The Apache HTTP Server...
sep 12 06:04:30 debian apachectl[4354]: AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using >
sep 12 06:04:30 debian systemd[1]: Started apache2.service - The Apache HTTP Server.
```

```bash
root@debian:~# ss -putan | grep 80
tcp   LISTEN 0      511                        *:80                 *:*    users:(("apache2",pid=4357,fd=4),("apache2",pid=4356,fd=4),("apache2",pid=4355,fd=4))
```

3. Creación del host virtual.

```bash
root@debian:/etc/apache2/sites-available# cp -pv 000-default.conf apache2practica.gal.conf
'000-default.conf' -> 'apache2practica.gal.conf'
```

4. Editamos el archivo de configuración con el siguiente resultado.

```bash
root@debian:/etc/apache2/sites-available# cat apache2practica.gal.conf
# Define el VirtualHost que escucha en la IP correspondiente y el puerto definido
<VirtualHost 10.158.120.142:80>

    # Nombre de dominio del sitio
    ServerName apache2practicas.gal
    ServerAlias www.apache2practicas.gal
    # Nombre del administrador del sitio y directorio raíz
    ServerAdmin webmaster@apache2practicas.gal
    DocumentRoot /var/www/apache2practicas.gal

    # Logs
    ## Archivo de error del sitio
    ErrorLog ${APACHE_LOG_DIR}/error_apache2practicas.gal.log
    ## Archivo de accesos del sitio
    CustomLog ${APACHE_LOG_DIR}/access_so2practicas.log vhost_combined

    # Mensaxes de erro
    ErrorDocument 404 http://apache2practicas.gal/errores/error_404.html
    ErrorDocument 401 "No estás autorizado"

    # Configuración de directorios
    ## Configuración del directorio principal
    ### Directivas
    ### DirectoryIndex: Prioridad de archivos por defecto
    ### Options Indexes: Permite listar directorios si no hay archivo index
    ### AllowOverride all: Permite a los .htaccess sobreescribir directivas del servidor
    ### Require: Permite acceso a equipos en unos rangos de IP. Tambien se permite el acceso desde localhost

    <Directory "/var/www/apache2practicas.gal">
        DirectoryIndex index.php index.html
        Options Indexes
        AllowOverride all
        Require ip 192.168.100.0/24
        Require ip 10.0.0.0/16
        Require host localhost
    </Directory>

    ## Configuración de subdirectorio
    ### Directivas
    ### DirectoryIndexes: Archivo por defecto en este directorio.
    ### Options -Indexes: No permite listar si no existe archivo indice.html.
                #### Anteriormente se hizo uso de Options Indexes: Con el "-" desactivamos esta directiva que teniamos heredada.
    ### AuthType Basic: Tipo de autenticación HTTP básica para el acceso.
    ### AuthName: Mensaje de la ventana de autenticación.
    ### AuthBasicProvider file y AuthUserFile: Definen el archivo de las credenciales de usuario.
    ### RequireAll: Obliga a cumplir las ambas las condiciones, sin ella, con el cumplimiento de una sola bastaría.
    <Directory "/var/www/apache2practicas.gal/privado">
        DirectoryIndex indice.html
        Options -Indexes
        AuthType Basic
        AuthName "Acceso restringido"
        AuthBasicProvider file
        AuthUserFile "/usr/local/apache/passwd/passwords"
        <RequireAll>
            Require ip 10.158.120.251
            Require user martin
        </RequireAll>
    </Directory>
</VirtualHost>
```

5. Definimos el fichero de contraseñas para la autenticación Basic.

```bash
root@debian:~# mkdir -p /usr/local/apache/passwd
root@debian:~# htpasswd -c /usr/local/apache/passwd/passwords martin
New password:
Re-type new password:
Adding password for user martin
```

_*Nota*_: Definimos el fichero de contraseñas en `/usr/local` ya que `/usr` es donde se almacenan los archivos del sistema que son compartidos entre todos los usuarios, como bibliotecas, programas y documentación. Es la ubicación estándar para software que se instala desde los repositorios del sistema o por el administrador del sistema. Este directorio está subdividido en bin, sbin, lib siendo estos enlaces débiles somo se mostraba anteriormente y que tendrán acceso todos los usuarios del sistema. Su nombre viene de user system resources.

6. Creamos el directorio del sitio web.

```bash
root@debian:~# mkdir /var/www/apache2practicas.gal
root@debian:~# mkdir /var/www/apache2practicas.gal/privado
```

7. Creamos la página web.

Web Principal

```bash
root@debian:~# cat /var/www/apache2practicas.gal/index.html
<html>
        <head>
                <meta charset="utf8">
                <title>Servidor Web Apache</title>
        </head>
        <body>
                <h1>Servidor Web Apache</h1>
                <h3>Martín Gil Blanco</h3>
        </body>
</html>
```

Espacio privado.

```bash
root@debian:~# cat /var/www/apache2practicas.gal/privado/indice.html
<html>
        <head>
                <meta charset="utf8">
                <title>Zona privada</title>
        </head>
        <body>
                <h1>Privado</h1>
                <h3>Martín Gil Blanco</h3>
        </body>
</html>
```

Error 404.

```bash
root@debian:~# cat /var/www/apache2practicas.gal/errores/error_404.html
<html>
        <head>
                <meta charset="utf8">
                <title>Error 404</title>
        </head>
        <body>
                <h1>No existe el recurso</h1>
        </body>
</html>
```

8. Habilitamos el sitio web.

```bash
root@debian:~# ls /etc/apache2/sites-available/
000-default.conf  apache2practica.gal.conf  default-ssl.conf

root@debian:~# ls /etc/apache2/sites-enabled/
000-default.conf

root@debian:~# a2ensite apache2practica.gal.conf
Enabling site apache2practica.gal.
To activate the new configuration, you need to run:
  systemctl reload apache2

root@debian:~# ls /etc/apache2/sites-enabled/
000-default.conf  apache2practica.gal.conf
```

_*Nota*_: Podemos comprobar si la sintaxis de los archivos de configuración son correctos con _apache2ctl -t_.

9. Reiniciamos el servicio apache.

```bash
root@debian:~# systemctl reload apache2
```

10. Acceso al contenido.

_*Nota*_: Llegados a este punto podemos con un navegador acceder a: `http://10.158.120.142/` o configurar el archivo de `/etc/hosts` si nuestro anfitrión es linux o `C:\Windows\System32\drivers\etc\hosts` en caso de Windows.

Rutas de acceso:

- http://apache2practicas.gal
- http://apache2practicas.gal/privado/
- http://apache2practicas.gal/privado/sadfg
