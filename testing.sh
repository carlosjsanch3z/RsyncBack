#!/bin/bash

# Custom Messages
A='No se ha podido conectar con la raspberry, comprueba la conexión.'
B='No se ha podido registrar la copia de seguridad con código de error: 500'
C='Existe conexión con raspberry, pero no se ha podido realizar la copia completa'
D='Se ha realizado la copia completa, pero no se ha podido guardar el registro en Coconut'
E='No se ha podido realizar la copia incremental, por que no se ha identificado una copia completa previa valida'
F='Se ha encontrado la última copia completa, pero no se ha podido completar la copia incremental'
G='Se ha realizado la copia incremental correctamente, pero no se ha podido registrar en coconut'

# Vars
remotehosts=() # Se rellena leyendo el fichero hostsfile
hostsfile='hosts/hosts.list'
aliashost='' # Nombre del host
remoteusercloud='' # Usuario de la máquina remota, con el que conectamos
hostip='' # Direccion IP Interna
osdistro='' # Distribucción

currentdate=$(date +%d-%m-%Y)
logpath='logs/'
logfile=${logpath}Backup-${currentdate}.log

recipient='carlosjsanchezortega@gmail.com'
sender='info@charliejsanchez.com'


excludefile='/root/exclude-list.txt' # Fichero que indica los directorios que no deseamos incluir en la copia
coconutaddress='coconut.charliejsanchez.com'
pathaddr='/var/www/html/data/charlie/files/'

# OK
function checkHostFile() {
  if [[ ! -f ${hostsfile} ]]; then
    printf "No estan definidos los hosts en el fichero: ${hostsfile}\n"
    exit 1
  fi
}
# OK
function checkExistLogDay() {
  if [[ ! -e $logfile ]]; then
    touch $logfile
  fi
}
# OK
function getRemoteHost() {
  while IFS= read -r line; do
    remotehosts+=("${line}")
  done < ${hostsfile}
}
# OK
function SetVariables() {
  aliashost=$(cut -d ':' -f1 <<< "$1")
  remoteusercloud=$(cut -d ':' -f2 <<< "$1")
  hostip=$(cut -d ':' -f3 <<< "$1")
  osdistro=$(cut -d ':' -f4 <<< "$1")
}

function CheckLastAction() {
  if [[ $? != 0 ]]; then
    printf "$1" >> $logfile
  else
    printf "OK!" >> $logfile
  fi
}

function SendMailDaily() {
  mail -s "Backups Notification: ${currendate}" $recipient -r $sender < ${logfile}
}

checkHostFile # OK
checkExistLogDay # OK
getRemoteHost # OK
for row in "${remotehosts[@]}"; do
  SetVariables ${row} # OK
done

SendMailDaily


#SetVariables ${hostip}
#ssh root@172.22.200.2 rsync -azhe ssh --exclude-from "${excludefile}" / ${remoteuser}@${coconutaddress}:${pathaddr}${aliashost}/backup
