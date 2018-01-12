# RsyncBack
Script written in bash, to make backup copies of several hosts, making a complete backup weekly and an incremental backup every day.

## Alojamiento o Ubicación del script
El script se encuentra alojado en una máquina llamada "monitor", donde se ha utilizado un daemon, creando un service y un timer en /etc/systemd/system/.
#### Service
~~~
[Unit]
Description=Automatizar Copias de Respaldo

[Service]
User=root
Type=simple
ExecStart=/bin/bash /usr/local/sbin/RsyncBack/backup.sh

[Install]
WantedBy=multi-user.target
~~~
#### Timer
~~~
[Unit]
Description=Ejecutar Copia de Respaldo

[Timer]
OnCalendar=*-*-* 00:43:00
Persistent=true

[Install]
WantedBy=multi-user.target
~~~

## Conexión PostgreSQL - Sin introducir contraseña
Necesario crear un fichero llamado ".pgpass" para incluir dentro la contraseña del usuario de la base de datos:
~~~
*:*:*:user:password
~~~

Para evitar el tener que introducir la contraseña interactivamente, una de las posibilidades que ofrece PostgreSQL es almacenarla en un fichero como el anterior.
Cambiar los permisos a dicho fichero:
~~~
chmod 600 /root/.pgpass
~~~
## Conexión SSH - Sin introducir contraseña
En la máquina remota que vamos a realizar la copia de respaldo, deberá estar la clave pública del host "monitor"
~~~
cat ~/.ssh/id_rsa.pub | ssh user@IP 'cat >> .ssh/authorized_keys'
~~~
o:
~~~
ssh-copy-id -i ~/.ssh/id_rsa.pub "usuario@ip -p 22"
~~~

## Directorios necesarios
En la máquina remota debe existir la carpeta "destino", antes de iniciar el script debido a que "rsync" su funcionamiento base consiste
en reflejar los ficheros existentes en un origen a un destino.

## Directorios a excluir
Los directorios que no queremos respaldar, lo indicamos en un fichero con el mismo nombre de la máquina en el home del usuario "root"
Ejemplo:
~~~
/media/*
/mnt/*
/opt/*
/proc/*
/run/*
/sbin/*
/srv/*
/sys/*
/tmp/*
/usr/*
~~~
## Claves para encriptar directorio crítico
Comando:
~~~
gpg --full-generate-key
~~~
Ejemplos: 
Encriptar (Necesario que el directorio se encuentre empaquetado antes) 
~~~
tar -zcf test.tar.gz test/ gpg --encrypt --recipient coconutkey test.tar.gz
~~~
Desencriptar:
~~~
gpg -d -o test.tar.gz test.tar.gz.gpg
~~~

## Explicación breve del código

El script comprueba que tenga conectividad con el servidor encargado de almacenar las copias de respaldo en un volumen localmente y la conectividad con la base de datos de la aplicación que aloja los registros de dichas copias.

Comprueba la existencia de un fichero log denominado "Backup-FechaActual"

Comprueba que exista el fichero donde estan definida la información de las máquinas remotas que queremos respaldar:
~~~
mickey:root:10.0.0.12:debian:172.22.200.2
minnie:root:10.0.0.4:ubuntu:172.22.200.56
donald:root:10.0.0.11:centos:172.22.200.37
~~~
Consulta la información del fichero anterior y rellenar las variables necesarias.



Todas las lineas volcadas en el fichero de log, serán enviadas por correo, al email declarado en la variable "recipient"

