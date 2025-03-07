# subshells

Si colocamos una secuencia de órdenes entre paréntesis, forzamos a que estos comandos se ejecuten en una subshell.

```bash
$ (readonly AAA='aes'; echo $AAA; unset AAA; echo $AAA); AAA='bes'; echo $AAA; unset AAA;
echo $AAA # En la subshell definida con paréntesis y en la shell, las variables AAA son variables distintas.
```