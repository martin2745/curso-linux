# Comandos de identidad de usuario: who, whoami, id y groups

## Índice

1. [Comando who](#comando-who)
2. [Comando whoami](#comando-whoami)
3. [Comando id y sus variantes](#comando-id-y-sus-variantes)
4. [Comando groups](#comando-groups)

---

## Comando who

El comando `who` muestra información en tiempo real sobre los usuarios que están actualmente conectados al sistema (sesiones activas). Es una herramienta rápida y esencial para control de sesiones concurrentes y auditoría de accesos.

```bash
usuario@debian:~$ who
nuevo    pts/0        2024-04-25 18:46 (10.0.2.2)
usuario  pts/1        2024-04-25 17:44 (10.0.2.2)
```

**Explicación:** En este caso, la salida muestra dos usuarios conectados: `nuevo` y `usuario`. También informa de la terminal virtual desde la que operan (`pts/0` y `pts/1` respectivamente), la fecha y hora de conexión y la dirección IP desde la que se conectaron (`10.0.2.2`).

---

## Comando whoami

El comando `whoami` imprime el nombre del usuario efectivo que invoca el comando.

```bash
usuario@debian:~$ whoami
usuario
```

**Explicación:** Simplemente devuelve el nombre de la cuenta actual en formato texto plano, que en este caso es `usuario`. En la administración de sistemas y creación de *scripts* (*bash scripting*), se utiliza frecuentemente para hacer comprobaciones de seguridad condicionales, por ejemplo, averiguando si el script está siendo ejecutado como administrador antes de proseguir con operaciones delicadas.

---

## Comando id y sus variantes

El comando `id` imprime por pantalla la identidad completa de usuario y grupo del usuario actual, proporcionando información pormenorizada sobre el identificador numérico de usuario (UID) y del grupo (GID), así como la lista completa de todos los grupos secundarios a los que pertenece.

```bash
usuario@debian:~$ id
uid=1000(usuario) gid=1000(usuario) grupos=1000(usuario),24(cdrom),25(floppy),27(sudo),29(audio),30(dip),44(video),46(plugdev),100(users),106(netdev),112(bluetooth),114(lpadmin),117(scanner)
```

**Explicación:** Muestra el UID y GID del usuario `usuario` como `1000`. En sistemas Linux como Debian, los usuarios convencionales humanos inician típicamente su numeración de UID en el `1000`. A continuación, se detalla la lista de identificadores numéricos y nombres de los grupos asociados a dicha cuenta.

### Obtener el identificador numérico de usuario (UID)

Podemos aislar partes de esta información utilizando parámetros. El comando `id -u` devuelve exclusivamente el número de UID.

```bash
usuario@debian:~$ id -u
1000
```

Si le pasamos como parámetro adicional el nombre de otro usuario, podemos consultar su identificador sin necesidad de iniciar sesión con esa cuenta. Por ejemplo, consultando al administrador supremo `root`:

```bash
usuario@debian:~$ id -u root
0
```

**Explicación:** El número `0` siempre es asignado de forma inmutable a la cuenta `root` en cualquier sistema basado en Linux.

### Obtener el identificador numérico de grupo principal (GID)

De manera análoga, el comando `id -g` se utiliza para imprimir de forma aislada el número del GID (Group ID) primario del usuario actual.

```bash
usuario@debian:~$ id -g
1000
```

> **Nota:** Se prefieren extraer los identificadores de este modo (`id -u` o `id -g`) al programar *scripts* automatizados, ya que resulta mucho más sencillo de gestionar e introducir en variables (ya que solo devuelve el número limpio) frente a intentar extraer ese dato procesando texto de la salida larga del comando original `id`.

---

## Comando groups

El comando `groups` sirve para listar todos los grupos (tanto el principal como los secundarios) a los que pertenece un usuario.

```bash
usuario@debian:~$ groups
usuario cdrom floppy sudo audio dip video plugdev users netdev bluetooth lpadmin scanner
```

**Explicación:** Devuelve de forma clara y limpia la lista de los grupos en los que está inscrito el usuario actual (o el usuario especificado por argumento). El primer grupo de la lista (`usuario`) actúa siempre como el **grupo primario** o predeterminado para esa cuenta, mientras que el resto actúan como **grupos secundarios**, los cuales son los encargados de otorgar o denegar privilegios puntuales en el sistema frente al acceso a hardware, permisos y ciertos ficheros.
