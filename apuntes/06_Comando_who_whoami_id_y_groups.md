# Comando who, whoami, id y groups

- `who:` El comando `who` muestra información sobre los usuarios que están actualmente conectados al sistema. En este caso, muestra dos usuarios: "nuevo" y "usuario". Muestra la terminal (pts/0 y pts/1) desde la que están conectados, así como la hora y la dirección IP.

```bash
usuario@debian:~$ who
nuevo    pts/0        2024-04-25 18:46 (10.0.2.2)
usuario  pts/1        2024-04-25 17:44 (10.0.2.2)
```

- `whoami:` El comando `whoami` imprime el nombre del usuario efectivo. Simplemente devuelve el nombre de usuario actual, que en este caso es "usuario".

```bash
usuario@debian:~$ whoami
usuario
```

- `id`: El comando `id` muestra información sobre el usuario actual, incluyendo el UID (User ID), GID (Group ID), y los grupos a los que pertenece. Muestra el UID y GID del usuario actual como 1000, junto con la lista de grupos a los que pertenece.

```bash
usuario@debian:~$ id
uid=1000(usuario) gid=1000(usuario) grupos=1000(usuario),24(cdrom),25(floppy),27(sudo),29(audio),30(dip),44(video),46(plugdev),100(users),106(netdev),112(bluetooth),114(lpadmin),117(scanner)
```

- `id -u`: El comando `id -u` muestra el UID (User ID) del usuario actual. En este caso, el UID del usuario actual es 1000.

```bash
usuario@debian:~$ id -u
1000

usuario@debian:~$ id -u root
0
```

- `id -g`: El comando `id -g` muestra el GID (Group ID) del usuario actual. Muestra el GID del usuario actual, que es 1000 en este caso.

```bash
usuario@debian:~$ id -g
1000
```

- `groups`: El comando `groups` muestra los grupos a los que pertenece el usuario actual. Muestra una lista de los grupos a los que pertenece el usuario actual.

```bash
usuario@debian:~$ groups
usuario cdrom floppy sudo audio dip video plugdev users netdev bluetooth lpadmin scanner
```
