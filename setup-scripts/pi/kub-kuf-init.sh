#!/bin/bash
goal="setup"
mkdir ${HOME}/torus-${goal}-logs
logfile=${HOME}/torus-${goal}-logs/k8s-init.log
joincluster=${HOME}/torus-${goal}-logs/k8s-join.log
kb_web=${HOME}/torus-${goal}-logs/kb_web_access.log
####################     VARS     ####################
nodetype=$1
master_ip=$2
master_token=$3
####################     ERROR CORRECTION     ####################
menu=$(cat <<EOF
Usage:
    sudo setup-1.sh [nodetype] [nodeid]
GENERAL

    node type       'm' - master
                    'w' - worker

MASTER
    No further arguments needed

WORKER

    master node ip     'ip' - the ip address of the master node

    master token       'token' - the token of the master node's 
                                     kubernetes API
EOF
)
err1="No nodetype was given"
err2="No master IP was given"
err3="No master token was given"
if [ -z "$nodetype" ]; then
    clear
    echo "!!! ${err1} !!!"
    echo -e
    exit
elif [ $nodetype = "w" ]; then
    if [ -z "$master_ip" ]; then
        clear
        echo "!!! ${err2} !!!"
        echo -e
        exit
    fi
     if [ -z "$master_token" ]; then
        clear
        echo "!!! ${err3} !!!"
        echo -e
        exit
    fi
fi
####################     SETUP     ####################
sudo snap install core 2>&1 | tee $logfile
sudo snap install microk8s --classic 2>&1 | tee $logfile
echo -e "\n\n------------------------------\n\n" 2>&1 | tee $logfile
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
if [ $nodetype = "m" ]; then
    echo "master..."
    echo -e "\n\n\n Follow these instructions to join a node to the cluster... \n\n"
    microk8s add-node 2>&1 | tee $joincluster
    cat $joincluster >> $logfile
    echo -e "\n\n Intructions saved at $joincluster \n\n"
    echo -e "\n\n Microk8s installed, check out 'microk8s kubectl' for more... \n\n"
    echo -e "\n\n------------------------------\n\n" 2>&1 | tee $logfile
    echo -e "\n\n\n Follow these instructions to access kubeflow dashboard... \n\n"
    microk8s enable kubeflow 2>&1 | tee $kb_web
    cat $kb_web >> $logfile
    echo -e "\n\n Intructions saved at $kb_web \n\n"
    echo -e "\n\n------------------------------\n\n" 2>&1 | tee $logfile

elif [ $nodetype = "w" ]; then
    # Get Kubernetes Master Node Info
    microk8s join ${master_ip}:25000/${master_token}
    echo "ok..."
fi
