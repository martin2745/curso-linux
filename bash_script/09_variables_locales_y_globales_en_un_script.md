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

En un script de shell en Linux, puedes definir variables locales y globales dentro de una función de la siguiente manera:

#### Sin especificar nada (implícitamente global):

```bash
mi_funcion() {
    variable_global="Hola"
}
```

- **Descripción:** La variable `variable_global` será global y accesible desde cualquier parte del script después de llamar a `mi_funcion()`.

#### Con `local`:

```bash
mi_funcion() {
    local variable_local="Mundo"
}
```

- **Descripción:** `variable_local` será local a la función `mi_funcion()` y no estará disponible fuera de ella.

#### Con `declare`:

```bash
mi_funcion() {
    declare variable_local="Linux"
}
```

- **Descripción:** Similar a `local`, `variable_local` será local a la función `mi_funcion()` y no estará disponible fuera de ella. `declare` es una forma más explícita de declarar variables en Bash.

#### Con `declare -g`:

```bash
mi_funcion() {
    declare -g variable_global="Adiós"
}
```

- **Descripción:** `variable_global` será global, incluso si se define dentro de una función, y será accesible desde cualquier parte del script después de llamar a `mi_funcion()`.

#### Resumen:

- **Global (implícito):** Sin ninguna palabra clave, la variable es global.
- **Local:** Se define usando `local` o `declare` dentro de la función.
- **Global explícito:** Se usa `declare -g` para declarar una variable global dentro de una función.