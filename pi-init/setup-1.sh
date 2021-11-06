#!/bin/bash

echo -e "\n\n"
ip a s | grep eth0
echo -e "\n\n"

if [[ "$nodetype" = "m" ]];
then
    echo "ok..."
elif [[ "$nodetype" = "w" ]];
then
    echo "ok..."
else
    echo -e "\n\n\n First Argument (node type) should be a 'm' or a 'w' !!!!"
    exit
fi

echo "Changing hostname and restarting..."


if [[ "$1" = "w" ]];
then
    read -p "What is this machine's id? " nodeid
    echo "worker${nodeid}" > /etc/hostname
elif [[ "$1" = "w" ]];
    echo "master" > /etc/hostname
fi

echo "rebooting..."
sudo reboot now