#!/bin/bash
mkdir ${HOME}/torus-setup-logs
logfile=${HOME}/torus-setup-logs/newhost.log
####################     VARS     ####################
nodetype=$1
nodeid=$2
dbdrive=$3
####################     ERROR CORRECTION     ####################
menu=$(cat <<EOF
Usage:
    sudo setup-1.sh [nodetype] [nodeid]

 GENERAL

    node type       'm' - master
                    'w' - worker

    node id         'id' - only needed for a worker node, and
                           optional, but extremely helpful

 OPTIONAL

    drive           '/dev/{drive}' - option to mount an external drive
                                     for extended storage.
                        This drive, if selected, is where the following will be stored:
                        !!! Service Root Directories: maria-db, mongo-db, docker
                         !! Persistant Volumes: docker-volumes 
                          ! Important Files: k3s deployments, k3s services 
                            Misc Files: scripting logs  
EOF
)
err1="node type not selected..."
err2="node id empty..."
err3="no proper drive from /dev selected..."

if [ -z "$nodetype" ]; then
    clear
    echo "!!! ${err1} !!!\n"
    exit
elif [ $nodetype = "w" ]; then
    if [ -z "$nodeid" ]; then
        clear
        echo "!!! ${err2} !!!\n"
        exit
    fi
fi

if [ -z "${dbdrive}" ]; then
    echo ${dbdrive} | grep --quiet "/dev/"
    if [ $? = 1 ]; then
        clear
        echo "!!! ${err3} !!!\n"
        exit
    fi
fi

if [ $1 = "w" ]; then
    echo "master..."
    echo "worker${nodeid}" > /etc/hostname
elif [ $1 = "m" ]; then
    echo "worker..."
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