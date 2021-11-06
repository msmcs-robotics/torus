#!/bin/bash

read -p "Master of Worker node? (m/w)> " nodetype

if [ $nodetype = "m" ]
then
    read -p "What is the new name of the master node?> " masname
else
    read -p "What will this node's worker ID be? (Ex: a number or string of letters with no spaces)> " nodename
fi


# Networking
echo $nodename > /etc/hostname
echo "nameserver 1.1.1.1" > /etvc/resolv.conf
echo "nameserver 1.0.0.1" >> /etc/resolv.conf

sudo apt update && sudo apt upgrade

sudo apt install nmap git docker iperf3 speedtest-cli python3 python3-pip

chmod -R 777 .


if [ $nodetype = "m" ]
then
    bash master/mas-ab.sh
    bash master/mas-kb.sh
    bash master/mas-kf.sh
    bash master/mas-smb.sh
else
    bash worker/work-ab.sh
    bash worker/work-kb.sh
    bash worker/work-kf.sh
    bash worker/work-smb.sh
fi

sudo reboot now