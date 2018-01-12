#!/bin/bash

currentdate=$(date +%d-%m-%Y)
logfile=Backup-${currentdate}.log
okey='... OKEY\n'
failed='... FAILED\n'
A='El fichero se ha creado correctamente '

function CheckLastAction() {
  if [[ $? != 0 ]]; then
    printf "$1 $2 ${failed}" >> $logfile
  else
    printf "$1 $2 ${okey}" >> $logfile
  fi
}

function checkExistLogDay() {
  if [[ ! -f $logfile ]]; then
    host='Mickey'
    printf "[${currentdate}]\n" >> $logfile
    CheckLastAction $host $A
  fi
}

checkExistLogDay
