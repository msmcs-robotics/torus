#!/bin/bash


read -p "What is the new name of the master node?> " masname

read -p "What will this node's worker ID be? (Ex: a number or string of letters with no spaces)> " nodename


# Networking
echo $nodename > /etc/hostname
echo "nameserver 1.1.1.1" > /etvc/resolv.conf
echo "nameserver 1.0.0.1" >> /etc/resolv.conf

sudo apt update && sudo apt upgrade

sudo apt install nmap git docker iperf3 speedtest-cli

chmod -R 777 *

bash init-ab.sh
bash init-kb.sh
bash init-kf.sh
bash init-smb.sh

sudo reboot now