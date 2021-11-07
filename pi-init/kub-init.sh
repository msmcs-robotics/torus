#!/bin/bash
nodetype=$1

if [[ "$nodetype" = "m" ]];
then
    echo "ok..."
elif [[ "$nodetype" = "w" ]];
then
    # Get Kubernetes Master Node Info
    masip=$2
    mastoken=$3
    echo "ok..."
fi