#!/bin/bash

read -p "What is the directory to the setup-scripts? (EX: /opt/torus/pi-setup-scripts)> " setupdir
read -p "What will this node's worker ID be? (Ex: a number or string of letters with no spaces)> " nodename
cd ${setupdir}/workers

# Networking
echo $nodename > /etc/hostname
echo "nameserver 1.1.1.1" > /etvc/resolv.conf
echo "nameserver 1.0.0.1" >> /etc/resolv.conf

sudo apt update && sudo apt upgrade

sudo apt install nmap git docker iperf3 speedtest-cli

chmod -R 777 {setupdir}/workers

bash ${setupdir}/workers/init-kb.sh
bash ${setupdir}/workers/init-kf.sh
bash ${setupdir}/workers/init-smb.sh
bash ${setupdir}/workers/init-

sudo reboot now