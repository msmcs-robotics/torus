#!/bin/bash
# setup matrix binary 
mkdir ${HOME}/torus-setup-logs
logfile=${HOME}/torus-setup-logs/notification-setup.log
####################     VARS     ####################
nodetype=$1
if [ $nodetype = "m" ]; then
    name="master"
if [ $nodetype = "w" ]; then
    name="worker"
    nodeid=$(hostname | cut -c 7-)
fi