#!/bin/bash
logfile=/home/$USER/init.log
clear

echo "Logging to: $logfile"
echo -e "\n\n"
ip a s | grep eth0
echo -e "\n\n"
read -p "Master or Worker node? (m/w)> " nodetype

if [ $nodetype = "m" ]
then
    read -p "What is the new name of the master node?> " masname
    echo $masname > /etc/hostname
else
    read -p "What will this node's worker ID be? (Ex: a number or string of letters with no spaces)> " nodename
    echo $nodename > /etc/hostname
fi

# Networking
ip a s | grep eth0 >> $logfile
echo -e "\n\n------------------------------\n\n" >> $logfile
echo "nameserver 1.1.1.1" > /etvc/resolv.conf
echo "nameserver 1.0.0.1" >> /etc/resolv.conf

echo "Getting things up to date (update & upgrade)..."
sudo apt update && sudo apt upgrade >> $logfile
echo -e "\n\n------------------------------\n\n" >> $logfile
echo "Installing 7 packages..."
sudo apt install nmap git docker iperf3 speedtest-cli python3 python3-pip >> $logfile
echo -e "\n\n------------------------------\n\n" >> $logfile
chmod -R 777 .


if [[ "$nodetype" = "m" ]];
then
    echo "Setting up ansible..."
    bash master/mas-ab.sh
    echo "Setting up kubernetes..."
    bash master/mas-kb.sh
    echo "Setting up kubeflow..."
    bash master/mas-kf.sh
    echo "Setting up smb..."
    bash master/mas-smb.sh
else if [[ "$nodetype" = "w" ]];
then
    echo "Setting up ansible..."
    bash worker/work-ab.sh
    echo "Setting up kubernetes..."
    bash worker/work-kb.sh
    echo "Setting up kubeflow..."
    bash worker/work-kf.sh
    echo "Setting up smb..."
    bash worker/work-smb.sh
else
    exit
fi

read -p "Setup done, would you like to reboot now? (y/n)> " rebnow
if [[ "$rebnow" = "n" ]];
then
    exit
else
    sudo reboot now
fi