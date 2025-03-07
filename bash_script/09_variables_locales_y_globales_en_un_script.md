# Variables locales y globales en un script

`global, local`

Todas las variables en los scripts bash, a menos que se definan de otra manera, son globales, es decir, una vez definidas pueden ser utilizadas en cualquier parte del script. Para que una variable sea local, es decir, tenga sentido solamente dentro de una sección del script, como en una función, y no en todo el script, debe ser precedida por la sentencia: local.

1. `caso A`: Sin sentencia local para la variable `NOMBRE`.

```bash
si@si-VirtualBox:~$ cat script.sh
    #!/bin/bash

    function dentro_variable_local() {
            NOMBRE="DENTRO"
            echo ${NOMBRE}
    }

    NOMBRE="FUERA"
    echo ${NOMBRE}

    dentro_variable_local
    echo ${NOMBRE}

si@si-VirtualBox:~$ ./script.sh
FUERA
DENTRO
DENTRO
```

2. `caso B`: Con sentencia local para la variable `NOMBRE`.

```bash
si@si-VirtualBox:~$ cat script.sh
    #!/bin/bash

    function dentro_variable_local() {
            local NOMBRE="DENTRO"
            echo ${NOMBRE}
    }

    NOMBRE="FUERA"
    echo ${NOMBRE}

    dentro_variable_local
    echo ${NOMBRE}

si@si-VirtualBox:~$ ./script.sh
FUERA
DENTRO
FUERA
```