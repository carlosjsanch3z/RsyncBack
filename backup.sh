#!/bin/bash
# System Backup with Rsync & Tar
# Created on 02-01-2018
# Author: Carlos Jesús Sánchez
# Version 1.0

# Vars
DOW=$(date +%u)
currentdate=$(date +%d-%m-%Y)
hostsfile='hosts/hosts.list'
logpath='logs/'
pkglistname='packages-installed.txt'
recipient='carlosjsanchezortega@gmail.com'
sender='info@charliejsanchez.com'
coconutaddress='coconut.charliejsanchez.com'
dbaddress='172.22.200.110'
dbname='db_backup'
dbuser='carlos.sanchez'
insert='insert into backups values ('
pathaddr='/var/www/html/data/charlie/files/'
remotehosts=()
aliashost=''
remoteusercloud=''
hostip=''
floatip=''
osdistro=''
excludefile=''
FullTargetDir=''
IncrTargetDir=''
CriticalTargetDir=''
logfile=${logpath}Backup-${currentdate}.log

# Custom Messages
okey='... OKEY\n'
failed='... FAILED\n'
A='GPG - Directorio root encriptado del host:'
B='Coconut - Registro copia del host:'
C='Backup - Respaldo completo realizado: '
D='Backup - Respaldo incremental realizado: '
E='Testing network connectivity from: '

function checkHostFile() {
  if [[ ! -f ${hostsfile} ]]; then
    printf "Analizando el fichero ${hostsfile}${failed}" >> $logfile
    exit 1
  else
    printf "Analizando el fichero ${hostsfile}${okey}" >> $logfile
  fi
}

function checkExistLogDay() {
  if [[ ! -e $logfile ]]; then
    printf "[${currentdate}]\n" >> $logfile
  fi
}

function getRemoteHost() {
  while IFS= read -r line; do
    remotehosts+=("${line}")
  done < ${hostsfile}
}

function SetVariables() {
  aliashost=$(cut -d ':' -f1 <<< "$1")
  remoteusercloud=$(cut -d ':' -f2 <<< "$1")
  hostip=$(cut -d ':' -f3 <<< "$1")
  osdistro=$(cut -d ':' -f4 <<< "$1")
  floatip=$(cut -d ':' -f5 <<< "$1")
  excludefile="/${remoteusercloud}/${aliashost}"
}

function CheckLastAction() {
  if [[ $? != 0 ]]; then
    printf "$1 $2 ${failed}" >> $logfile
  else
    printf "$1 $2 ${okey}" >> $logfile
  fi
}

function SendMailDaily() {
  mail -s "Backups Notification: ${currendate}" $recipient -r $sender < ${logfile}
}

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

function encryptDir() {
	ssh root@${coconutaddress} "cd ${pathaddr}${aliashost}/$1/ && tar -zcf $2.tar.gz $2/"
	ssh root@${coconutaddress} "cd ${pathaddr}${aliashost}/$1/ && gpg --encrypt --recipient coconutkey $2.tar.gz && rm -rf $2.tar.gz && rm -rf $2"
	ssh root@${coconutaddress} "cd ${pathaddr}${aliashost}/ && tar -zcf $1.tar.gz $1/"
	ssh root@${coconutaddress} "cd ${pathaddr}${aliashost}/ && rm -rf $1"
	# Restore tar command: tar zxf file.tar.gz
	# decrypt : gpg -d -o file.tar.gz file.tar.gz.gpg
}

function AddRegisterCoconut() {
  psql -h ${dbaddress} -d ${dbname} -U ${dbuser} -c "${insert}'${dbuser}','${floatip}','$1','$2 bytes');"
}

function GetSizeInfo() {
   bytes=$(ssh root@${coconutaddress} "wc -c $1$2/$3 | cut -d ' ' -f1")
}

function CheckHostRemote() {
  ping -c 1 $1
  CheckLastAction ${E} $1
}

function Full() {
  ssh ${remoteusercloud}@${hostip} "rsync -azvhe ssh --exclude-from "${excludefile}" / ${remoteusercloud}@${coconutaddress}:${pathaddr}${aliashost}/FullCopy-${currentdate}"
  FullTargetDir=FullCopy-${currentdate}
  CriticalTargetDir='root'
  encryptDir ${FullTargetDir} ${CriticalTargetDir}
  GetSizeInfo ${pathaddr} ${aliashost} ${FullTargetDir}.tar.gz
  AddRegisterCoconut ${FullTargetDir} ${bytes}
}

function Incr() {
  ssh ${remoteusercloud}@${hostip} "rsync -azvhe ssh --exclude-from "${excludefile}" / ${remoteusercloud}@${coconutaddress}:${pathaddr}${aliashost}/backup/"
  IncrTargetDir=IncrCopy-${currentdate}
  CriticalTargetDir='root'
  encryptDir ${IncrTargetDir} ${CriticalTargetDir}
  GetSizeInfo ${pathaddr} ${aliashost} ${IncrTargetDir}.tar.gz
  AddRegisterCoconut ${IncrTargetDir} ${bytes}
}

function makeBackup() {
    getRemoteHost
    for row in "${remotehosts[@]}"; do
      SetVariables ${row}
      GetPkgsList
      if [[ $1 = 'full' ]]; then
        Full
      elif [[ $1 = 'incr' ]]; then
        Incr
      fi
    done
}

function PP() {
  checkExistLogDay
  CheckHostRemote ${coconutaddress}
  CheckHostRemote ${dbaddress}
  checkHostFile
  if [[ $DOW -eq 4 ]]; then
    makeBackup incr
  elif [[ $DOW -ne 4 ]]; then
    makeBackup full
  fi
  SendMailDaily
}

PP
