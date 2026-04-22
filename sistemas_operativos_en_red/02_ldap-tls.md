# TLS en OpenLDAP (slapd) — Ubuntu Server 24.04.3 LTS
### Escenario práctico: Centro Educativo IES Ejemplo

## Índice

1. [Introducción](#introducción)
   - 1.1 [¿Por qué TLS en LDAP?](#por-qué-tls-en-ldap)
   - 1.2 [StartTLS vs LDAPS](#starttls-vs-ldaps)
   - 1.3 [Infraestructura de clave pública (PKI)](#infraestructura-de-clave-pública-pki)
2. [Generación de certificados](#generación-de-certificados)
   - 2.1 [Crear la Autoridad Certificadora (CA)](#crear-la-autoridad-certificadora-ca)
   - 2.2 [Crear el certificado del servidor LDAP](#crear-el-certificado-del-servidor-ldap)
   - 2.3 [Verificar los certificados generados](#verificar-los-certificados-generados)
3. [Configuración de TLS en slapd](#configuración-de-tls-en-slapd)
   - 3.1 [Copiar los certificados al directorio de slapd](#copiar-los-certificados-al-directorio-de-slapd)
   - 3.2 [Aplicar la configuración TLS mediante LDIF](#aplicar-la-configuración-tls-mediante-ldif)
   - 3.3 [Verificar la configuración aplicada](#verificar-la-configuración-aplicada)
   - 3.4 [Reiniciar y comprobar el servicio](#reiniciar-y-comprobar-el-servicio)
4. [Verificación de TLS desde el servidor](#verificación-de-tls-desde-el-servidor)
5. [Distribución del certificado CA a los clientes](#distribución-del-certificado-ca-a-los-clientes)
   - 5.1 [Copiar el certificado CA al cliente](#copiar-el-certificado-ca-al-cliente)
   - 5.2 [Instalar el certificado CA en el sistema](#instalar-el-certificado-ca-en-el-sistema)
6. [Actualización de SSSD en el cliente](#actualización-de-sssd-en-el-cliente)
   - 6.1 [Nuevo fichero sssd.conf con TLS](#nuevo-fichero-sssdconf-con-tls)
   - 6.2 [Aplicar los cambios](#aplicar-los-cambios)
7. [Verificación final](#verificación-final)
   - 7.1 [Verificar que la autenticación sigue funcionando](#verificar-que-la-autenticación-sigue-funcionando)
   - 7.2 [Verificar que el cambio de contraseña funciona](#verificar-que-el-cambio-de-contraseña-funciona)
   - 7.3 [Verificar que el tráfico va cifrado](#verificar-que-el-tráfico-va-cifrado)

---

> **Convención de etiquetas usada en estos apuntes:**
>
> **SERVIDOR** — El paso se realiza en la máquina Ubuntu Server 24.04.3 LTS con `slapd` instalado (`192.168.1.10`).
>
> **CLIENTE** — El paso se realiza en la máquina cliente del alumno o profesor (`192.168.1.20`).

---

## Introducción

### ¿Por qué TLS en LDAP?

Sin TLS, toda la comunicación entre los clientes y el servidor LDAP viaja en **texto plano** por la red. Esto incluye las contraseñas de los alumnos y profesores en el momento del login, los datos del directorio y cualquier cambio de contraseña. Cualquier equipo de la red que capture el tráfico puede leer esa información sin ningún esfuerzo.

En el escenario del centro educativo, con decenas de equipos en aulas conectados a la misma red, esto supone un riesgo real. Un alumno con conocimientos básicos de redes podría capturar las credenciales de sus compañeros o incluso de los profesores usando herramientas como `tcpdump` o Wireshark.

TLS cifra todo el canal de comunicación entre cliente y servidor, haciendo que el tráfico interceptado sea ilegible. Adicionalmente, los certificados permiten que el cliente verifique que está hablando con el servidor legítimo y no con un impostor (protección contra ataques *man-in-the-middle*).

> **Recuerda:** Hasta este punto, en `sssd.conf` teníamos la línea `ldap_auth_disable_tls_never_use_in_production = true`. El propio nombre del parámetro indica que **nunca debe usarse en producción**. Configurar TLS correctamente nos permite eliminarlo.

---

### StartTLS vs LDAPS

Existen dos formas de cifrar la comunicación LDAP:

| | **StartTLS** | **LDAPS** |
|--|-------------|-----------|
| **Puerto** | 389 (el mismo que LDAP sin cifrar) | 636 (puerto dedicado) |
| **Funcionamiento** | La conexión empieza sin cifrar y negocia TLS mediante el comando `STARTTLS` | El cifrado se establece desde el primer byte de la conexión |
| **Estándar** | RFC 4513 — es el método moderno recomendado | Método antiguo, considerado obsoleto por algunos RFCs |
| **Compatibilidad** | Mejor compatibilidad con herramientas modernas | Más simple de entender conceptualmente |
| **En `sssd.conf`** | `ldap_id_use_start_tls = true` | Cambiar `ldap://` por `ldaps://` |

En estos apuntes usaremos **StartTLS**, que es el método recomendado actualmente y el que mejor se integra con `sssd`.

---

### Infraestructura de clave pública (PKI)

Para usar TLS necesitamos certificados digitales. En un entorno de producción se usaría una CA (*Certificate Authority*) pública como Let's Encrypt. Para un centro educativo con una red interna, crearemos nuestra propia **CA autofirmada** (*self-signed CA*).

La cadena de confianza funciona así:

```
CA del IES (raíz de confianza)
    └── Certificado del servidor ldap.ies.local
            └── Conexiones TLS cifradas y verificadas
```

Los clientes confiarán en el certificado del servidor porque está firmado por la CA del IES, y esa CA la instalaremos en cada cliente. Es exactamente el mismo principio que usan los navegadores web con los certificados HTTPS.

Los ficheros que generaremos son:

| Fichero | Descripción | Dónde se usa |
|---------|-------------|--------------|
| `ca.key` | Clave privada de la CA | Solo en el servidor, nunca se distribuye |
| `ca.crt` | Certificado público de la CA | Se distribuye a todos los clientes |
| `ldap.key` | Clave privada del servidor LDAP | Solo en el servidor |
| `ldap.crt` | Certificado público del servidor LDAP | Se configura en `slapd` |

> **Advertencia:** Las claves privadas (`ca.key` y `ldap.key`) nunca deben salir del servidor ni enviarse por la red. Si se comprometen, cualquiera puede suplantar al servidor o firmar certificados falsos.

---

## Generación de certificados

**SERVIDOR**

Todos los pasos de generación de certificados se realizan en el servidor LDAP. Crear un directorio de trabajo dedicado para mantener los ficheros organizados:

```bash
root@ldap:~# mkdir -p /root/tls-ldap
root@ldap:~# cd /root/tls-ldap
```

> **Nota:** El paquete `openssl` viene instalado por defecto en Ubuntu Server 24.04. Verificar que está disponible con `openssl version`.

---

### Crear la Autoridad Certificadora (CA)

La CA es la entidad raíz de confianza. Genera primero su clave privada y después su certificado autofirmado.

**Paso 1 — Generar la clave privada de la CA:**

```bash
root@ldap:~/tls-ldap# openssl genrsa -out ca.key 4096
```

| Parámetro | Descripción |
|-----------|-------------|
| `genrsa` | Genera un par de claves RSA |
| `-out ca.key` | Nombre del fichero de salida para la clave privada |
| `4096` | Longitud de la clave en bits. 4096 es el mínimo recomendado actualmente |

**Paso 2 — Generar el certificado autofirmado de la CA:**

```bash
root@ldap:~/tls-ldap# openssl req -new -x509 -days 3650 \
  -key ca.key \
  -out ca.crt \
  -subj "/C=ES/ST=Galicia/L=Ourense/O=IES Ejemplo/OU=Informatica/CN=CA IES Ejemplo"
```

| Parámetro | Descripción |
|-----------|-------------|
| `req -new -x509` | Genera un certificado autofirmado (no una solicitud de firma) |
| `-days 3650` | Validez del certificado: 10 años |
| `-key ca.key` | Clave privada con la que se firma el certificado |
| `-out ca.crt` | Fichero de salida del certificado |
| `-subj` | Datos de identificación del certificado sin modo interactivo |
| `CN=CA IES Ejemplo` | Nombre común de la CA. Aparecerá en los navegadores y herramientas |

> **Nota:** Los campos del parámetro `-subj` pueden adaptarse al centro real: `/C=ES` es el código de país (España), `/ST` es la comunidad autónoma, `/L` la localidad, `/O` la organización y `/OU` el departamento.

---

### Crear el certificado del servidor LDAP

El certificado del servidor se genera en dos pasos: primero una **solicitud de firma** (CSR) y después la firma por parte de la CA.

**Paso 1 — Generar la clave privada del servidor:**

```bash
root@ldap:~/tls-ldap# openssl genrsa -out ldap.key 4096
```

**Paso 2 — Crear la solicitud de firma del certificado (CSR):**

```bash
root@ldap:~/tls-ldap# openssl req -new \
  -key ldap.key \
  -out ldap.csr \
  -subj "/C=ES/ST=Galicia/L=Ourense/O=IES Ejemplo/OU=Informatica/CN=ldap.ies.local"
```

> **Importante:** El campo `CN` del certificado del servidor debe coincidir **exactamente** con el hostname que usarán los clientes para conectarse. En nuestro caso `ldap.ies.local`. Si los clientes usan la IP directamente (`192.168.1.10`), habría que añadir un Subject Alternative Name (SAN). En estos apuntes usamos el hostname.

**Paso 3 — Crear un fichero de extensiones para el SAN:**

Las versiones modernas de OpenSSL y las herramientas de verificación de certificados requieren que el hostname esté en el campo **Subject Alternative Name** además del CN. Crear el fichero de extensiones:

```bash
root@ldap:~/tls-ldap# cat > ldap-ext.cnf << EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = ldap.ies.local
DNS.2 = ldap
IP.1  = 192.168.1.10
EOF
```

> **Nota:** Incluir tanto el hostname (`ldap.ies.local`), el nombre corto (`ldap`) y la IP (`192.168.1.10`) en los SANs garantiza que el certificado sea válido independientemente de cómo los clientes resuelvan el servidor.

**Paso 4 — Firmar el certificado del servidor con la CA:**

```bash
root@ldap:~/tls-ldap# openssl x509 -req -days 3650 \
  -in ldap.csr \
  -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -out ldap.crt \
  -extensions v3_req \
  -extfile ldap-ext.cnf
```

| Parámetro | Descripción |
|-----------|-------------|
| `-req` | Indica que la entrada es una CSR |
| `-days 3650` | Validez del certificado del servidor: 10 años |
| `-in ldap.csr` | CSR generada en el paso anterior |
| `-CA ca.crt` | Certificado de la CA que firma |
| `-CAkey ca.key` | Clave privada de la CA |
| `-CAcreateserial` | Crea el fichero de número de serie de la CA automáticamente |
| `-out ldap.crt` | Certificado del servidor resultante |
| `-extensions v3_req -extfile ldap-ext.cnf` | Incluye los SANs definidos en el fichero de extensiones |

---

### Verificar los certificados generados

Comprobar que el certificado del servidor es válido y está firmado por nuestra CA:

```bash
root@ldap:~/tls-ldap# openssl verify -CAfile ca.crt ldap.crt
```

La salida debe ser:

```
ldap.crt: OK
```

Verificar el contenido del certificado y que los SANs están presentes:

```bash
root@ldap:~/tls-ldap# openssl x509 -in ldap.crt -noout -text | grep -A 4 "Subject Alternative Name"
```

La salida debe mostrar:

```
X509v3 Subject Alternative Name:
    DNS:ldap.ies.local, DNS:ldap, IP Address:192.168.1.10
```

Listar todos los ficheros generados:

```bash
root@ldap:~/tls-ldap# ls -lh
```

```
-rw-r--r-- 1 root root 2.0K ca.crt
-rw------- 1 root root 3.2K ca.key
-rw-r--r-- 1 root root 2.1K ldap.crt
-rw-r--r-- 1 root root  711 ldap.csr
-rw------- 1 root root 3.2K ldap.key
-rw-r--r-- 1 root root   17 ca.srl
```

> **Advertencia:** Los ficheros `.key` deben tener permisos `600` (solo lectura/escritura para root). Si tienen permisos más abiertos, `slapd` se negará a usarlos.

---

## Configuración de TLS en slapd

**SERVIDOR**

### Copiar los certificados al directorio de slapd

El directorio estándar para los certificados de `slapd` en Ubuntu es `/etc/ldap/sasl2/` o bien un subdirectorio dedicado. Usaremos `/etc/ldap/tls/` para mantenerlo organizado:

```bash
root@ldap:~# mkdir -p /etc/ldap/tls
root@ldap:~# cp /root/tls-ldap/ca.crt   /etc/ldap/tls/
root@ldap:~# cp /root/tls-ldap/ldap.crt /etc/ldap/tls/
root@ldap:~# cp /root/tls-ldap/ldap.key /etc/ldap/tls/
```

Asignar los permisos correctos. La clave privada solo debe ser legible por `root` y el usuario `openldap` (que es el usuario con el que corre `slapd`):

```bash
root@ldap:~# chown -R openldap:openldap /etc/ldap/tls/
root@ldap:~# chmod 755 /etc/ldap/tls/
root@ldap:~# chmod 644 /etc/ldap/tls/ca.crt
root@ldap:~# chmod 644 /etc/ldap/tls/ldap.crt
root@ldap:~# chmod 600 /etc/ldap/tls/ldap.key
```

Verificar los permisos:

```bash
root@ldap:~# ls -lh /etc/ldap/tls/
```

```
-rw-r--r-- 1 openldap openldap 2.0K ca.crt
-rw-r--r-- 1 openldap openldap 2.1K ldap.crt
-rw------- 1 openldap openldap 3.2K ldap.key
```

> **Importante:** Si la clave privada `ldap.key` tiene permisos más permisivos que `600`, `slapd` rechazará usarla y el servicio no arrancará.

---

### Aplicar la configuración TLS mediante LDIF

En Ubuntu 24.04, la configuración de `slapd` se gestiona de forma dinámica a través del backend `cn=config`. **No se editan ficheros de texto directamente**: los cambios se aplican mediante `ldapmodify` autenticado con el socket Unix local.

Crear el fichero LDIF con la configuración TLS:

```bash
root@ldap:~# nano /root/ldif_ies/tls-config.ldif
```

Contenido del fichero `/root/ldif_ies/tls-config.ldif`:

```ldif
# Configuración TLS para slapd
# Se aplica sobre la base de datos de configuración cn=config
dn: cn=config
changetype: modify
# Ruta al certificado de la CA (para verificar certificados de clientes)
replace: olcTLSCACertificateFile
olcTLSCACertificateFile: /etc/ldap/tls/ca.crt
-
# Ruta al certificado público del servidor
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ldap/tls/ldap.crt
-
# Ruta a la clave privada del servidor
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ldap/tls/ldap.key
-
# Nivel de verificación del certificado del cliente:
# never  → no se pide certificado al cliente (lo más habitual)
# allow  → se acepta si se presenta pero no es obligatorio
# demand → se exige certificado al cliente
replace: olcTLSVerifyClient
olcTLSVerifyClient: never
```

Aplicar la configuración usando el socket Unix local (no requiere contraseña LDAP, se autentica como `root`):

```bash
root@ldap:~# ldapmodify -Y EXTERNAL -H ldapi:/// -f /root/ldif_ies/tls-config.ldif
```

La salida esperada es:

```
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "cn=config"
```

> **Nota:** `-Y EXTERNAL -H ldapi:///` se autentica mediante el socket Unix local como `root` del sistema operativo. Solo funciona ejecutándolo directamente en el servidor como `root`. Esta es la forma segura de modificar la configuración de `slapd` sin exponer credenciales LDAP.

---

### Verificar la configuración aplicada

Comprobar que los parámetros TLS se han guardado correctamente en `cn=config`:

```bash
root@ldap:~# ldapsearch -Y EXTERNAL -H ldapi:/// \
  -b "cn=config" \
  "(objectClass=olcGlobal)" \
  olcTLSCACertificateFile olcTLSCertificateFile olcTLSCertificateKeyFile olcTLSVerifyClient
```

La salida debe mostrar las cuatro rutas configuradas:

```
dn: cn=config
olcTLSCACertificateFile: /etc/ldap/tls/ca.crt
olcTLSCertificateFile: /etc/ldap/tls/ldap.crt
olcTLSCertificateKeyFile: /etc/ldap/tls/ldap.key
olcTLSVerifyClient: never
```

---

### Reiniciar y comprobar el servicio

Reiniciar `slapd` para que aplique la nueva configuración TLS:

```bash
root@ldap:~# systemctl restart slapd
root@ldap:~# systemctl status slapd
```

El servicio debe mostrar `active (running)`. Si aparece `failed`, revisar los logs para identificar el problema:

```bash
root@ldap:~# journalctl -u slapd --no-pager | tail -30
```

Los errores más comunes en este punto son permisos incorrectos en los ficheros de certificados o rutas mal escritas en el LDIF.

---

## Verificación de TLS desde el servidor

**SERVIDOR**

Probar que StartTLS funciona correctamente desde el propio servidor usando `openssl s_client`:

```bash
root@ldap:~# openssl s_client -connect ldap.ies.local:389 -starttls ldap -CAfile /etc/ldap/tls/ca.crt
```

Si TLS está correctamente configurado, la salida mostrará la cadena de certificados y finalizará con:

```
Verify return code: 0 (ok)
```

También verificar con `ldapsearch` usando StartTLS (el parámetro `-Z` activa StartTLS):

```bash
root@ldap:~# ldapsearch -x -H ldap://ldap.ies.local -Z \
  -b "dc=ies,dc=local" \
  "(objectClass=organizationalUnit)" dn
```

| Parámetro | Descripción |
|-----------|-------------|
| `-Z` | Activa StartTLS. Usar `-ZZ` para forzarlo (falla si TLS no está disponible) |

La búsqueda debe devolver las OUs del directorio viajando ahora de forma cifrada.

> **Nota:** Para que `ldapsearch` confíe en el certificado autofirmado hay que indicarle la CA. Editar `/etc/ldap/ldap.conf` en el servidor y añadir: `TLS_CACERT /etc/ldap/tls/ca.crt`

```bash
root@ldap:~# echo "TLS_CACERT /etc/ldap/tls/ca.crt" >> /etc/ldap/ldap.conf
```

---

## Distribución del certificado CA a los clientes

**CLIENTE**

Para que los clientes confíen en el certificado del servidor LDAP, necesitan tener instalado el certificado de nuestra CA. Sin este paso, SSSD rechazará la conexión TLS porque no podrá verificar la autenticidad del servidor.

---

### Copiar el certificado CA al cliente

Copiar el fichero `ca.crt` desde el servidor al cliente. Hay varias formas de hacerlo. La más sencilla en un entorno de aula es usar `scp`:

```bash
root@ldap:~# scp /etc/ldap/tls/ca.crt root@192.168.1.20:/tmp/ies-ca.crt
```

O desde el propio cliente:

```bash
root@cliente:~# scp root@192.168.1.10:/etc/ldap/tls/ca.crt /tmp/ies-ca.crt
```

> **Nota:** Solo se copia el certificado público de la CA (`ca.crt`). La clave privada (`ca.key`) y el certificado del servidor (`ldap.crt`) **nunca** se distribuyen a los clientes.

---

### Instalar el certificado CA en el sistema

Ubuntu gestiona los certificados de confianza del sistema en `/usr/local/share/ca-certificates/`. Cualquier fichero `.crt` colocado ahí e importado con `update-ca-certificates` pasará a ser de confianza para todas las aplicaciones del sistema.

```bash
root@cliente:~# cp /tmp/ies-ca.crt /usr/local/share/ca-certificates/ies-ca.crt
root@cliente:~# update-ca-certificates
```

La salida debe indicar que se ha añadido un certificado:

```
Updating certificates in /etc/ssl/certs...
1 added, 0 removed; done.
Running hooks in /etc/ca-certificates/update.d...
done.
```

Verificar que el certificado está instalado correctamente:

```bash
root@cliente:~# openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt /tmp/ies-ca.crt
```

La salida debe ser:

```
/tmp/ies-ca.crt: OK
```

---

## Actualización de SSSD en el cliente

**CLIENTE**

### Nuevo fichero sssd.conf con TLS

Con el certificado CA instalado, ahora se puede configurar SSSD para usar StartTLS de forma segura. Editar el fichero de configuración:

```bash
root@cliente:~# nano /etc/sssd/sssd.conf
```

El fichero completo debe quedar así, eliminando los parámetros inseguros que teníamos antes y sustituyéndolos por la configuración TLS correcta:

```ini
[sssd]
domains = ies.local
services = nss, pam
config_file_version = 2

[domain/ies.local]
id_provider = ldap
auth_provider = ldap

# --- Conexión al servidor ---
ldap_uri = ldap://192.168.1.10
ldap_search_base = dc=ies,dc=local
ldap_schema = rfc2307

# --- TLS (StartTLS) ---
# Activar StartTLS para cifrar toda la comunicación
ldap_id_use_start_tls = true
# Ruta al certificado CA instalado en el sistema
ldap_tls_cacert = /etc/ssl/certs/ca-certificates.crt
# Exigir que el certificado del servidor sea válido
ldap_tls_reqcert = demand

# --- Búsqueda de usuarios ---
ldap_user_search_base = ou=usuarios,dc=ies,dc=local
ldap_user_name = uid

# --- Búsqueda de grupos ---
ldap_group_search_base = ou=grupos,dc=ies,dc=local

# --- Caché y comportamiento offline ---
cache_credentials = true
entry_cache_timeout = 300

# --- Directorio home ---
override_homedir = /home/%u

# --- Enumeración ---
enumerate = true

# --- Cambio de contraseña por el usuario ---
chpass_provider = ldap
ldap_chpass_uri = ldap://192.168.1.10
ldap_chpass_update_last_change = true
# ldap_auth_disable_tls_never_use_in_production = true  ← ya no es necesario, TLS está activo
```

> **Importante:** Al activar `ldap_tls_reqcert = demand`, SSSD verificará que el certificado del servidor está firmado por una CA de confianza y que el CN o SAN coincide con el hostname al que se conecta. Si el certificado no es válido, la conexión se rechaza. Esto es exactamente lo que queremos: protección contra suplantación del servidor.

---

### Aplicar los cambios

Verificar que los permisos del fichero siguen siendo correctos:

```bash
root@cliente:~# chmod 600 /etc/sssd/sssd.conf
root@cliente:~# chown root:root /etc/sssd/sssd.conf
```

Limpiar la caché y reiniciar SSSD:

```bash
root@cliente:~# sss_cache -E
root@cliente:~# systemctl restart sssd
root@cliente:~# systemctl status sssd
```

El servicio debe mostrar `active (running)` sin errores TLS en los logs.

Verificar el estado del dominio:

```bash
root@cliente:~# sssctl domain-status ies.local
```

Debe mostrar:

```
Online status: Online
```

---

## Verificación final

### Verificar que la autenticación sigue funcionando

**CLIENTE**

```bash
root@cliente:~# getent passwd a.garcia
```

Salida esperada:

```
a.garcia:x:10001:10000:Ana Garcia Lopez:/home/a.garcia:/bin/bash
```

```bash
root@cliente:~# getent group SMR1
```

Salida esperada:

```
SMR1:x:10000:a.garcia,c.lopez
```

Probar login completo:

```bash
root@cliente:~# sudo su - a.garcia
```

---

### Verificar que el cambio de contraseña funciona

```bash
a.garcia@ubuntu:~$ passwd
Contraseña actual:
Nueva contraseña UNIX:
Repita la nueva contraseña UNIX:
passwd: contraseña actualizada correctamente
```

---

### Verificar que el tráfico va cifrado

Desde el servidor, capturar el tráfico LDAP en la interfaz de red y comprobar que las contraseñas ya no son visibles en texto plano. Con `tcpdump` se puede verificar que el tráfico en el puerto 389 está cifrado:

```bash
root@ldap:~# tcpdump -i enp0s3 -A port 389 2>/dev/null | grep -i "userpassword\|password\|bind"
```

Si TLS está correctamente configurado, este comando no mostrará contraseñas en texto plano aunque se estén produciendo logins en ese momento. El tráfico aparecerá como datos binarios ilegibles.

> **Nota:** Para una verificación más visual, se puede usar Wireshark en una máquina de la red. Sin TLS se verían los paquetes LDAP con el atributo `userPassword` legible. Con TLS activo, solo se verán registros TLS cifrados.
