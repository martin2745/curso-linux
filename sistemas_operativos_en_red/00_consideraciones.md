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
