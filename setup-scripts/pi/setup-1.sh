#!/bin/bash
mkdir ${HOME}/torus-setup-logs
logfile=${HOME}/torus-setup-logs/newhost.log
####################     VARS     ####################
nodetype=$1
nodeid=$2
menu=$(cat <<EOF
Usage:
    sudo setup-1.sh [nodetype] [nodeid]

 GENERAL

    node type       'm' - master
                    'w' - worker

    node id         'id' - only needed for a worker node, and
                           optional, but extremely helpful
EOF
)

if [ $nodetype = "m" ]; then
    echo "master..."
elif [ $nodetype = "w" ]; then
    echo "worker..."
else
    clear
    echo -e "$menu"
    exit
fi


if [ $1 = "w" ]; then
    echo "worker${nodeid}" > /etc/hostname
elif [ $1 = "m" ]; then
    echo "master" > /etc/hostname
    echo "127.0.0.1         $(hostname)" | tee -a /etc/hosts
fi
####################     NETWORKING     ####################
ip a s | grep eth0 2>&1 | tee -a $logfile
echo -e "\n\n------------------------------\n\n" 2>&1 | tee -a $logfile
echo -e "nameserver 1.1.1.1\nnameserver 1.0.0.1" > /etc/resolv.conf

####################     BASE PACKAGES     ####################
echo "Getting things up to date (update & upgrade)..."
sudo apt update -y 2>&1 | tee -a $logfile
sudo apt upgrade -y  2>&1 | tee -a $logfile
echo -e "\n\n------------------------------\n\n" 2>&1 | tee -a $logfile
echo "Installing packages..."
sudo apt install -fy nmap git iperf3 speedtest-cli python3 python3-pip \
        python3-dev gcc g++ build-essential snap snapd 2>&1 | tee -a $logfile
sudo curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh 2>&1 | tee -a $logfile
sudo usermod -aG docker $USER
echo -e "\n\n------------------------------\n\n" 2>&1 | tee -a $logfile
chmod -R 777 .

echo "rebooting..."
sudo reboot now