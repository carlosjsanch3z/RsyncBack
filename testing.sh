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
excludefile=''

currentdate=$(date +%d-%m-%Y)
logpath='logs/'
logfile=${logpath}Backup-${currentdate}.log

recipient='carlosjsanchezortega@gmail.com'
sender='info@charliejsanchez.com'

pkglistname='packages-installed.txt'

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
  excludefile="/${remoteusercloud}/${aliashost}"
}
# MEJORAR
function CheckLastAction() {
  if [[ $? != 0 ]]; then
    printf "$1" >> $logfile
  else
    printf "OK!" >> $logfile
  fi
}
# OK
function SendMailDaily() {
  mail -s "Backups Notification: ${currendate}" $recipient -r $sender < ${logfile}
}

# OK

function GetPkgsList() {
  case ${osdistro,,} in
    debian|ubuntu)
      getpkgs='dpkg --get-selections | grep -v deinstall'
      ;;
    centos)
      getpkgs='yum list installed'
      ;;
  esac
  ssh ${remoteusercloud}@${hostip} "$getpkgs > $pkglistname"
}

function Full() {
  # rsync - Conectarse por ssh desde la instancia
  rsync -avzhe ssh --exclude-from "${excludefile}" / ${remoteusercloud}@${coconutaddress}:${pathaddr}${aliashost}/FullCopy-${currendate}
  # Cifrar los ficheros que yo vea necesarios - Conectarse a raspy
  # tar compress - Conectarse a la raspy
  #ssh root@192.168.1.150 'cd /var/www/html/data/charlie/files/mickey/ && tar -zcvf FullCopy-2018-01-10.tar.gz backup/'
  # coconut
}


function makeBackup() {
    getRemoteHost # OK
    for row in "${remotehosts[@]}"; do
      SetVariables ${row}
      GetPkgsList # OK
      if [[ $1 = 'full' ]]; then
        Full

      elif [[ $1 = 'incr' ]]; then
        echo "OKEY xD"
      fi
    done
}

function PP() {
  checkHostFile # OK
  checkExistLogDay # OK
  if [[ $DOW -eq 4 ]]; then
    makeBackup full
  elif [[ $DOW -ne 4 ]]; then
    makeBackup incr
  fi
}

PP
#tar -zcf /var/www/html/data/charlie/files/mickey/FullCopy-2018-01-10 /var/www/html/data/charlie/files/mickey/backup
# tar uncompress
#tar -zxf FullCopy-2018.tar.gz --transform s/prueba/yeah/
# Decidir directorios de Centos
