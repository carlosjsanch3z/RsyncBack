## RsyncBack
Script written in bash, to make backup copies of several hosts, making a complete backup weekly and an incremental backup every day.

## NOTA: Antes de ejecutar el script con systemd

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
