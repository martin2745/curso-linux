# Introducción a Linux

![Linux](./imagenes/linux.png)

Linux es un sistema operativo de código abierto creado por Linus Torvalds en 1991, inicialmente como un proyecto personal para desarrollar un sistema gratuito basado en Unix. A diferencia de sistemas como Windows o macOS, el código fuente de Linux es público, lo que permite que cualquier persona pueda ver, modificar y distribuir el software. Esto ha dado lugar a una gran cantidad de distribuciones, como Ubuntu, Debian o Fedora, adaptadas a diferentes necesidades.

Linux es conocido por su seguridad, estabilidad y flexibilidad, características que lo hacen ideal para servidores y sistemas críticos, además de ser muy utilizado en supercomputadoras y dispositivos embebidos como routers o dispositivos IoT. Aunque ofrece interfaces gráficas similares a otros sistemas operativos, también tiene una poderosa interfaz de línea de comandos que es popular entre programadores y administradores de sistemas. La comunidad activa que respalda Linux fomenta la colaboración y el soporte continuo, y su licencia GPL asegura que cualquier cambio o mejora en el software sea libremente compartido. Aunque no es tan común en escritorios personales, Linux es ampliamente utilizado en servidores web, infraestructura tecnológica, y especialmente en la nube, donde su eficiencia y control lo hacen una opción preferida.

## Índice de contenidos

### Apuntes de comandos

- [01 - Sistema de ficheros de Linux](./apuntes/01_Sistema_De_Ficheros.md)
- [02 - Entorno y variables de entorno en Linux](./apuntes/02_Entorno_y_variables_de_entorno_en_Linux.md)
- [03 - Comandos básicos](./apuntes/03_Comandos_Basicos.md)
- [04 - Comando ls](./apuntes/04_Comando_ls.md)
- [05 - Comando head y tail](./apuntes/05_Comando_head_y_tail.md)
- [06 - Comando who, whoami, id y groups](./apuntes/06_who_whoami_id_y_groups.md)
- [07 - Comando whitch y type](./apuntes/07_Comando_whitch_y_type.md)
- [08 - Comando sort](./apuntes/08_Comando_sort.md)
- [09 - Comando grep, egre, expresiones regulares y metacaracteres](./apuntes/09_Comando_grep_egre_expresiones_regulares_y_metacaracteres.md)
- [10 - Redirecciones](./apuntes/10_Redirecciones.md)
- [11 - Comando wc](./apuntes/11_Comando_wc.md)
- [12 - Comando dd](./apuntes/12_Comando_dd.md)
- [13 - Comando df](./apuntes/13_Comando_df.md)
- [14 - Comando du](./apuntes/14_Comando_du.md)
- [15 - Comando sed](./apuntes/15_Comando_sed.md)
- [16 - Comando alias](./apuntes/16_Comando_alias.md)
- [17 - Comando find](./apuntes/17_Comando_find.md)
- [18 - Comando cut](./apuntes/18_Comando_cut.md)
- [19 - Comando awk](./apuntes/19_Comando_awk.md)
- [20 - Comando tr](./apuntes/20_Comando_tr.md)
- [21 - Comando history](./apuntes/21_Comando_history.md)
- [22 - Comando ps, psgrep, ptree, pidof, kill y killall](./apuntes/22_Comando_ps_psgrep_ptree_pidof_kill_y_killall.md)
- [23 - Comando tar](./apuntes/23_Comando_tar.md)
- [24 - Comando atime, mtime, ctime y touch](./apuntes/24_Comando_atime_mtime_ctime_y_touch.md)
- [25 - Comando mount y umount](./apuntes/25_Comando_mount_y_umount.md)
- [26 - Comando command y builting](./apuntes/26_Comando_command_y_builting.md)
- [27 - Repositorios](./apuntes/27_Repositorios.md)
- [28 - Gestion de usuarios y permisos](./apuntes/28_Gestion_de_usuarios_y_permisos.md)
- [29 - Niveles de arranque en Linux](./apuntes/29_Niveles_de_arranque_en_Linux.md)
- [30 - Comando systemd systemctl e init.d](./apuntes/30_Comando_systemd_systemctl_e_init.d.md)
- [31 - Comando ip e ifconfig](./apuntes/31_Comando_ip_e_ifconfig.md)
- [32 - Comando ss y netstat](./apuntes/32_Comando_ss_y_netstat.md)
- [33 - Comando wget y curl](./apuntes/33_Comando_wget_y_curl.md)
- [34 - Comando ssh y scp](./apuntes/34_Comando_ssh_y_scp.md)
- [35 - Crontab y at](./apuntes/35_Crontab_y_at.md)
- [36 - Particionado con fdisk](./apuntes/36_Particionado_con_fdisk.md)
- [37 - Particionado con parted](./apuntes/37_Particionado_con_parted.md)
- [38 - Raid con mdadm](./apuntes/38_Raid_con_mdadm.md)
- [39 - Herramienta tmux](./apuntes/39_Herramienta_tmux.md)
- [40 - Repaso comandos](./apuntes/40_Repaso_comandos.md)

### Tareas

#### Tareas de comandos

- [1.1 Tarea: Creación de una Copia de Seguridad de los Datos](./apuntes/tareas/tarea1.1/1.1_tarea.md)
- [1.2 Tarea: Administración de Procesos y Trabajos en Segundo Plano](./apuntes/tareas/tarea1.2/1.2_tarea.md)
- [1.3 Tarea: Procesamiento de Textos](./apuntes/tareas/tarea1.3/1.3_tarea.md)
- [1.4 Tarea: Creación de un Shell Restringido](./apuntes/tareas/tarea1.4/1.4_tarea.md)

#### Tareas de particionado y Raid 5

- [2.1 Tarea: Práctica de particionado](./apuntes/tareas/tarea2.1/2.1_tarea.md)
- [2.2 Tarea: Configuración de un RAID 5 con mdadm](./apuntes/tareas/tarea2.2/2.2_tarea.md)

#### Tareas de permisos y ACLs

- [3.1 Tarea: Práctica de permisos y ACLs](./apuntes/tareas/tarea3.1/3.1_tarea.md)

### Apuntes de Scripting en Bash

- [01 - orden de preferencia](./bash_script/01_orden_preferencia.md)
- [02 - declare, typeset y readonly](./bash_script/02_declare_typeset_readonly.md)
- [03 - set, unset y env](./bash_script/03_set_unset_env.md)
- [04 - source y export](./bash_script/04_source_export.md)
- [05 - Comillas en variables de bash](./bash_script/05_comillas_en_variables_de_bash.md)
- [06 - Uso de {variable}](./bash_script/06_uso_de_variable.md)
- [07 - Ejecución de scripts](./bash_script/07_ejecucion_de_scripts.md)
- [08 - subshells](./bash_script/08_subshell.md)
- [09 - Variables locales y globales en un script](./bash_script/09_variables_locales_y_globales_en_un_script.md)
- [10 - Diferencia entre `[` y `[[`](./bash*script/10_diferencia*[\_[[.md)
- [11 - arrays en bash](./bash_script/11_arrays_en_bash.md)
- [12 - cheatsheet bash y estructuras](./bash_script/12_cheatsheet_bash_y_estructuras.md)

### Tareas de Scripting en Bash

#### Boletines

- [01 - Boletín](./bash_script/tareas/boletines/01_boletin/boletin1.md)
- [02 - Boletín](./bash_script/tareas/boletines/02_boletin/boletin2.md)
- [03 - Boletín](./bash_script/tareas/boletines/03_boletin/boletin3.md)
- [04 - Boletín](./bash_script/tareas/boletines/04_boletin/boletin4.md)
- [05 - Boletín](./bash_script/tareas/boletines/05_boletin/boletin5.md)

#### Tareas

- [4.1 Tarea: Comprobar los datos de una página web](./bash_script/tareas/tareas/tarea4.1/4.1_tarea.md)
- [4.2 Tarea: Comprobación del sistema](./bash_script/tareas/tareas/tarea4.2/4.2_tarea.md)
- [4.3 Tarea: Importa y exporta usuarios en el sistema](./bash_script/tareas/tareas/tarea4.3/4.3_tarea.md)
