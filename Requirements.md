Crear los directorios para cada una de las máquinas en el servidor remoto:
~~~
mkdir -p /var/www/html/data/charlie/files/Mickey
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
