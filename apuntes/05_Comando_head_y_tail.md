# Comando head y tail

## `head`

El comando `head` se utiliza para mostrar las primeras líneas de uno o más archivos. Por defecto, muestra las primeras 10 líneas.

### Sintaxis básica

```bash
head [OPCIÓN]... [ARCHIVO]...
```

#### Opciones comunes

- `-n K`, `--lines=K`: Muestra las primeras `K` líneas del archivo. Por ejemplo, `head -n 5 archivo.txt` muestra las primeras 5 líneas.
- `-c K`, `--bytes=K`: Muestra los primeros `K` bytes del archivo. Por ejemplo, `head -c 100 archivo.txt` muestra los primeros 100 bytes.
- `-q`, `--quiet`, `--silent`: No imprime el nombre del archivo cuando se trabaja con múltiples archivos.
- `-v`, `--verbose`: Siempre imprime el nombre del archivo.

#### Ejemplos

- Mostrar las primeras 10 líneas (por defecto):

```bash
head archivo.txt
```

- Mostrar las primeras 20 líneas:

```bash
head -n 20 archivo.txt
```

- Mostrar los primeros 50 bytes:

```bash
head -c 50 archivo.txt
```

- Mostrar las primeras 5 líneas de varios archivos sin imprimir el nombre de los archivos:

```bash
head -n 5 -q archivo1.txt archivo2.txt
```

## `tail`

El comando `tail` se utiliza para mostrar las últimas líneas de uno o más archivos. Por defecto, muestra las últimas 10 líneas.

### Sintaxis básica

```bash
tail [OPCIÓN]... [ARCHIVO]...
```

#### Opciones comunes

- `-n K`, `--lines=K`: Muestra las últimas `K` líneas del archivo. Por ejemplo, `tail -n 5 archivo.txt` muestra las últimas 5 líneas.
- `-c K`, `--bytes=K`: Muestra los últimos `K` bytes del archivo. Por ejemplo, `tail -c 100 archivo.txt` muestra los últimos 100 bytes.
- `-f`, `--follow`: Sigue el archivo en tiempo real, mostrando nuevas líneas a medida que se añaden.
- `-F`: Similar a `-f`, pero también sigue el archivo si se renombra o se reemplaza.
- `--pid=PID`: Con `-f`, finaliza después de que el proceso con el ID especificado finalice.
- `-q`, `--quiet`, `--silent`: No imprime el nombre del archivo cuando se trabaja con múltiples archivos.
- `-v`, `--verbose`: Siempre imprime el nombre del archivo.

#### Ejemplos

- Mostrar las últimas 10 líneas (por defecto):

```bash
tail archivo.txt
```

- Mostrar las últimas 20 líneas:

```bash
tail -n 20 archivo.txt
```

```bash
usuario@debian:/tmp/prueba$ tail -2 users.csv
user04;abc123.;group02;s
user05;abc123.;group02;S
usuario@debian:/tmp/prueba$ tail +2 users.csv
user01;abc123.;group01;N
user02;abc123.;group01;s
user03;abc123.;group01;n
user04;abc123.;group02;s
user05;abc123.;group02;S
```

```bash
usuario@debian:/tmp/prueba$ tail -n -2 users.csv
user04;abc123.;group02;s
user05;abc123.;group02;S
usuario@debian:/tmp/prueba$ tail -n +2 users.csv
user01;abc123.;group01;N
user02;abc123.;group01;s
user03;abc123.;group01;n
user04;abc123.;group02;s
user05;abc123.;group02;S
```

- Mostrar los últimos 50 bytes:

```bash
tail -c 50 archivo.txt
```

- Seguir un archivo en tiempo real:

```bash
tail -f archivo.txt
```

- Seguir un archivo en tiempo real y reconectarse si el archivo es renombrado:

```bash
tail -F archivo.txt
```
