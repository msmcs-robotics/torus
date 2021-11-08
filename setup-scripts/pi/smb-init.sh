#!/bin/bash
mkdir ${HOME}/torus-setup-logs
logfile=${HOME}/torus-setup-logs/smb-setup.log
####################     VARS     ####################
smbuser=$1
smbpass=$2
smbsharename=$3
smbsharedir=$4