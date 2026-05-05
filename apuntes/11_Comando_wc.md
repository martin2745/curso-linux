# Comando wc

## Índice

1. [Opciones comunes](#1-opciones-comunes)
2. [Ejemplo de uso](#2-ejemplo-de-uso)

---

El comando `wc` (_word count_) en sistemas Unix/Linux es una herramienta muy útil para contar palabras, líneas y caracteres en archivos de texto. También es comúnmente utilizado junto con tuberías (`|`) para contar la cantidad de resultados devueltos por otros comandos.

---

## 1. Opciones comunes

| Parámetro | Descripción |
|-----------|-------------|
| `-l` | Muestra solo el recuento de líneas. |
| `-w` | Muestra solo el recuento de palabras. |
| `-c` | Muestra solo el recuento de bytes. |
| `-m` | Muestra solo el recuento de caracteres. |
| `-L` | Muestra la longitud de la línea más larga. |

> **Nota:** Por defecto, si se ejecuta `wc` sin opciones, mostrará el número de líneas, palabras y bytes, en ese orden.

---

## 2. Ejemplo de uso

El siguiente ejemplo muestra la creación de un archivo de texto con un contenido específico y la posterior ejecución del comando `wc` combinando múltiples opciones (`-l`, `-w`, `-c`) simultáneamente.

```bash
usuario@debian:~$ echo "VirtualBox es un software de virtualización de código abierto gratuito que permite crear y gestionar máquinas virtuales para ejecutar múltiples sistemas operativos (como Windows, Linux o macOS) simultáneamente en un solo dispositivo físico." > /tmp/texto.txt
usuario@debian:~$ wc -lwc /tmp/texto.txt
  1  33 247 /tmp/texto.txt
```

> **Explicación del output:** La salida `1 33 247 /tmp/texto.txt` significa que el archivo contiene 1 línea, 33 palabras y 247 caracteres/bytes, seguido del nombre del archivo analizado.
