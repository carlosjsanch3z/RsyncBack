#!/bin/bash

# Inicio

ping -q -w 1 -c 1 87.221.173.196 > /dev/null

if [ $? -eq 0 ]; then
  echo "perfect"
else
  echo $?
fi

# Comprobaciones



#
