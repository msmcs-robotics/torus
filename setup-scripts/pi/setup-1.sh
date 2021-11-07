#!/bin/bash
mkdir ${HOME}/torus-setup-logs
logfile=${HOME}/torus-setup-logs/newhost.log
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

echo -e "\n\n"
ip a s | grep eth0
echo -e "\n\n"

if [ $nodetype = "m" ]; then
    echo "master..."
elif [ $nodetype = "w" ]; then
    echo "worker..."
else
    clear
    echo -e "$menu"
    exit
fi

echo "Changing hostname and restarting..."


if [ $1 = "w" ]; then
    echo "worker${nodeid}" > /etc/hostname
elif [ $1 = "m" ]; then
    echo "master" > /etc/hostname
fi

echo "rebooting..."
sudo reboot now