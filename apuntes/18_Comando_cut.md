# Comando cut

El comando `cut` se utiliza para cortar secciones específicas de cada línea de un archivo de texto. Su sintaxis básica es:

```bash
cut [opciones] archivo
```

- **`-d`**:

La opción `-d` se utiliza para especificar el delimitador que `cut` debe utilizar para separar los campos en cada línea del archivo de entrada, el cual solo admitirá un caracter. Por defecto, `cut` utiliza el tabulador como delimitador. La sintaxis es la siguiente:

```bash
cut -d <delimitador> archivo
```

- `<delimitador>`: Especifica el carácter que actúa como delimitador de campos.

Por ejemplo, si tienes un archivo de texto donde los campos están separados por comas (`,`), puedes usar la opción `-d` para extraer los campos correctamente:

```bash
cut -d ',' -f1,3 archivo.csv
```

Esto extraería el primer y tercer campo de cada línea del archivo `archivo.csv`, considerando que los campos están separados por comas.

- **`-c`**:

La opción `-c` se utiliza para seleccionar caracteres específicos de cada línea en lugar de campos delimitados. La sintaxis es:

```bash
cut -c <lista_de_caracteres> archivo
```

- `<lista_de_caracteres>`: Especifica los caracteres que deseas seleccionar de cada línea. Puedes especificar un rango de caracteres utilizando el formato `inicio-fin`, o simplemente enumerar los caracteres que deseas seleccionar.

Por ejemplo, si deseas extraer los primeros tres caracteres de cada línea de un archivo, puedes hacerlo así:

```bash
si@si-VirtualBox:/tmp/prueba$ cat p.txt
1234
1234
si@si-VirtualBox:/tmp/prueba$ cut -c 1-3 p.txt
123
123
```

Esto devolverá los primeros tres caracteres de cada línea en el archivo `archivo.txt`.

También puedes especificar caracteres individuales:

```bash
cut -c 1,3,5 archivo.txt
```

Esto devolverá el primer, tercer y quinto carácter de cada línea en el archivo `archivo.txt`.

Además, si necesitas excluir ciertos caracteres, puedes usar el signo de menos `-`:

```bash
cut -c -3 archivo.txt
```

Esto devolverá todos los caracteres de cada línea hasta el tercero, excluyéndolo.

_*Nota: Con `cut` si escribimos -f3,1 no obtenemos la tercera columa y luego la primera. Obtenemos siempre primera y luego tercera. Para este comportamiento necesitaremos el `awk`*_

```bash
si@si-VirtualBox:~$ head /etc/passwd | cut -d ':' -f1,2
root:x
daemon:x
bin:x
sys:x
sync:x
games:x
man:x
lp:x
mail:x
news:x

si@si-VirtualBox:~$ head /etc/passwd | cut -d ':' -f2,1
root:x
daemon:x
bin:x
sys:x
sync:x
games:x
man:x
lp:x
mail:x
news:x
```
