#!/bin/bash
# Send mail to USER


A='No se ha podido conectar con la raspberry, comprueba la conexión.'
B='No se ha podido registrar la copia de seguridad con código de error: 500'
C='Existe conexión con raspberry, pero no se ha podido realizar la copia completa'
D='Se ha realizado la copia completa, pero no se ha podido guardar el registro en Coconut'
E='No se ha podido realizar la copia incremental, por que no se ha identificado una copia completa previa valida'
F='Se ha encontrado la última copia completa, pero no se ha podido completar la copia incremental'
G='Se ha realizado la copia incremental correctamente, pero no se ha podido registrar en coconut'


function sendmail(message) {
  #statements
}
