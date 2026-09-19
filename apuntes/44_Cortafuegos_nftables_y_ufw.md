# Cortafuegos: nftables y ufw

## Índice

1. [ufw: el cortafuegos sencillo](#1-ufw-el-cortafuegos-sencillo)
   1. [La política por defecto](#11-la-política-por-defecto)
   2. [Abrir los servicios necesarios](#12-abrir-los-servicios-necesarios)
   3. [Activar y comprobar](#13-activar-y-comprobar)
2. [nftables: el cortafuegos nativo](#2-nftables-el-cortafuegos-nativo)
3. [Un conjunto de reglas básico para un servidor](#3-un-conjunto-de-reglas-básico-para-un-servidor)
4. [La regla de oro: no cerrarse el acceso a uno mismo](#4-la-regla-de-oro-no-cerrarse-el-acceso-a-uno-mismo)
5. [¿ufw o nftables?](#5-ufw-o-nftables)

---

## 1. ufw: el cortafuegos sencillo

`ufw` (*Uncomplicated Firewall*) es un frontend pensado para gestionar el cortafuegos con órdenes fáciles de recordar, sin tener que aprender la sintaxis interna. Por debajo traduce cada orden a reglas de `nftables`. Es la forma recomendable de empezar y suficiente para la mayoría de los servidores sencillos.

Se instala y se consulta su estado así:

```bash
root@debian:~# apt install ufw
root@debian:~# ufw status
Estado: inactivo
```

### 1.1 La política por defecto

Lo primero es fijar la política general: denegar todo lo que entra y permitir todo lo que sale. Esta es la base de un cortafuegos bien planteado.

```bash
root@debian:~# ufw default deny incoming
root@debian:~# ufw default allow outgoing
```

### 1.2 Abrir los servicios necesarios

Con la puerta cerrada por defecto, se abre solo lo imprescindible. Los servicios se pueden indicar por su número de puerto o por su nombre:

```bash
root@debian:~# ufw allow 22/tcp          # SSH por numero de puerto
root@debian:~# ufw allow ssh             # equivalente, por nombre de servicio
root@debian:~# ufw allow 80/tcp          # HTTP
root@debian:~# ufw allow 443/tcp         # HTTPS
```

| Orden | Efecto |
|---|---|
| `ufw allow PUERTO` | Permite el tráfico entrante a ese puerto. |
| `ufw deny PUERTO` | Deniega expresamente ese puerto. |
| `ufw allow from IP` | Permite todo el tráfico procedente de una IP concreta. |
| `ufw allow from IP to any port PUERTO` | Permite una IP concreta solo hacia un puerto. |
| `ufw limit ssh` | Permite SSH pero limita la frecuencia de conexiones, como defensa ante ataques de fuerza bruta. |
| `ufw delete allow 80/tcp` | Elimina una regla creada previamente. |

### 1.3 Activar y comprobar

Una vez definidas las reglas, se activa el cortafuegos y se revisa el resultado con detalle:

```bash
root@debian:~# ufw enable
root@debian:~# ufw status verbose
Estado: activo
Registro: on (low)
Por defecto: deny (entrante), allow (saliente)

Hasta                       Acción      Desde
-----                       ------      -----
22/tcp                      ALLOW IN    Anywhere
80/tcp                      ALLOW IN    Anywhere
443/tcp                     ALLOW IN    Anywhere
```

> **Advertencia:** Si se está administrando el servidor **por SSH**, hay que permitir el puerto 22 **antes** de activar el cortafuegos con `ufw enable`. Si se activa la política `deny incoming` sin haber abierto antes el SSH, la propia conexión con la que se está trabajando se corta de inmediato y se pierde el acceso a la máquina. Este descuido es la forma más habitual de quedarse fuera de un servidor remoto, y en el apartado 4 se explica cómo protegerse de él.

> **Recuerda:** `ufw limit ssh` es una defensa muy recomendable en cualquier servidor accesible desde internet. Bloquea temporalmente una dirección que intente conectarse más de seis veces en treinta segundos, lo que frena en seco los ataques automatizados de fuerza bruta contra SSH sin molestar a un usuario legítimo.

---

## 2. nftables: el cortafuegos nativo

`nftables` es la herramienta con la que el núcleo gestiona directamente el cortafuegos, y es lo que `ufw` utiliza por debajo. Conviene conocerla porque ofrece un control total y porque es lo que aparece en la documentación y en los sistemas donde no hay `ufw` instalado. Su comando es `nft`.

Antes de escribir reglas hay que entender su estructura, que se organiza en tres niveles:

| Nivel | Qué es |
|---|---|
| **Tabla** (*table*) | El contenedor de más alto nivel. Se asocia a una **familia** de protocolos: `inet` (IPv4 e IPv6 a la vez), `ip`, `ip6`, etc. |
| **Cadena** (*chain*) | Dentro de una tabla, agrupa reglas y se engancha a un momento del recorrido del paquete: `input` (tráfico dirigido a la máquina), `output` (tráfico que genera la máquina) y `forward` (tráfico que la atraviesa hacia otra red). |
| **Regla** (*rule*) | La condición concreta y la acción: por ejemplo, "si el puerto de destino es el 22, acepta". |

El estado completo del cortafuegos se consulta en cualquier momento con:

```bash
root@debian:~# nft list ruleset
```

---

## 3. Un conjunto de reglas básico para un servidor

Lo habitual no es teclear las reglas una a una, sino escribirlas en el fichero de configuración `/etc/nftables.conf`, que el sistema carga al arrancar. Un conjunto de reglas mínimo y seguro para un servidor web con acceso por SSH sería este:

```bash
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        # Permitir el trafico de la interfaz de bucle local
        iif "lo" accept

        # Permitir las respuestas a conexiones ya establecidas
        ct state established,related accept

        # Permitir SSH, HTTP y HTTPS entrantes
        tcp dport 22 accept
        tcp dport { 80, 443 } accept

        # Permitir ping
        ip protocol icmp accept
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
```

Conviene detenerse en las líneas que hacen el trabajo importante, porque son el patrón que se repite en cualquier configuración:

| Línea | Qué hace y por qué |
|---|---|
| `policy drop;` | La política por defecto de la cadena: todo lo que no coincida con ninguna regla se **descarta**. Es la base del "cerrar todo por defecto". |
| `iif "lo" accept` | Permite el tráfico de la interfaz de bucle local (`lo`). Muchos servicios del propio sistema se comunican entre sí por ahí, así que bloquearla rompería cosas. |
| `ct state established,related accept` | Permite las **respuestas** al tráfico que la propia máquina inició. Sin esta regla, se podría salir a navegar pero las respuestas de vuelta se bloquearían. Es la regla que hace que un cortafuegos sea usable. |
| `tcp dport 22 accept` | Abre el puerto de destino (*destination port*) 22, el de SSH. |
| `tcp dport { 80, 443 } accept` | Abre varios puertos a la vez usando un conjunto entre llaves. |

Para aplicar el fichero y hacer que se cargue en cada arranque:

```bash
root@debian:~# nft -f /etc/nftables.conf     # carga las reglas ahora
root@debian:~# systemctl enable nftables     # las carga en cada arranque
```

> **Importante:** El orden de las reglas dentro de una cadena **importa**, porque `nftables` las evalúa de arriba abajo y se detiene en la primera que coincide. Por eso las reglas de aceptación (`accept`) van antes, y la política `drop` actúa al final sobre todo lo que no encajó en ninguna. Colocar una regla permisiva después de un descarte general no tendría ningún efecto.

---

## 4. La regla de oro: no cerrarse el acceso a uno mismo

El error más grave y más frecuente al configurar un cortafuegos es aplicar una política de denegación por defecto en un servidor remoto **sin haber permitido antes el puerto por el que se está administrando**, normalmente el 22 de SSH. En cuanto la regla entra en vigor, la conexión actual se corta, y como el SSH ya no está permitido, tampoco se puede volver a entrar. La máquina queda inaccesible hasta que alguien acuda físicamente a ella o desde la consola del proveedor.

Hay varias formas de protegerse de este desastre:

- **Permitir el SSH lo primero.** Antes de cualquier `policy drop` o `ufw enable`, la regla que abre el puerto 22 debe estar ya puesta.
- **Probar sin cerrar la sesión.** Tras aplicar las reglas, se abre una **segunda** conexión SSH desde otra terminal para comprobar que sigue funcionando, **sin cerrar la primera**. Si la segunda entra, la configuración es correcta; si algo falla, la primera sesión sigue abierta para deshacer el cambio.
- **Usar una red de seguridad temporal.** El comando `nft list ruleset` guardado en un fichero antes de tocar nada permite restaurar el estado anterior. En cambios delicados sobre servidores remotos, algunos administradores programan incluso un `at` (documento 35) que vuelva a abrir el SSH pasados unos minutos, por si se equivocan.

> **Advertencia:** Esta precaución no es teórica. Quedarse fuera de un servidor de producción por una regla de cortafuegos mal aplicada es uno de los incidentes más comunes en administración de sistemas, y casi siempre obliga a recurrir al acceso físico o a la consola de emergencia del proveedor. La costumbre de mantener una segunda sesión abierta mientras se prueban reglas nuevas evita el problema por completo.

---

## 5. ¿ufw o nftables?

Las dos herramientas gestionan el mismo cortafuegos del núcleo, así que no se trata de cuál es mejor, sino de cuál conviene según el caso:

| | `ufw` | `nftables` |
|---|---|---|
| Facilidad | Muy alta, órdenes sencillas. | Requiere entender tablas, cadenas y reglas. |
| Control | Suficiente para casos habituales. | Total y granular. |
| Uso recomendado | Servidores sencillos, primeros pasos. | Configuraciones complejas, enrutamiento, NAT. |

> **Recuerda:** No deben usarse las dos a la vez para gestionar las mismas reglas, porque `ufw` escribe su propia configuración de `nftables` y editar ambas por separado lleva a conflictos difíciles de depurar. Lo sensato es elegir una: `ufw` mientras las necesidades sean sencillas, y pasar a gestionar `nftables` directamente cuando el escenario lo requiera.

> **Nota:** La herramienta antigua `iptables` todavía puede aparecer en documentación y en sistemas heredados. En Debian actual, lo que se ejecuta al invocar `iptables` es en realidad una capa de compatibilidad (`iptables-nft`) que traduce las órdenes a `nftables`. Conviene saber que existe, pero para configuraciones nuevas la recomendación es usar directamente `nftables` o `ufw`.
