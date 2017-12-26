#!/bin/bash

# Comprobar conectividad

ping -q -w 1 -c 1 PublicIP > /dev/null

if [ $? -eq 0 ]; then
  # Hacer el insert
  /usr/bin/psql -h 172.22.200.110 -d db_backup -U carlos.sanchez -c "INSERT backups into values'"
  if [ $? -eq 0 ]; then
    # Enviar por correo el aviso de que hay que ingresar el registro de la copia manualmente
else
  # Si no hay conexión, modificar el backup_status y añadir el fallo
  /usr/bin/psql -h 172.22.200.110 -d db_backup -U carlos.sanchez -c
  if [[ $? -ne 0 ]]; then
    # Enviar notificación de que ha fallado coconut db
  fi
  # Notificación no se ha podido almacenar la copia de dicha máquina en remoto
fi
