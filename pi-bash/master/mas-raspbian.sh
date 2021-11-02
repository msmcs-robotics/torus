#!/bin/bash

read -p "What is the new name of the master node?> " masname

# Networking
echo $masname > /etc/hostname
echo "nameserver 1.1.1.1" > /etvc/resolv.conf
echo "nameserver 1.0.0.1" >> /etc/resolv.conf

sudo apt update && sudo apt upgrade

sudo apt install nmap git docker iperf3 speedtest-cli

chmod -R 777 *

bash mas-ab.sh
bash mas-kb.sh
bash mas-kf.sh
bash mas-smb.sh

sudo reboot now