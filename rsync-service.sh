#!/bin/bash
# System Backup with Rsync & Tar
# Created on 02-01-2018
# Author: Carlos Jesús Sánchez
# Version 1.0

# DECLARATION BLOCK - VARIOUS

dow=$(/bin/date +%u) # Dia de la semana, Formato: 1-7
date=$(/bin/date +%d-%m-%Y) # Fecha actual
keyname='backup_rsa.pub'# Ruta a la clave pública
hostsfile='hosts/hosts.list' # Fichero que define los hosts e información
pkglistname='packages-list.txt' # Fichero temporal que almacena los paquetes instalados del Sys
excludedir='excludes' # Directorio que guarda los directorios a excluir de cada host
to='mail/mail.list' # A quien avisar en caso de exito/error
sender='info@charliejsanchez.com' # correo remitente

# Empty Vars
remotehosts=() # Se rellena leyendo el fichero hostsfile
aliashost='' # Nombre del host
excludefile='' # Fichero que indica los directorios que no deseamos incluir en la copia
remoteuser='' # Usuario de la máquina remota, con el que conectamos
hostip='' # Direccion IP Interna
osdistro='' # Distribucción


# STORAGE INFO
staddr='192.168.1.138'
stuser='root'
stsource='/'
stdir='/var/www/html/data/charlie/files/'$aliashost
stdest=$stuser@$staddr:$stdir

# APP DATABASE CREDENTIALS
dbname='db_backup'
dbaddr='172.22.200.110'
dbuser='carlos.sanchez'

# Functions

function GetPkgsList() {
  case ${os,,} in
    debian|ubuntu)
      getpkgs='dpkg --get-selections | grep -v deinstall'
      ;;
    centos)
      getpkgs='yum list installed'
      ;;
  esac
  ssh ${user}@${hostip} "$getpkgs > $pkglistname"
}

function getRemoteHost() {
  while IFS= read -r line; do
    remotehosts+=("${line}")
  done < ${hostsfile}
}

function checkHosts() {
  if [[ ! -f ${hostsfile} ]]; then
    printf "No estan definidos los hosts en el fichero: ${hostsfile}\n"
    exit 1
  fi
}

function SetVariables() {
  aliashost=$(cut -d ':' -f1 <<< "$1")
  excludefile="${excludedir}/${aliashost}"
  remoteuser=$(cut -d ':' -f2 <<< "$1")
  hostip=$(cut -d ':' -f3 <<< "$1")
  osdistro=$(cut -d ':' -f4 <<< "$1")
}

function SendError() {
  while IFS= read line; do
    mail -s "Error: $1" $linea -r ${sender} < ${LOGFILE}
  done < ${to}
}

function CheckLastAction() {
  if [[ $? != 0 ]]; then
    echo "ERROR";
  else
    echo "OK!"
  fi
}

function makeBackup() {
  getRemoteHost
  for host in "${remotehosts[@]}"; do
    SetVariables ${host}
    if [[ $1 = 'full' ]]; then
      # rsync - Conectarse por ssh desde la instancia
      rsync -avzhe ssh --exclude-from 'exclude-list.txt' / root@coconut.charliejsanchez.com:/var/www/html/data/charlie/files/mickey/backup

      # Cifrar los ficheros que yo vea necesarios - Conectarse a raspy

      # tar compress - Conectarse a la raspy
      ssh root@192.168.1.150 'cd /var/www/html/data/charlie/files/mickey/ && tar -zcvf FullCopy-2018-01-10.tar.gz backup/'
      tar -zcf /var/www/html/data/charlie/files/mickey/FullCopy-2018-01-10 /var/www/html/data/charlie/files/mickey/backup
      # tar uncompress
      tar -zxf FullCopy-2018.tar.gz --transform s/prueba/yeah/

      # coconut
    elif [[ $1 = 'incr' ]]; then
      # rsync - Conectarse por ssh desde la instancia
      rsync -avzhe ssh --exclude-from 'exclude-list.txt' / root@coconut.charliejsanchez.com:/var/www/html/data/charlie/files/mickey/FullCopy-2018-01-09
    fi
  done
}


function PP() {
  checkHosts
  if [[ $DOW -eq 3 ]]; then
    makeBackup full
  elif [[ $DOW -ne 3 ]]; then
    makeBackup incr
  fi
}
