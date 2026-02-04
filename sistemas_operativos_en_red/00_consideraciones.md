# Consideraciones

A continuación realizaremos el proceso de configuración de un servidor Samba4 y dos máquinas cliente (windows, linux). El escenario final una vez concluido el manual será el siguiente.

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

## Vías de trabajo futuro

- Sería de interés el uso de Ansible para la instalación de software y realización de acciones administrativas desde el Samba AD-DC.
- Sería interesante el uso de docker y contenedores en nuestros clientes.

_*Nota*_: Este manual está pendiente de revisión y será actualizado con el tiempo.

## Conceptos técnicos a tratar en este manual

### 1. ¿Qué es Samba y Samba4?

**Samba** es una implementación de código abierto del protocolo **SMB (Server Message Block)**. Este es el "lenguaje" que utilizan los ordenadores Windows para compartir archivos e impresoras.

**Samba4** representa un hito fundamental, ya que permite que un servidor Linux actúe como un **Controlador de Dominio de Active Directory (AD DC)**. Desde la perspectiva de un cliente Windows, el servidor Ubuntu resulta indistinguible de un servidor Windows Server real.

### 2. El Controlador de Dominio (Domain Controller - DC)

"Promocionar" un servidor a Controlador de Dominio significa que este se convierte en la **autoridad central** de la red.

- **Gestión Centralizada:** Los usuarios no se crean localmente en cada PC, sino una sola vez en el DC, permitiendo el inicio de sesión en cualquier máquina vinculada al dominio.
- **Seguridad:** El DC gestiona la relación de "confianza" entre todos los dispositivos que integran la red.

### 3. LDAP y Kerberos: Los pilares centrales

- **LDAP (Lightweight Directory Access Protocol):** Se define como la **base de datos** del sistema. Almacena el árbol de directorios, incluyendo la identidad de los usuarios, sus grupos de pertenencia y sus atributos (teléfono, correo electrónico, etc.).
- **Kerberos:** Actúa como el **guardia de seguridad**. Gestiona la autenticación mediante un sistema de "tickets". Para evitar el envío constante de contraseñas por la red, Kerberos emite tickets cifrados. Tras el inicio de sesión, el usuario obtiene un "ticket maestro" que permite el acceso a recursos (archivos o impresoras) sin reintroducir credenciales, proceso conocido como **Single Sign-On**.

### 4. DNS y DHCP en el escenario

En el escenario planteado, el **Ubuntu Server** es el encargado de ejecutar ambos roles.

#### **DNS (Domain Name System)**

- **Definición:** Traduce nombres de host (como `servidor.lan`) en direcciones IP (como `192.168.100.1`).
- **Función en Active Directory:** El DNS actúa como el "pegamento" del sistema. Samba4 utiliza registros DNS específicos (registros SRV) para que los clientes localicen los servicios del Controlador de Dominio y de Kerberos. Si el DNS no es funcional, el cliente Windows no podrá localizar el dominio para iniciar sesión.
- **Implementación:** El **Ubuntu Server** ejecuta la zona DNS interna para la red privada.

#### **DHCP (Dynamic Host Configuration Protocol)**

- **Definición:** Es el servicio que asigna automáticamente parámetros de red (dirección IP, máscara de subred y puerta de enlace) a los dispositivos al conectarse.
- **Utilidad:** Evita conflictos de IP y elimina la necesidad de configurar manualmente cada cliente de la red.
- **Implementación:** El **Ubuntu Server** gestiona las peticiones de las máquinas "Windows 10" o "Ubuntu Desktop", asignando una IP (como `.10` o `.140`) e informándoles de la identidad del servidor DNS y la puerta de enlace.

### ¿Por qué el Ubuntu Server centraliza estas funciones?

En el esquema diseñado, el **Ubuntu Server** actúa como **Gateway/Router**, situándose entre Internet y la red de área local (LAN).

1.  **Como DHCP:** Debe controlar la asignación de direcciones para asegurar que cada dispositivo apunte a la puerta de enlace correcta (el propio servidor) para alcanzar el exterior.
2.  **Como DNS:** Al ser el Controlador de Dominio, es imperativo que gestione los registros internos para que los clientes Windows y Linux puedan localizarse y autenticarse correctamente.

### Resumen del flujo en el escenario

1.  **DHCP:** El cliente Windows 10 solicita una dirección IP y el servidor Ubuntu le asigna la `192.168.100.140`.
2.  **DNS:** El cliente consulta por la ubicación del Controlador de Dominio y el servidor Ubuntu responde con su propia dirección, la `192.168.100.1`.
3.  **Kerberos/LDAP:** El usuario introduce sus credenciales; el servidor Ubuntu las valida y concede el acceso.
4.  **NAT/NFTABLES:** Cuando se requiere acceso a recursos externos (como Google), el servidor Ubuntu traduce la IP privada a la IP pública, permitiendo la navegación.
