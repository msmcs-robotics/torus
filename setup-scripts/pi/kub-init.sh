#!/bin/bash

mkdir ${HOME}/torus-setup-logs
logfile=${HOME}/torus-setup-logs/k3s-init.log

####################     ARGUMENTS     ####################
nodetype=$1
master_ip=$2
master_token=$3
save_token="/home/$USER/k3s-server-token.txt"
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
####################     SETUP     ####################
if [ $nodetype = "m" ]; then
    echo "ok..."
    curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 2>&1 | tee $logfile
    echo -e "\n\n\n\n\n\n"
    sudo cat /var/lib/rancher/k3s/server/node-token 2>&1 | tee $logfile
    sudo cat /var/lib/rancher/k3s/server/node-token > $save_token
    echo "token saved in $save_token..."
    ####################     INSTALL HELM     ####################
    #export HELM_VERSION=v3.0.2
    #export HELM_INSTALL_DIR=/usr/local/bin
    #wget https://get.helm.sh/helm-$HELM_VERSION-linux-arm64.tar.gz
    #tar xvzf helm-$HELM_VERSION-linux-arm64.tar.gz
    #sudo mv linux-arm64/helm $HELM_INSTALL_DIR/helm
    #rm -rf linux-arm64 && rm helm-$HELM_VERSION-linux-arm64.tar.gz
    ####################     HELM REPOS     ####################
    #helm repo add stable https://kubernetes-charts.storage.googleapis.com/
    #helm repo add bitnami https://charts.bitnami.com/bitnami

elif [ $nodetype = "w" ]; then
    # Get Kubernetes Master Node Info
    k3s_server="https://${master_ip}:6443"
    k3s_token=$master_token
    curl -sfL https://get.k3s.io | K3S_URL=$k3s_server K3S_TOKEN=$k3s_token sh - 2>&1 | tee $logfile
    echo "ok..."
fi
