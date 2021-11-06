#!/bin/bash
logfile=/home/$USER/init.log
clear
nodetype=$1
rebnow=$2

menu=$(cat <<EOF
usage:
    setup-2.sh [nodetype] [reboot now] [smbuser] [smbpass] [smbsharename] [smbsharedir] 
First Argument (node type) should be a 'm' or a 'w'
Second Argument (reboot now) should be a 'y' or a 'n'
EOF
)

if [[ "$nodetype" = "m" ]];
then
    echo "ok..."
elif [[ "$nodetype" = "w" ]];
then
    echo "ok..."
else
    clear
    echo -e "$menu"
    exit
fi

if [[ "$rebnow" = "y" ]];
then
    echo "ok..."
elif [[ "$rebnow" = "n" ]];
then
    echo "ok..."
else
    clear
    echo -e "$menu"
    exit
fi


echo "Logging to: $logfile"
echo -e "\n\n"
ip a s | grep eth0
echo -e "\n\n"

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
elif [[ "$nodetype" = "w" ]];
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
    echo -e "\n\n\n First Argument should be a 'm' or a 'w' !!!!"
    exit
fi

if [[ "$rebnow" = "n" ]];
then
    exit
else
    sudo reboot now
fi