# Comando alias

Considerando que en ~/.bashrc existe el `alias listar='ls -ltr'`, se ejecuta el comando `alias listar='ls -lahi --color'`. Si por consola lanzamos en ese momento el comando obtenemos:

```bash
usuario@debian:~$ alias listar='ls -lahi --color'
usuario@debian:~$ listar
total 156K
392450 drwx------ 16 usuario usuario 4,0K abr 12 16:29 .
392449 drwxr-xr-x  3 root   root   4,0K feb 17 18:08 ..
392746 -rw-------  1 usuario usuario 1,5K mar  5 16:11 .bash_history
392451 -rw-r--r--  1 usuario usuario  220 feb  2 17:57 .bash_logout
392453 -rw-r--r--  1 usuario usuario 3,5K feb  2 17:57 .bashrc
392470 drwxr-xr-x  8 usuario usuario 4,0K feb  2 18:11 .cache
392460 drwx------  7 usuario usuario 4,0K feb  2 18:10 .config
```

Si en ese momento ejecutamos el comando `source ~/.bashrc && listar` se ha recargado el .bashrc y por lo tanto el alias es `listar='ls -ltr'`.

```bash
usuario@debian:~$ alias
total 36
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Vídeos
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Público
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Plantillas
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Música
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Imágenes
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Escritorio
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Documentos
drwxr-xr-x 2 usuario usuario 4096 feb  2 18:10 Descargas
drwxr-xr-x 2 usuario usuario 4096 mar  4 09:58 d1
-rw-r--r-- 1 usuario usuario    0 abr 12 16:29 fichero.txt
```

```bash
usuario@debian:~$ alias listar='ls -lhai'
usuario@debian:~$ alias directorioTrabajo='pwd'
usuario@debian:~$ alias
alias directorioTrabajo='pwd'
alias listar='ls -lhai'
usuario@debian:~$ unalias directorioTrabajo
usuario@debian:~$ alias
alias listar='ls -lhai'
usuario@debian:~$ unalias -a
usuario@debian:~$ alias
```
