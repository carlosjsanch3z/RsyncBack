### Habilitar Acceso SSH Root de la máquina que almacena las copias

Definir una contraseña:
~~~
passwd root
~~~

Cambiar los siguientes valores en el fichero /etc/ssh/sshd_config:
~~~
PermitRootLogin yes
PasswordAuthentication yes
~~~

Reiniciar el servicio SSH:
~~~
systemctl restart ssh
~~~

Crear los directorios para cada una de las máquinas en el servidor remoto:
~~~
mkdir -p /var/www/html/data/charlie/files/{Mickey,Minnie,Donald}
~~~



### En Mickey
~~~
root@mickey:~# nano .pgpass
~~~

Añadir:

~~~
*:*:*:user:password
~~~

Definir los permisos apropiados al fichero:
~~~
root@mickey:~# chmod 600 /root/.pgpass
~~~

Crear una clave pública:
~~~
ssh-keygen -t rsa
~~~

Pasar la clave a la máquina remota:
~~~
cat ~/.ssh/id_rsa.pub | ssh user@IP 'cat >> .ssh/authorized_keys'
~~~

Cambiar los permisos:
~~~
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
~~~
