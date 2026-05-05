# Consideraciones

## Índice

1. [Vías de trabajo futuro](#vías-de-trabajo-futuro)
2. [Conceptos técnicos a tratar en este manual](#conceptos-técnicos-a-tratar-en-este-manual)
   - [1. ¿Qué es Samba y Samba4?](#1-qué-es-samba-y-samba4)
   - [2. El Controlador de Dominio (Domain Controller - DC)](#2-el-controlador-de-dominio-domain-controller---dc)
   - [3. LDAP y Kerberos: Los pilares centrales](#3-ldap-y-kerberos-los-pilares-centrales)
   - [4. DNS y DHCP en el escenario](#4-dns-y-dhcp-en-el-escenario)
   - [¿Por qué el Ubuntu Server centraliza estas funciones?](#por-qué-el-ubuntu-server-centraliza-estas-funciones)
   - [Resumen del flujo en el escenario](#resumen-del-flujo-en-el-escenario)

---

A continuación realizaremos el proceso de configuración de un servidor `Samba4` y dos máquinas cliente (Windows, Linux). El escenario final una vez concluido el manual será el siguiente.

```bash
INTERNET (Nube)                             TU RED PRIVADA (LAN)
      (Google, Usuarios)                           (192.168.100.0/24)
            |
            | Cable ISP
            v                                  Subred 192.168.100.0/25
+-----------------------------+             +-----------------------------+
|      UBUNTU SERVER          |             |      UBUNTU DESKTOP         |
|(SAMBA4, DHCP, DNS, KERBEROS)|             |     (Servidor Web)          |
|                             |enp0s8 (.1)  | IP: 192.168.100.10          |
|[IP PÚBLICA: 203.0.113.1]    |<------------| Ej. puerto Origen: 20800    |
|[IP PRIVADA: 192.168.100.1]  |    (1)      +-----------------------------+
|[IP PRIVADA: 192.168.100.129]|
| TABLA DE CONEXIONES (NAT)   |
| +-----------------------+   |
| | IN (Priv)  | OUT (Pub)|   |
| |------------|----------|   |
| | .10:20800  | .1:20800 |   |                Subred 192.168.100.128/25
| | .140:10500 | .1:10500 |   |enp0s9 (.129)+-----------------------------+
| +-----------------------+   |<------------|        WINDOWS 10           |
|                             |    (2)      |       (Navegando)           |
|      Reglas NFTABLES        |             | IP: 192.168.100.140         |
|     (SNAT & DNAT)           |             | Ej. puerto Origen: 10500    |
+-----------------------------+             +-----------------------------+
            ^
            | (3) Tráfico DNAT (Entrada)
            |
    Usuario Externo
    Pide ver un recurso (por ejemplo el servidor web en la .10)
```

---

## Vías de trabajo futuro

- Sería de interés el uso de `Ansible` para la instalación de software y realización de acciones administrativas desde el `Samba AD-DC`. El uso de herramientas de automatización reduce errores humanos y estandariza despliegues en múltiples clientes simultáneamente.
- Sería interesante el uso de `Docker` y contenedores en nuestros clientes para el despliegue rápido de servicios o pruebas de configuración sin afectar el sistema base.

> **Nota:** Este manual está pendiente de revisión y será actualizado con el tiempo para incluir mejores prácticas de seguridad y escalabilidad.

---

## Conceptos técnicos a tratar en este manual

### 1. ¿Qué es Samba y Samba4?

**Samba** es una implementación de código abierto del protocolo `SMB` (Server Message Block). Este es el "lenguaje" estándar que utilizan los ordenadores Windows para compartir archivos, impresoras y comunicarse en red de manera transparente.

**Samba4** representa un hito fundamental, ya que permite que un servidor Linux actúe como un **Controlador de Dominio de Active Directory (AD DC)**. Desde la perspectiva de un cliente Windows, el servidor `Ubuntu` resulta indistinguible de un servidor `Windows Server` real, lo que permite a las organizaciones usar infraestructura de código abierto para gestionar redes corporativas complejas sin incurrir en costes de licenciamiento.

### 2. El Controlador de Dominio (Domain Controller - DC)

"Promocionar" un servidor a Controlador de Dominio significa que este se convierte en la **autoridad central** de la red. Esto es clave en entornos empresariales.

- **Gestión Centralizada:** Los usuarios no se crean localmente en cada PC, sino una sola vez en el `DC`, permitiendo el inicio de sesión en cualquier máquina vinculada al dominio. Esto simplifica drásticamente la gestión del ciclo de vida de los usuarios (altas, bajas, modificaciones de contraseñas).
- **Seguridad y Políticas:** El `DC` gestiona la relación de "confianza" entre todos los dispositivos que integran la red y permite aplicar Políticas de Grupo (GPOs) para forzar configuraciones de seguridad de forma automatizada en todos los clientes.

### 3. LDAP y Kerberos: Los pilares centrales

- **LDAP (Lightweight Directory Access Protocol):** Se define como la **base de datos** jerárquica del sistema. Almacena el árbol de directorios, incluyendo la identidad de los usuarios, sus grupos de pertenencia, equipos unidos al dominio y sus atributos (teléfono, correo electrónico, permisos, etc.). Las consultas a `LDAP` son extremadamente rápidas, ideal para validaciones de lectura.
- **Kerberos:** Actúa como el **guardia de seguridad**. Gestiona la autenticación mediante un sistema de "tickets". Para evitar el envío constante de contraseñas por la red (lo que sería un fallo crítico de seguridad), `Kerberos` emite tickets cifrados. Tras el inicio de sesión exitoso, el usuario obtiene un Ticket Granting Ticket (`TGT`) o "ticket maestro" que permite el acceso a recursos (archivos o impresoras) sin reintroducir credenciales, proceso conocido como **Single Sign-On (SSO)**.

### 4. DNS y DHCP en el escenario

En el escenario planteado, el servidor `Ubuntu Server` es el encargado de ejecutar ambos roles, los cuales son requisitos indispensables para el correcto funcionamiento de `Active Directory`.

#### DNS (Domain Name System)

- **Definición:** Traduce nombres de host (como `servidor.lan`) en direcciones IP (como `192.168.100.1`).
- **Función en Active Directory:** El `DNS` actúa como el "pegamento" del sistema. `Samba4` utiliza registros `DNS` específicos (registros `SRV`) para que los clientes localicen automáticamente los servicios del Controlador de Dominio y de `Kerberos`. Si el `DNS` no es funcional o está mal configurado, el cliente Windows no podrá localizar el dominio para iniciar sesión, resultando en un entorno inoperativo.
- **Implementación:** El `Ubuntu Server` ejecuta la zona `DNS` interna para la red privada, resolviendo peticiones tanto locales como externas.

#### DHCP (Dynamic Host Configuration Protocol)

- **Definición:** Es el servicio que asigna automáticamente parámetros de red (dirección IP, máscara de subred y puerta de enlace) a los dispositivos al conectarse.
- **Utilidad:** Evita conflictos de IP y elimina la necesidad de configurar manualmente cada cliente de la red, facilitando la escalabilidad del entorno.
- **Implementación:** El `Ubuntu Server` gestiona las peticiones de las máquinas `Windows 10` o `Ubuntu Desktop`, asignando una IP (como `.10` o `.140`) e informándoles automáticamente de la identidad del servidor `DNS` (`192.168.100.1`) y la puerta de enlace predeterminada.

### ¿Por qué el Ubuntu Server centraliza estas funciones?

En el esquema diseñado, el `Ubuntu Server` actúa como **Gateway/Router**, situándose entre Internet y la red de área local (LAN).

1. **Como DHCP:** Debe controlar la asignación de direcciones para asegurar que cada dispositivo apunte a la puerta de enlace correcta (el propio servidor) para alcanzar el exterior.
2. **Como DNS:** Al ser el Controlador de Dominio, es imperativo que gestione los registros internos para que los clientes Windows y Linux puedan localizarse y autenticarse correctamente, y a la vez reenviar (forward) las peticiones no resueltas a Internet.

### Resumen del flujo en el escenario

1. **DHCP:** El cliente `Windows 10` solicita una dirección IP y el servidor Ubuntu le asigna la `192.168.100.140`.
2. **DNS:** El cliente consulta por la ubicación del Controlador de Dominio y el servidor Ubuntu responde con su propia dirección, la `192.168.100.1`.
3. **Kerberos/LDAP:** El usuario introduce sus credenciales; el servidor Ubuntu las valida y concede el acceso mediante tickets.
4. **NAT/NFTABLES:** Cuando se requiere acceso a recursos externos (como navegar a Google), el servidor Ubuntu traduce la IP privada a la IP pública (SNAT/Masquerade), permitiendo la navegación transparente del cliente.
