# ss y netstat

Tanto `ss` como `netstat` son comandos utilizados en sistemas Unix y Linux para mostrar información sobre conexiones de red, enrutamiento y estadísticas de red. Opciones comunes para ambas herramientas:

- `-l`: Muestra sólo las conexiones que están escuchando (es decir, los sockets en estado de escucha).
- `-a`: Muestra todas las conexiones, tanto las que están escuchando como las establecidas.
- `-t`: Muestra sólo las conexiones TCP.
- `-u`: Muestra sólo las conexiones UDP.
- `-n`: Muestra las direcciones IP y los números de puerto en formato numérico (sin resolución de nombres).

Podemos ver con ambos comandos la interfaz y puerto que ofrece el servicio (0.0.0.0 significa que se oferta en todas las interfaces de mi máquina en el puerto especificado), así como el servicio que lo expone.

```bash
vagrant@debian:~$ netstat -putan
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      -
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -
tcp        0     52 192.168.33.11:22        192.168.33.1:53679      ESTABLISHED -
tcp6       0      0 :::80                   :::*                    LISTEN      -
tcp6       0      0 :::111                  :::*                    LISTEN      -
tcp6       0      0 :::22                   :::*                    LISTEN      -
udp        0      0 0.0.0.0:68              0.0.0.0:*                           -
udp        0      0 0.0.0.0:111             0.0.0.0:*                           -
udp        0      0 127.0.0.1:323           0.0.0.0:*                           -
udp6       0      0 :::111                  :::*                                -
udp6       0      0 ::1:323                 :::*                                -

vagrant@debian:~$ ss -putan
Netid                   State                    Recv-Q                   Send-Q                                     Local Address:Port                                     Peer Address:Port                   Process
udp                     UNCONN                   0                        0                                                0.0.0.0:68                                            0.0.0.0:*
udp                     UNCONN                   0                        0                                                0.0.0.0:111                                           0.0.0.0:*
udp                     UNCONN                   0                        0                                              127.0.0.1:323                                           0.0.0.0:*
udp                     UNCONN                   0                        0                                                   [::]:111                                              [::]:*
udp                     UNCONN                   0                        0                                                  [::1]:323                                              [::]:*
tcp                     LISTEN                   0                        4096                                             0.0.0.0:111                                           0.0.0.0:*
tcp                     LISTEN                   0                        128                                              0.0.0.0:22                                            0.0.0.0:*
tcp                     ESTAB                    0                        52                                         192.168.33.11:22                                       192.168.33.1:53679
tcp                     LISTEN                   0                        511                                                    *:80                                                  *:*
tcp                     LISTEN                   0                        4096                                                [::]:111                                              [::]:*
tcp                     LISTEN                   0                        128                                                 [::]:22                                               [::]:*
```