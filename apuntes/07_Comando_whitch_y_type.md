# Comando which y type

Ambos comandos, `which` y `type`, son útiles para identificar la ubicación de un comando específico y para determinar cómo se interpretará un comando en particular.

- **`which`**: Es un comando que se utiliza para encontrar la ubicación de un comando ejecutable en el sistema de archivos del usuario. Devuelve la ruta completa del ejecutable de ese comando si está presente en alguna de las rutas de búsqueda del sistema.

```bash
usuario@debian:~$ which ls
/usr/bin/ls
```

- **`type`**: Es un comando que no solo muestra la ubicación de un comando ejecutable, sino también cómo será interpretado por el shell. Puede ser un comando interno del shell, un comando externo (ubicación del archivo ejecutable) o una función shell definida por el usuario.

```bash
usuario@debian:~$ type ls
ls es un alias de `ls --color=auto`

usuario@debian:~$ type -a ls
ls es un alias de `ls --color=auto'
ls is /usr/bin/ls
ls is /bin/ls
```
