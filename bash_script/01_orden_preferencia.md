# Orden de preferencia

En Linux, cuando ejecutas un comando en la terminal, el sistema sigue un **orden de preferencia** para determinar qué ejecutar. El orden es el siguiente:

```bash
alias > keyword > function > builtin > file
```

Indica cómo el shell (como `bash` o `zsh`) prioriza las distintas formas en que un comando puede estar definido. Vamos a explicarlo con detalle:

### 1. **Alias**  
- Son atajos que el usuario define para simplificar comandos más largos.  
- Se crean con `alias nombre='comando'`.  
- Se revisan con `alias` o `type nombre`.  
- **Ejemplo:**  
```bash
┌──(kali㉿kali)-[~]
└─$ type -a ls
ls is an alias for ls --color=auto
ls is /usr/bin/ls
ls is /bin/ls
```
Si escribimos `ls`, el shell usará el alias definido en el `.bashrc` antes de cualquier otro tipo de comando.

### 2. **Keyword (Palabra clave de shell)**  
- Son palabras reservadas del shell con significado especial, como `if`, `for`, `while`, `case`, etc.  
- **Ejemplo:**  
```bash
┌──(kali㉿kali)-[~]
└─$ if [ 5 -eq 5 ]; then; echo "5 es igual a 5"; fi
5 es igual a 5
```
- Aquí, `if` es una **keyword**, no un comando ejecutable.

### 3. **Function (Función de shell)**  
- Definidas dentro del shell, permiten agrupar comandos en una estructura reutilizable.  
- Se crean con la sintaxis:  
```bash
function nombre {
comandos
}
```
- Se revisan con `declare -f nombre` o `type nombre`.  
- **Ejemplo:**  
```bash
┌──(kali㉿kali)-[~]
└─$ function nombre {
echo "Me llamo Martín :)"
function> }

┌──(kali㉿kali)-[~]
└─$ nombre
Me llamo Martín :)

┌──(kali㉿kali)-[~]
└─$ declare -f nombre
nombre () {
        echo "Me llamo Martín :)"
}
```
- Si ejecutas `nombre`, se usará esta función antes que un comando del sistema si existiera.

### 4. **Builtin (Comando interno del shell)**  
- Son comandos incorporados dentro del shell, ejecutados sin llamar a un programa externo.  
- Algunos ejemplos: `cd`, `echo`, `exit`, `read`, `set`.  
- Se revisan con `help comando` o `type comando`.  
- **Ejemplo:**  
```bash
echo "Me llamo Martín :)"
```
- Aquí, `echo` es un **shell builtin**, pero si existe un alias `alias echo='echo -e'`, el alias tendrá prioridad.

### 5. **File (Ejecutable en el sistema)**  
- Si no se encuentra en las opciones anteriores, el shell busca en los directorios de `$PATH`.  
- Usa `which comando` o `type comando` para verificar.  
- **Ejemplo:**  
```bash
┌──(kali㉿kali)-[~]
└─$ type ls
ls is an alias for ls --color=auto

┌──(kali㉿kali)-[~]
└─$ type -a ls
ls is an alias for ls --color=auto
ls is /usr/bin/ls
ls is /bin/ls

┌──(kali㉿kali)-[~]
└─$ which ls
ls: aliased to ls --color=auto
```
- Aquí, el shell ejecuta el alias de `ls` creado en el `.bashrc` pero si no existiera, ejecutaría el archivo `ls` ubicado en `/usr/bin/ls`.

---

### **Ejemplo de Prioridad en Acción**

Todo lo anterior se puede ver reflejado a continuación.

```bash
┌──(kali㉿kali)-[~]
└─$ type -a ls
ls is an alias for ls --color=auto
ls is /usr/bin/ls
ls is /bin/ls

┌──(kali㉿kali)-[~]
└─$ function ls {
function> echo "Soy la función ls"
function> }

┌──(kali㉿kali)-[~]
└─$ type -a ls
ls is an alias for ls --color=auto
ls is a shell function
ls is /usr/bin/ls
ls is /bin/ls

┌──(kali㉿kali)-[~]
└─$ ls
Desktop  Documents  Downloads  Music  Pictures  Public  Templates  Videos  copias # Se muestra con colores

┌──(kali㉿kali)-[~]
└─$ unalias ls

┌──(kali㉿kali)-[~]
└─$ type -a ls
ls is a shell function
ls is /usr/bin/ls
ls is /bin/ls

┌──(kali㉿kali)-[~]
└─$ ls
Soy la función ls

┌──(kali㉿kali)-[~]
└─$ unset -f ls

┌──(kali㉿kali)-[~]
└─$ type -a ls
ls is /usr/bin/ls
ls is /bin/ls

┌──(kali㉿kali)-[~]
└─$ ls
Desktop  Documents  Downloads  Music  Pictures  Public  Templates  Videos  copias # Se muestra sin colores

```
---

### **En resumen**
Cuando ejecutas un comando en Linux, el shell sigue este orden:  
1. **Alias** → Si existe, lo usa primero.  
2. **Keyword** → Si el comando es una palabra clave reservada, la ejecuta.  
3. **Function** → Si hay una función con ese nombre, la ejecuta.  
4. **Builtin** → Si es un comando interno del shell, lo usa.  
5. **File** → Finalmente, busca un ejecutable en `$PATH`.  

Esto nos permite personalizar y modificar el comportamiento de los comandos según tus necesidades.