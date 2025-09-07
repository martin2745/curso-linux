# Comando cut

El comando _cut_ se utiliza para cortar secciones específicas de cada línea de un archivo de texto. Su sintaxis básica es:

```bash
cut [opciones] archivo
```

- **-c**: La opción _-c_ se utiliza para seleccionar caracteres específicos de cada línea en lugar de campos delimitados. Los números pueden ir separados por _,_ lo que indica que se quieren los caracteres concretos en la posición especificada o con _-_ estableciendo un rango.
- **-d**: La opción _-d_ se utiliza para especificar el delimitador que _cut_ debe utilizar para separar los campos en cada línea del archivo de entrada, el cual solo admitirá un caracter. Por defecto, _cut_ utiliza el tabulador como delimitador.
- **-f**: La opción _-f_ permite elegir las columnas que queremos que se muestren. La forma de seleccionar funciona igual que para la opción _-c_.

```bash
root@debian:~# cut -c 1-5,10- /etc/passwd | tail -1
usuar:1001:1001::/home/usuario:/bin/bash
root@debian:~# cat /etc/passwd | tail -1
usuario:x:1001:1001::/home/usuario:/bin/bash
```

```bash
root@debian:~# cut -d ':' -f 1,7 /etc/passwd | tail -1
usuario:/bin/bash

root@debian:~# cut -d ':' -f 1-3 /etc/passwd | tail -1
usuario:x:1001

root@debian:~# cat /etc/passwd | cut -d: -f1,7 | grep -w /bin/bash | wc -l
3
root@debian:~# cat /etc/passwd | cut -d ":" -f1,7 | grep -w /bin/bash | cat -n
     1  root:/bin/bash
     2  vagrant:/bin/bash
     3  usuario:/bin/bash
```
