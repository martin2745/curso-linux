# Criterios de Ampliación por Tipo de Sección

Este archivo contiene guías concretas sobre qué añadir en cada tipo de sección habitual en apuntes de servicios en red en Linux. Consultar antes de ampliar cualquier explicación.

---

## Por tipo de sección

### Sección de Introducción / ¿Qué es X?

Verificar que la introducción cubre:
- **Qué es** el servicio (definición funcional)
- **Para qué sirve** (casos de uso principales)
- **Cómo funciona** a alto nivel (modelo cliente/servidor, protocolo base)
- **Características principales** (modularidad, plataformas, protocolos soportados)

Si falta alguno de estos elementos, añadirlos. Ejemplos de ampliación habituales:

- Apache: mencionar los **MPM (Multi-Processing Modules)** — `prefork`, `worker`, `event` — y su impacto en el rendimiento y concurrencia.
- SSH: mencionar el uso de **pares de claves** como alternativa más segura a la contraseña.
- DNS: distinguir entre **servidor autoritativo** y **servidor recursivo/caché**.
- DHCP: mencionar el proceso **DORA** (Discover, Offer, Request, Acknowledge).
- FTP: advertir que FTP transmite en texto plano y mencionar FTPS/SFTP como alternativas seguras.
- Samba: mencionar la integración con dominios Windows y Active Directory.
- NFS: mencionar versiones (NFSv3 vs NFSv4) y sus diferencias en seguridad.

---

### Sección de Instalación

Verificar que se explica:
- El gestor de paquetes usado y el nombre del paquete
- Cómo verificar que el servicio quedó activo tras la instalación
- El usuario del sistema con el que corre el servicio (ej: `www-data` para Apache)
- El puerto por defecto en el que escucha

Si solo hay el comando de instalación sin explicación posterior, añadir:

```markdown
> **Nota:** Tras la instalación, el servicio se inicia automáticamente en sistemas Debian/Ubuntu. Puedes verificarlo con `systemctl status <servicio>`.
```

---

### Sección de Archivos de Configuración

Si el documento lista archivos de configuración, verificar que se explica:
- La función de cada archivo o directorio
- La diferencia entre directorios `*-available` y `*-enabled` (cuando aplique)
- El concepto de enlace simbólico en este contexto

Ampliación estándar para la diferencia available/enabled:

> Los directorios `*-available` contienen las configuraciones disponibles en el sistema, mientras que `*-enabled` contiene únicamente enlaces simbólicos a las configuraciones activas. Esta separación permite habilitar y deshabilitar configuraciones sin eliminarlas, facilitando la gestión del servicio.

---

### Sección de Puertos y Escucha

Verificar que se explica:
- Qué directiva controla el puerto de escucha
- Cómo escuchar en múltiples puertos o interfaces
- La diferencia entre escuchar en todas las interfaces (`*` o `0.0.0.0`) vs. una interfaz específica
- Implicaciones de seguridad de exponer un servicio en todas las interfaces

Callout de seguridad habitual:

```markdown
> **Advertencia:** Escuchar en todas las interfaces (`*`) expone el servicio a todas las redes a las que está conectado el equipo. En entornos de producción, limitar la escucha a la interfaz necesaria.
```

---

### Sección de Virtual Hosts / Sitios Virtuales

Para Apache u otros servidores web, verificar que se explica:
- La diferencia entre VirtualHosts **basados en nombre** y **basados en IP**
- Cuándo usar cada tipo
- El concepto de VirtualHost "por defecto" o catch-all
- Las directivas mínimas necesarias: `ServerName`, `DocumentRoot`

Ampliación habitual sobre la resolución de nombres:

> Cuando se usan hosts virtuales basados en nombre en un entorno local (sin DNS), es necesario editar el archivo `/etc/hosts` del cliente para asociar el nombre de dominio con la IP del servidor. En Windows, este archivo se encuentra en `C:\Windows\System32\drivers\etc\hosts`.

---

### Sección de Módulos

Verificar que se explica:
- Qué es un módulo y cuál es su propósito
- La diferencia entre módulo y configuración (si no está ya en el documento)
- Los comandos para habilitar/deshabilitar módulos
- La necesidad de reiniciar el servicio tras cambios en módulos

```markdown
> **Importante:** Cada vez que se habilite o deshabilite un módulo con `a2enmod` / `a2dismod` (o equivalente), es obligatorio reiniciar el servicio para que los cambios surtan efecto.
```

---

### Sección de Control de Acceso

Verificar que se explica:
- Qué módulos están involucrados
- La lógica de las directivas de agrupamiento (`RequireAll`, `RequireAny`, `RequireNone`)
- La diferencia entre control de acceso por **host/IP** y por **usuario/contraseña**
- Las implicaciones de seguridad

---

### Sección de Autenticación

Verificar que se explica:
- Los **tres tipos de módulos** implicados: tipo de autenticación, proveedor, autorización
- La diferencia entre autenticación **Basic** y **Digest** y cuál es más segura (y por qué)
- Cómo crear y gestionar el archivo de contraseñas
- La directiva `Require` y sus variantes

Ampliación estándar para autenticación Basic:

> La autenticación HTTP Basic codifica las credenciales en Base64, que **no es cifrado** — cualquiera que intercepte el tráfico puede decodificarlo trivialmente. Por este motivo, la autenticación Basic **solo debe usarse sobre HTTPS** (con `mod_ssl` activo).

Ampliación estándar para autenticación Digest:

> Aunque Digest no transmite la contraseña en texto plano (usa un hash MD5), el algoritmo MD5 está considerado criptográficamente roto desde hace años. La recomendación actual es usar autenticación Basic sobre HTTPS en lugar de Digest, ya que ofrece mejor seguridad en la transmisión y mejor compatibilidad con clientes modernos.

---

### Sección de Logs

Verificar que se explica:
- Dónde se almacenan los logs (ruta por defecto)
- Los tipos de log principales (errores y accesos)
- Cómo monitorizar los logs en tiempo real
- La directiva `LogLevel` y sus niveles (si no está en el documento)

Ampliación estándar sobre `LogLevel`:

> La directiva `LogLevel` controla la verbosidad del log de errores. Los niveles disponibles, de menor a mayor detalle, son: `emerg`, `alert`, `crit`, `error`, `warn`, `notice`, `info` y `debug`. El nivel por defecto es `warn`. Durante la depuración de problemas se recomienda usar `info` o `debug`, pero volver a `warn` en producción para evitar logs excesivamente grandes.

---

### Sección de HTTPS / SSL / TLS

Verificar que se explica:
- La diferencia entre SSL y TLS (TLS es el sucesor moderno de SSL)
- El concepto de **par clave privada / certificado**
- La diferencia entre certificado **autofirmado** y certificado emitido por una **Autoridad Certificadora (CA)**
- Por qué los navegadores no confían en certificados autofirmados
- Cómo deshabilitar versiones obsoletas de SSL/TLS

Ampliación estándar sobre el proceso TLS:

> Durante el establecimiento de una conexión HTTPS, se produce un **TLS Handshake**: el servidor presenta su certificado, el cliente verifica su autenticidad contra una CA de confianza, y ambas partes negocian los algoritmos de cifrado y establecen las claves de sesión. Solo entonces comienza la transmisión cifrada de datos.

Callout sobre versiones obsoletas:

```markdown
> **Advertencia:** Las versiones SSLv2, SSLv3 y TLSv1.0 tienen vulnerabilidades conocidas (POODLE, BEAST, etc.). Deben deshabilitarse explícitamente en la configuración del servidor. Usar únicamente TLSv1.2 o TLSv1.3.
```

---

### Sección de Mensajes de Error Personalizados

Verificar que se explica:
- Qué códigos de error se pueden personalizar (4xx y 5xx)
- Los tres tipos de acción posibles (texto, URL local, URL externa)
- En qué contextos puede usarse la directiva (`ErrorDocument`)

---

## Por servicio — Conceptos que siempre merecen explicación adicional

### Apache HTTP Server
- MPM (Multi-Processing Modules): `prefork`, `worker`, `event`
- Diferencia entre `sites-available` / `sites-enabled` y `mods-available` / `mods-enabled`
- Comandos `a2ensite`, `a2dissite`, `a2enmod`, `a2dismod`
- Directiva `AllowOverride` y sus implicaciones de seguridad
- `mod_rewrite` para reescritura de URLs
- `mod_security` como WAF básico

### Nginx
- Modelo de procesos basado en eventos vs. Apache (mencionar cuando se compare)
- Bloque `server` equivalente a VirtualHost
- Directiva `location` y sus tipos de coincidencia
- Diferencia entre `proxy_pass` y `fastcgi_pass`

### SSH
- Diferencia entre autenticación por contraseña y por clave pública
- Archivo `authorized_keys`
- Opciones de hardening: deshabilitar `PermitRootLogin`, cambiar puerto por defecto
- Uso de `ssh-keygen` y `ssh-copy-id`

### DNS (BIND/named)
- Tipos de registros: A, AAAA, CNAME, MX, NS, PTR, SOA, TXT
- Diferencia entre zona directa e inversa
- Concepto de TTL
- Diferencia entre `named.conf`, `named.conf.options`, `named.conf.local`

### DHCP (isc-dhcp-server / kea)
- Proceso DORA
- Diferencia entre asignación dinámica y reserva estática (por MAC)
- Parámetros de red distribuidos: gateway, DNS, máscara

### FTP (vsftpd / proftpd)
- Modos activo y pasivo y sus implicaciones con firewalls
- Advertencia de seguridad: FTP transmite en texto plano
- Alternativas seguras: FTPS (FTP sobre TLS) y SFTP (SSH File Transfer Protocol)
- Usuarios virtuales vs. usuarios del sistema

### Samba
- Niveles de seguridad: `user`, `domain`, `ads`
- Tipos de recurso compartido: `[homes]`, `[printers]`, recursos personalizados
- Comandos `smbpasswd`, `testparm`, `smbclient`

### NFS
- Diferencia entre NFSv3 y NFSv4 (seguridad, Kerberos, estado)
- Archivo `/etc/exports` y sus opciones (`ro`, `rw`, `sync`, `no_root_squash`)
- Comandos `exportfs`, `showmount`
