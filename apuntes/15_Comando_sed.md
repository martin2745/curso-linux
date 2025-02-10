# Comando sed

El comando `sed` en Linux es un editor de flujo de texto que permite realizar cambios en archivos de texto desde la línea de comandos. Por ejemplo, para reemplazar todas las instancias de "hola" por "adiós" en un archivo llamado `archivo.txt`, usarías el siguiente comando:

```
sed 's/hola/adiós/g' archivo.txt
```

1. `-e`: Este parámetro permite especificar múltiples comandos de `sed` en una sola línea de comando. Por ejemplo, `sed -e 'comando1' -e 'comando2' archivo` ejecutaría ambos `comando1` y `comando2` en el archivo.

2. `-i`: Modificará el archivo de entrada directamente. Por ejemplo, `sed -i 's/antiguo/nuevo/g' archivo` cambiaría todas las ocurrencias de "antiguo" por "nuevo" en el archivo `archivo`, modificando el archivo en su lugar.

3. `-n`: Este parámetro suprime la salida automática de `sed`. Por defecto, `sed` imprime todas las líneas después de aplicar los comandos. Con `-n`, solo imprime las líneas que se le indiquen explícitamente. Por ejemplo, `sed -n '5p' archivo` imprimiría solo la quinta línea del archivo.

4. `-r`: Permite el uso de expresiones regulares.

## Ejemplos de uso

Cambia los parametros `"` y `,` por ` ` y edita el fichero file.tmp.

```bash
si@si-VirtualBox:/tmp/prueba$ sed -i -e 's#"# #g' -e 's#,# #g' file.tmp
 user11   p11   /bin/bash   /tmp
 user2   p2   /bin/false   /home/user2
 user2   p2   /bin/false   /home/user2
```

- No muestra cambios por pantalla por `-n`.

```bash
si@si-VirtualBox:/tmp/prueba$ sed -n -e 's#"# #g' -e 's#,# #g' file.tmp
si@si-VirtualBox:/tmp/prueba$
```

- Si no se usa `g` solo se elimina la primera ocurrencia por linea.

```bash
si@si-VirtualBox:/tmp/prueba$ sed -e 's#user2#usuario#g' file.tmp
"user11","p11","/bin/bash","/tmp"
"usuario","p2","/bin/false","/home/usuario"
"usuario","p2","/bin/false","/home/usuario"

si@si-VirtualBox:/tmp/prueba$ sed -e 's#user2#usuario#' file.tmp
"user11","p11","/bin/bash","/tmp"
"usuario","p2","/bin/false","/home/user2"
"usuario","p2","/bin/false","/home/user2"
```

- La opción `p` hace que se muestren las lineas donde se han realizado sustituciones.

```bash
si@si-VirtualBox:/tmp/prueba$ sed -e 's/user2/usuario/gp' file.tmp
"user11","p11","/bin/bash","/tmp"
"usuario","p2","/bin/false","/home/usuario"
"usuario","p2","/bin/false","/home/usuario"
"usuario","p2","/bin/false","/home/usuario"
"usuario","p2","/bin/false","/home/usuario"

si@si-VirtualBox:/tmp/prueba$ sed -n -e 's/user2/usuario/gp' file.tmp
"usuario","p2","/bin/false","/home/usuario"
"usuario","p2","/bin/false","/home/usuario"
```

- Elimina las lineas con sed y `d`.

```bash
si@si-VirtualBox:/tmp/prueba$ for i in $(seq 1 80); do $(touch prueba.txt && echo "${i}" >> prueba.txt); done;
si@si-VirtualBox:/tmp/prueba$ head prueba.txt
1
2
3
4
5
6
7
8
9
10
```

```bash
si@si-VirtualBox:/tmp/prueba$ sed -i '2,7d' prueba.txt
si@si-VirtualBox:/tmp/prueba$ head prueba.txt
1
8
9
10
11
12
13
14
15
16
```

```bash
si@si-VirtualBox:/tmp/prueba$ sed -i '1d' prueba.txt
si@si-VirtualBox:/tmp/prueba$ head prueba.txt
8
9
10
11
12
13
14
15
16
17
```

```bash
si@si-VirtualBox:/tmp/prueba$ sed -i 1'd' prueba.txt
si@si-VirtualBox:/tmp/prueba$ head prueba.txt
9
10
11
12
13
14
15
16
17
18
```

```bash
si@si-VirtualBox:/tmp/prueba$ sed -i 1,5'd' prueba.txt
si@si-VirtualBox:/tmp/prueba$ head prueba.txt
14
15
16
17
18
19
20
21
22
23
```

- Rangos para sustituir.

```bash
si@si-VirtualBox:/tmp/prueba$ sed -i 's/false/bash/g' file.tmp
si@si-VirtualBox:/tmp/prueba$ cat file.tmp
"user11","p11","/bin/bash","/tmp"
"user2","p2","/bin/bash","/home/user2"
"user2","p2","/bin/bash","/home/user2"

si@si-VirtualBox:/tmp/prueba$ sed 2's/bash/false/g' file.tmp
"user11","p11","/bin/bash","/tmp"
"user2","p2","/bin/false","/home/user2"
"user2","p2","/bin/bash","/home/user2"

si@si-VirtualBox:/tmp/prueba$ sed '2s/bash/false/g' file.tmp
"user11","p11","/bin/bash","/tmp"
"user2","p2","/bin/false","/home/user2"
"user2","p2","/bin/bash","/home/user2"

si@si-VirtualBox:/tmp/prueba$ sed 1,3's/bash/false/g' file.tmp
"user11","p11","/bin/false","/tmp"
"user2","p2","/bin/false","/home/user2"
"user2","p2","/bin/false","/home/user2"

si@si-VirtualBox:/tmp/prueba$ sed '1,3s/bash/false/g' file.tmp
"user11","p11","/bin/false","/tmp"
"user2","p2","/bin/false","/home/user2"
"user2","p2","/bin/false","/home/user2"
```

- Guardar la modificación en otro fichero con `w`

```bash
si@si-VirtualBox:/tmp/prueba$ sed -e "s/user/usuario/gw fileModificado.tmp" file.tmp
"usuario11","p11","/bin/bash","/tmp"
"usuario2","p2","/bin/bash","/home/usuario2"
"usuario2","p2","/bin/bash","/home/usuario2"

si@si-VirtualBox:/tmp/prueba$ cat fileModificado.tmp
"usuario11","p11","/bin/bash","/tmp"
"usuario2","p2","/bin/bash","/home/usuario2"
"usuario2","p2","/bin/bash","/home/usuario2"
```

- Permite el uso de expresiones regulares con la opción `-r`.

```bash
si@si-VirtualBox:/tmp/prueba$ echo 'http://www.example1.local/cig/' | sed -r 's|(http)(://)(www.example1.local/cig)|\1s\2example1.local/cig|'
https://example1.local/cig/
```

**Desglose del patrón de búsqueda**

1. **(http)**: Captura la cadena `http` y la guarda en el grupo de captura 1.
2. **(://)**: Captura los caracteres `://` y los guarda en el grupo de captura 2.
3. **(www.example1.local/cig)**: Captura la cadena `www.example1.local/cig` y la guarda en el grupo de captura 3.

**Desglose del patrón de reemplazo**

- **\1**: Referencia al contenido capturado en el grupo 1, que es `http`.
- **s**: Un carácter literal que se inserta en el resultado.
- **\2**: Referencia al contenido capturado en el grupo 2, que es `://`.
- **example1.local/cig**: Texto literal que se inserta directamente en el resultado.

**Funcionamiento del comando completo**

1. **Entrada**: `'http://www.example1.local/cig/'`
2. **Patrón de búsqueda**: `(http)(://)(www.example1.local/cig)`
3. **Coincidencia**:
   - `http` se guarda en el grupo 1.
   - `://` se guarda en el grupo 2.
   - `www.example1.local/cig` se guarda en el grupo 3.
4. **Reemplazo**: `\1s\2example1.local/cig`
   - `\1` se reemplaza con `http`.
   - `s` se inserta literalmente.
   - `\2` se reemplaza con `://`.
   - `example1.local/cig` se inserta literalmente.
