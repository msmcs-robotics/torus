#!/bin/bash
mkdir ${HOME}/torus-setup-logs
logfile=${HOME}/torus-setup-logs/main.log
touch $logfile
clear
####################     INFORMATION     ####################
nodetype=$1
rebnow=$2

smbuser=$3
smbpass=$4
smbsharename=$5
smbsharedir=$6
####################     ERROR CORRECTION     ####################
menu=$(cat <<EOF
Usage:
    setup-2.sh [nodetype] [reboot now] [smbuser] [smbpass] [smbsharename] [smbsharedir] 

 GENERAL

    node type       'm' - master
                    'w' - worker

    reboot now      'y' - reboot imediately after scripts finish
                    'n' - do not reboot
 
 SMB

    smbuser         'name' - A new user for managing smb connections in the cluster.

    smbpass         'passwd' - The password for the smb user
    
    smbsharename    'name' - The name of the share that the node will use to transfer 
                    data within the cluster

    smbsharedir     'fullpath' - The directory that the share will use to store data

EOF
)
err1="node type incorrect"
err2="reboot option incorrect"
err3="smb variable empty"

if [ $nodetype = "m" ]; then
    echo "master..."
elif [ $nodetype = "w" ]; then
    # Get Kubernetes Master Node Info
    echo "worker..."
    read -p "What is the IP address of the master node?> " masip
    read -p "What is the api token provided by the master node?> " mastoken
else
    clear
    echo -e "\n\n\n!!! ${err1} !!!\n\n\n"
    echo -e "$menu"
    exit
fi

if [ $rebnow = "y" ]; then
    echo "will reboot..."
elif [ $rebnow = "n" ]; then
    echo "not rebooting..."
else
    clear
    echo -e "\n\n\n!!! ${err2} !!!\n\n\n"
    echo -e "$menu"
    exit
fi

if [ -z $smbuser ] || [ -z $smbpass ] || [ -z $smbsharename ] || [ -z $smbsharedir ]; then
    clear
    echo -e "\n\n\n!!! ${err3} !!!\n\n\n"
    echo -e "$menu"
    exit
else
    echo "smb ok..."
fi


echo "Logging output to: $logfile"

####################     NETWORKING     ####################
ip a s | grep eth0 2>&1 | tee $logfile
echo -e "\n\n------------------------------\n\n" 2>&1 | tee $logfile
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 1.0.0.1" >> /etc/resolv.conf

echo "Getting things up to date (update & upgrade)..."
sudo apt update -y 2>&1 | tee $logfile
sudo apt upgrade -y  2>&1 | tee $logfile
echo -e "\n\n------------------------------\n\n" 2>&1 | tee $logfile
echo "Installing packages..."
sudo apt install -fy nmap git docker iperf3 speedtest-cli python3 python3-pip 2>&1 | tee $logfile
echo -e "\n\n------------------------------\n\n" 2>&1 | tee $logfile
chmod -R 777 .

####################     FIREWALL SETUP     ####################
#echo "Setting up firewall..."
#sudo apt install ufw 2>&1 | tee $logfile
#kubernetes-ports-and-port-ranges=
#sudo ufw allow 21,22,222,80,139,443,445,9418/tcp
#sudo ufw allow 21,22,222,80,139,443,445,9418/udp
#sudo ufw allow ${kubernetes-ports-and-port-ranges}/tcp
#sudo ufw allow ${kubernetes-ports-and-port-ranges}/udp

####################     PASS TO OTHER SCRIPTS     ####################
if [ $nodetype = "m" ]; then
    #echo "Setting up matrix notifications..."
    #bash notifications.sh
    echo -e "\n\n\nSetting up kubernetes...\n\n\n"
    bash kub-init.sh m
    echo -e "\n\n\nSetting up kubeflow...\n\n\n"
    bash kuf-init.sh

elif [ $nodetype = "w" ]; then

    echo -e "\n\n\nSetting up kubernetes...\n\n\n"
    bash kub-init.sh w $masip $mastoken
fi

echo -e "\n\n\nSetting up smb...\n\n\n"
bash smb-init.sh $smbuser $smbsharename $smbsharedir

if [ $rebnow = "n" ]; then
    exit
else
    sudo reboot now
fi