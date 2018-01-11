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
O:
~~~
ssh-copy-id -i ~/.ssh/id_rsa.pub "usuario@ip -p 22"
~~~
Cambiar los permisos:
~~~
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
~~~

### Generar clave privada y publica
gpg --full-generate-key

gpg (GnuPG) 2.1.18; Copyright (C) 2017 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Por favor seleccione tipo de clave deseado:
   (1) RSA y RSA (por defecto)
   (2) DSA y ElGamal
   (3) DSA (sólo firmar)
   (4) RSA (sólo firmar)
Su elección: 1
las claves RSA pueden tener entre 1024 y 4096 bits de longitud.
¿De qué tamaño quiere la clave? (2048) 2048
El tamaño requerido es de 2048 bits
Por favor, especifique el período de validez de la clave.
         0 = la clave nunca caduca
      <n>  = la clave caduca en n días
      <n>w = la clave caduca en n semanas
      <n>m = la clave caduca en n meses
      <n>y = la clave caduca en n años
¿Validez de la clave (0)? 2y
La clave caduca sáb 11 ene 2020 17:37:57 CET
¿Es correcto? (s/n) s

GnuPG debe construir un ID de usuario para identificar su clave.

Nombre y apellidos: coconutkey
Dirección de correo electrónico: carlosjsanchezortega@gmail.com
Comentario: Key encrypt directory
Ha seleccionado este ID de usuario:
    "coconutkey (Key encrypt directory) <carlosjsanchezortega@gmail.com>"

¿Cambia (N)ombre, (C)omentario, (D)irección o (V)ale/(S)alir? V
Es necesario generar muchos bytes aleatorios. Es una buena idea realizar
alguna otra tarea (trabajar en otra ventana/consola, mover el ratón, usar
la red y los discos) durante la generación de números primos. Esto da al
generador de números aleatorios mayor oportunidad de recoger suficiente
entropía.
Es necesario generar muchos bytes aleatorios. Es una buena idea realizar
alguna otra tarea (trabajar en otra ventana/consola, mover el ratón, usar
la red y los discos) durante la generación de números primos. Esto da al
generador de números aleatorios mayor oportunidad de recoger suficiente
entropía.
gpg: clave 34BFCF95BD87A512 marcada como de confianza absoluta
gpg: directory '/root/.gnupg/openpgp-revocs.d' created
gpg: revocation certificate stored as '/root/.gnupg/openpgp-revocs.d/5D4DC871EAC3082A7A9CFC6834BFCF95BD87A512.rev'
claves pública y secreta creadas y firmadas.

pub   rsa2048 2018-01-11 [SC] [caduca: 2020-01-11]
      5D4DC871EAC3082A7A9CFC6834BFCF95BD87A512
      5D4DC871EAC3082A7A9CFC6834BFCF95BD87A512
uid                      coconutkey (Key encrypt directory) <carlosjsanchezortega@gmail.com>
sub   rsa2048 2018-01-11 [E] [caduca: 2020-01-11]

### Encryptar
tar -zcf test.tar.gz test/
gpg --encrypt --recipient coconutkey test.tar.gz

### Des
gpg -d -o test.tar.gz test.tar.gz.gpg

### He colocado los 3 ficheros que definen los directorios a excluir, en cada uno de los hosts 
