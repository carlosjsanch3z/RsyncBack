#!/bin/bash

# Comprobar dia de la semana
DOW=$(date +%u)
# Comprobar conectividad con el servidor remoto
ping -q -w 1 -c 1 PublicIP > /dev/null

if [ $? -eq 0 ]; then
  if [[ $DOW -eq 7 ]]; then
    # Hacer una copia completa
    rsync full
    # Guardar el registro de la copia en Coconut
    /usr/bin/psql -h 172.22.200.110 -d db_backup -U carlos.sanchez -c "INSERT backups into values'200'"
    if [ $? -ne 0 ]; then
      # Avisar por correo, ingresar registro manualmente de esta máquina
  else
    # Hacer una copia incremental
    rsync incremental
    # Guardar el registro de la copia incremental en Coconut
    /usr/bin/psql -h 172.22.200.110 -d db_backup -U carlos.sanchez -c "INSERT backups into values'200'"
    if [ $? -ne 0 ]; then
      # Avisar por correo, ingresar registro manualmente de esta máquina
  fi
else
  # Si no hay conexión, modificar el backup_status y añadir el fallo
  /usr/bin/psql -h 172.22.200.110 -d db_backup -U carlos.sanchez -c "INSERT backups into values'500'"
  if [[ $? -ne 0 ]]; then
    # Enviar notificación de que ha fallado coconut db & raspberry pi
  fi
fi
