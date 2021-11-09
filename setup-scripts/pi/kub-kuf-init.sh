#!/bin/bash
goal="setup"
mkdir ${HOME}/torus-${goal}-logs
logfile=${HOME}/torus-${goal}-logs/k3s-init.log
tokenfile=${HOME}/torus-${goal}-logs/master-token.log
####################     VARS     ####################
nodetype=$1
master_ip=$2
master_token=$3
numnodes=$4
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
before_reboot(){
    sudo iptables -F 
    sudo update-alternatives --set iptables /usr/sbin/iptables-legacy 2>&1 >> $logfile
    sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy 2>&1 >> $logfile
    sudo sed -i 's/rootwait/& group_enable=cpuset cgroup_enable=memory cgroup_memory=1/' /boot/cmdline.txt 
    echo -e "\n\n------------------------------\n\n" 2>&1 >> $logfile
    sudo reboot now
}

after_reboot(){
    if [ $nodetype = "m" ]; then
        echo "master..."

        ##########      K3S     ##########
        
        sudo curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -s - 2>&1 >> $logfile
        echo -e "\n\n------------------------------\n\n" 2>&1 >> $logfile
        echo -e "\n\n\n Use this token to join the cluster... \n\n"
        sudo cat /var/lib/rancher/k3s/server/node-token 2>&1 >> $tokenfile >> $logfile
        echo -e "\n\n------------------------------\n\n" 2>&1 >> $logfile

        ##########      KubeFlow    ##########
        export PIPELINE_VERSION=1.7.1
        kubectl apply -k "github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=$PIPELINE_VERSION" 2>&1 >> $logfile
        echo -e "\n\n------------------------------\n\n" 2>&1 >> $logfile
        kubectl wait --for condition=established --timeout=60s crd/applications.app.k8s.io 2>&1 >> $logfile
        echo -e "\n\n------------------------------\n\n" 2>&1 >> $logfile
        kubectl apply -k "github.com/kubeflow/pipelines/manifests/kustomize/env/platform-agnostic-pns?ref=$PIPELINE_VERSION" 2>&1 >> $logfile
        echo -e "\n\n------------------------------\n\n" 2>&1 >> $logfile
        #kubectl port-forward -n kubeflow svc/ml-pipeline-ui 8080:80

    elif [ $nodetype = "w" ]; then
        echo "ok..."
        sudo curl -sfL https://get.k3s.io | K3S_TOKEN="$master_token" K3S_URL="https://$master_ip:6443" K3S_NODE_NAME="$(hostname)" sh - 2>&1 >> $logfile
        echo -e "\n\n------------------------------\n\n" 2>&1 >> $logfile
    fi
}

echo "failure-domain=42" > /var/snap/microk8s/current/args/ha-conf
microk8s.stop
microk8s.start

if [ -f /var/run/rebooting-for-updates ]; then
    after_reboot
    sudo rm -rf /var/run/rebooting-for-updates
    update-rc.d myupdate remove
else
    before_reboot
    sudo touch /var/run/rebooting-for-updates
    update-rc.d myupdate defaults
    sudo reboot
fi
