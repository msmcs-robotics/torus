#!/bin/bash
logfile=/home/$USER/init.log
clear
####################     Variables & Some Error Correction    ####################
nodetype=$1
rebnow=$2

smbuser=$3
smbsharename=$4
smbsharedir=$5

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

if [ $nodetype = "m" ]; then
    echo "ok..."
elif [ $nodetype = "w" ]; then
    # Get Kubernetes Master Node Info
    read -p "What is the IP address of the master node?> " masip
    read -p "What is the api token provided by the master node?> " mastoken
    echo "ok..."
else
    clear
    echo -e "$menu"
    exit
fi

if [ $rebnow = "y" ]; then
    echo "ok..."
elif [ $rebnow = "n" ]; then
    echo "ok..."
else
    clear
    echo -e "$menu"
    exit
fi


echo "Logging output to: $logfile"
echo -e "\n\n"
ip a s | grep eth0
echo -e "\n\n"

####################     Networking     ####################
ip a s | grep eth0 >> $logfile
echo -e "\n\n------------------------------\n\n" >> $logfile
echo "nameserver 1.1.1.1" > /etvc/resolv.conf
echo "nameserver 1.0.0.1" >> /etc/resolv.conf

echo "Getting things up to date (update & upgrade)..."
sudo apt update && sudo apt upgrade >> $logfile
echo -e "\n\n------------------------------\n\n" >> $logfile
echo "Installing packages..."
sudo apt install nmap git docker iperf3 speedtest-cli python3 python3-pip >> $logfile
echo -e "\n\n------------------------------\n\n" >> $logfile
chmod -R 777 .

####################     Firewall Setup     ####################
#echo "Setting up firewall..."
#sudo apt install ufw >> $logfile
#kubernetes-ports-and-port-ranges=
#sudo ufw allow 21,22,222,80,139,443,445,9418/tcp
#sudo ufw allow 21,22,222,80,139,443,445,9418/udp
#sudo ufw allow ${kubernetes-ports-and-port-ranges}/tcp
#sudo ufw allow ${kubernetes-ports-and-port-ranges}/udp

####################     Pass NodeType Args to More Scripts     ####################
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