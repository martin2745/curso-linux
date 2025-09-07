# Comando wc

El comando `wc` (word count) en sistemas Unix/Linux es una herramienta muy útil para contar palabras, líneas y caracteres en archivos de texto.

- **Opciones comunes**:
  - `-l`: Muestra solo el recuento de líneas.
  - `-w`: Muestra solo el recuento de palabras.
  - `-c`: Muestra solo el recuento de bytes.
  - `-m`: Muestra solo el recuento de caracteres.
  - `-L`: Muestra la longitud de la línea más larga.

```bash
usuario@debian:~$ echo "VirtualBox es un software de virtualización de código abierto gratuito que permite crear y gestionar máquinas virtuales para ejecutar múltiples sistemas operativos (como Windows, Linux o macOS) simultáneamente en un solo dispositivo físico." > /tmp/texto.txt
usuario@debian:~$ wc -lwc /tmp/texto.txt
  1  33 247 /tmp/texto.txt
```
