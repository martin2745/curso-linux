
# Redirecciones

```bash
martin@debian12:~$ ls -l > fichero.txt
martin@debian12:~$ ls -l >> fichero.txt
martin@debian12:~$ ls -li > fichero.txt 2>&1
martin@debian12:~$ ls -li &> fichero.txt
martin@debian12:~$ cat < fichero.txt
```

```bash
martin@debian12:~$ cat > fichero.txt << VAI
> hola
> Que
> Tal?
> VAI
martin@debian12:~$ cat fichero.txt
hola
Que
Tal?
```

```bash
martin@debian12:~$ cat /etc/passwd | tail -2 | tee /tmp/pass.tmp
martin:x:1000:1000:martin,,,:/home/martin:/bin/bash
vboxadd:x:999:1::/var/run/vboxadd:/bin/false

martin@debian12:~$ cat /tmp/pass.tmp
martin:x:1000:1000:martin,,,:/home/martin:/bin/bash
vboxadd:x:999:1::/var/run/vboxadd:/bin/false

martin@debian12:~$ sudo cat /etc/shadow | tail -2 | tee -a /tmp/pass.tmp
martin:$y$j9T$D1YstIGhwPXktsEmolZg./$I7fKcY0m9yE2LYgGBEn8yolExy5PLvBTIlZf5keudM3:19770:0:99999:7:::
vboxadd:!:19755::::::

martin@debian12:~$ cat /tmp/pass.tmp
martin:x:1000:1000:martin,,,:/home/martin:/bin/bash
vboxadd:x:999:1::/var/run/vboxadd:/bin/false
martin:$y$j9T$D1YstIGhwPXktsEmolZg./$I7fKcY0m9yE2LYgGBEn8yolExy5PLvBTIlZf5keudM3:19770:0:99999:7:::
vboxadd:!:19755::::::
```

```bash
si@si-VirtualBox:~$ ls > prueba.txt 2>&1
si@si-VirtualBox:~$ cat prueba.txt
Desktop
Documents
Downloads
Music
Pictures
prueba.txt
Public
snap
Templates
Videos
si@si-VirtualBox:~$ lss > prueba.txt 2>&1
si@si-VirtualBox:~$ cat prueba.txt
Command 'lss' not found, but there are 15 similar ones.
```

Hay que tener en cuenta que las salidas de información de `stdin`, `stdout` y `stderr` redirigen al mismo lugar y son los `fd/num` los descriptiones utilizados a la hora de redireccionar la información.

```bash
si@si-VirtualBox:~/Downloads$ ls -l /dev/stdin
lrwxrwxrwx 1 root root 15 jun 15 09:12 /dev/stdin -> /proc/self/fd/0
si@si-VirtualBox:~/Downloads$ ls -l /dev/stdout
lrwxrwxrwx 1 root root 15 jun 15 09:12 /dev/stdout -> /proc/self/fd/1
si@si-VirtualBox:~/Downloads$ ls -l /dev/stderr
lrwxrwxrwx 1 root root 15 jun 15 09:12 /dev/stderr -> /proc/self/fd/2
si@si-VirtualBox:~/Downloads$ ls -l /proc/self/fd/0
lrwx------ 1 si si 64 jun 15 13:16 /proc/self/fd/0 -> /dev/pts/1
si@si-VirtualBox:~/Downloads$ ls -l /proc/self/fd/1
lrwx------ 1 si si 64 jun 15 13:16 /proc/self/fd/1 -> /dev/pts/1
si@si-VirtualBox:~/Downloads$ ls -l /proc/self/fd/2
lrwx------ 1 si si 64 jun 15 13:16 /proc/self/fd/2 -> /dev/pts/1
si@si-VirtualBox:~/Downloads$ ls -l /dev/pts/1
crw--w---- 1 si tty 136, 1 jun 15 13:17 /dev/pts/1
```

_*Nota*_: Tambien existen códigos de error como en el siguiente ejemplo.

## **1. `echo $?` (Código de salida del último comando)**
```bash
┌──(kali㉿kali)-[~]
└─$ whoami
kali

┌──(kali㉿kali)-[~]
└─$ echo $?
0
```
- **Explicación:**  
  - El comando `whoami` muestra el nombre del usuario actual que está ejecutando la terminal. En este caso, el usuario es `kali`.
  - El comando `echo $?` muestra el código de salida del último comando ejecutado.  
  - Como `whoami` se ejecutó correctamente, devuelve `0`, lo que indica **éxito**.

---

## **2. `echo $?` (Código de salida de `ls /noEncontrado`)**
```bash
┌──(kali㉿kali)-[~]
└─$ ls /noEncontrado
ls: cannot access '/noEncontrado': No such file or directory

┌──(kali㉿kali)-[~]
└─$ echo $?
1
```
- **Explicación:**  
  - El comando `ls /noEncontrado` intenta listar el contenido del directorio `/noEncontrado`, pero este no existe.  
  - El error `"No such file or directory"` indica que la ruta especificada no fue encontrada.
  - El código `1` indica un **error de uso incorrecto del comando o fallo específico**. En este caso, se debe a que `ls` no encontró el directorio especificado.

---

## **3. `echo $?` (Código de salida de `whoam`)**
```bash

┌──(kali㉿kali)-[~]
└─$ echo $?
127
```
- **Explicación:**  
  - Esto ocurre porque el comando `whoam` no está en el `PATH` del sistema.
  - El código `127` significa **"comando no encontrado"**, indicando que `whoam` no existe en el sistema.

---

### **Resumen de códigos de salida en este ejemplo**
| Código | Significado |
|--------|------------|
| `0`    | Éxito (el comando `whoami` se ejecutó correctamente). |
| `1`    | Uso incorrecto del comando (`ls` no encontró el directorio especificado). |
| `127`  | Comando no encontrado (`whoam` no existe en el sistema). |

