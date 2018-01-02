#!/bin/bash
# System Backup with Rsync about Debian Stretch
# Created on 02-01-2018
# Author: Carlos Jesús Sánchez
# Version 1.0


# DECLARATION BLOCK - VARIOUS
dow=$(/bin/date +%u)
date=$(/bin/date +%d-%m-%Y)
keyname='id_rsa.pub'
hostname=$(/bin/hostname)

# DECLARATION BLOCK - APP DATABASE
dbname='db_backup'
dbaddr='172.22.200.110'
dbuser='carlos.sanchez'

# DECLARATION BLOCK - STORAGE
staddr='192.168.1.138'
stuser='root'
stsource='/'
stdir='/var/www/html/data/charlie/files/'$hostname
stdest=$stuser@$staddr:$stdir

# Functions

function SendNotification(code) {
  /bin/bash /usr/local/sbin/backup-notification.sh $code
}

# Check connectivity with the destination
ping -q -w 1 -c 1 $staddr > /dev/null

if [ $? -eq 0 ]; then
  if [[ $DOW -eq 7 ]]; then
    # List of Packages
    /usr/bin/dpkg --get-selections | /bin/grep -v deinstall > ~/installed-packages.txt
    # Create New Directory
    /usr/
    # Make the full backup
    /usr/bin/rsync -avzhe ssh --exclude-from 'exclude-list.txt' $stsource $stdest/'FullCopy-'$date
    if [[ $? -ne 0 ]]; then
      SendNotification(C)
    fi
    # Add record of the full copy in coconut
    /usr/bin/psql -h $LOCALIP -d $DB -U $USER -c "INSERT backups into values'200'"
    if [[ $? -ne 0 ]]; then
      SendNotification(D)
    fi
  else
    # Identify the last complete copy
    latest=$(/bin/ls -ltrp | /bin/grep 'FullCopy-*' | /usr/bin/tail -1 | /usr/bin/cut -d ' ' -f 10)
    if [[ $? -eq 0 ]]; then
      # Make the incremental backup
      /usr/bin/rsync -avzhe ssh --exclude-from 'exclude-list.txt' $stsource $latest
      if [[ $? -ne 0 ]]; then
        SendNotification(F)
      fi
      # Add record of the incremental copy in coconut
      /usr/bin/psql -h $LOCALIP -d $DB -U $USER -c "INSERT backups into values'200'"
      if [[ $? -ne 0 ]]; then
        SendNotification(G)
      fi
    else
      SendNotification(E)
    fi
  fi
else
  # if the connection fails
  SendNotification(A)
  # Add record with error code in Coconut
  /usr/bin/psql -h $LOCALIP -d $DB -U $USER -c "INSERT backups into values'500'"
  if [[ $? -ne 0 ]]; then
    SendNotification(B)
  fi
fi
