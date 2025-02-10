# Comando command y builting

El orden de ejecución en Linux es:

- **alias**:
  - Localización: $HOME/.bashrc, /etc/bashrc
  - Descripción: Crea un alias para un comando.
- **keywords**:
  - Palabras clave: function, if, for...
  - Descripción: Palabras reservadas del lenguaje de scripting de Bash.
- **functions**:
  - Funciones: nombre_funcion() {...}
  - Descripción: Define funciones personalizadas en Bash.
- **builtin**:
  - Descripción: Comandos internos de Bash que siempre están cargados en memoria.
- **file**:
  - Descripción: Scripts y programas ejecutables (según PATH).

**command**:

- Descripción: Busca comandos builtin y files para su ejecución.

**builtin**:

- Descripción: Busca comandos internos (builtin) para su ejecución.

```bash
martin@debian12:~$ type -a ls
ls es un alias de `ls --color=auto'
ls is /usr/bin/ls
ls is /bin/ls
```

```bash
martin@debian12:~$ command ls
d1	   Documentos  fichero.txt  Música	Público
Descargas  Escritorio  Imágenes     Plantillas	Vídeos
```

```bash
martin@debian12:~$ type -a cd
cd es una orden interna del shell
martin@debian12:~$ command cd
martin@debian12:~$ builtin cd
```
