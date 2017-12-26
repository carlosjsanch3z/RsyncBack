#!/bin/bash

# Comprobar conectividad

ping -q -w 1 -c 1 87.221.173.196 > /dev/null

if [ $? -eq 0 ]; then
  echo "perfect"
else
  echo $?
fi

# Comprobaciones

# Hacer las copias remotas


# Si sale bien hacer el insert

#psql -h <host> -p <port> -U <username> -W <password> <database>
/usr/bin/psql -h 172.22.200.110 -d db_backup -U carlos.sanchez -c "SELECT backup_label from backups where backup_user = 'carlos.sanchez'"
