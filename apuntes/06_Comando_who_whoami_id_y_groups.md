# Comando who, whoami, id y groups

- `who:` El comando `who` muestra información sobre los usuarios que están actualmente conectados al sistema. En este caso, muestra dos usuarios: "nuevo" y "si". Muestra la terminal (pts/0 y pts/1) desde la que están conectados, así como la hora y la dirección IP.

```bash
$ who
nuevo    pts/0        2024-04-25 18:46 (10.0.2.2)
si       pts/1        2024-04-25 17:44 (10.0.2.2)
```

- `whoami:` El comando `whoami` imprime el nombre del usuario efectivo. Simplemente devuelve el nombre de usuario actual, que en este caso es "si".

```bash
$ whoami
si
```

- `id`: El comando `id` muestra información sobre el usuario actual, incluyendo el UID (User ID), GID (Group ID), y los grupos a los que pertenece. Muestra el UID y GID del usuario actual como 1000, junto con la lista de grupos a los que pertenece.

```bash
$ id
uid=1000(si) gid=1000(si) groups=1000(si),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),122(lpadmin),135(lxd),136(sambashare)
```

- `id -u`: El comando `id -u` muestra el UID (User ID) del usuario actual. En este caso, el UID del usuario actual es 1000.

```bash
$ id -u
1000
```

- `id -g`: El comando `id -g` muestra el GID (Group ID) del usuario actual. Muestra el GID del usuario actual, que es 1000 en este caso.

```bash
$ id -g
1000
```

- `groups`: El comando `groups` muestra los grupos a los que pertenece el usuario actual. Muestra una lista de los grupos a los que pertenece el usuario actual.

```bash
$ groups
si adm cdrom sudo dip plugdev lpadmin lxd sambashare
```
