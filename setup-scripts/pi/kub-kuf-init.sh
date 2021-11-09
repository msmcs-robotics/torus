#!/bin/bash
goal="setup"
mkdir ${HOME}/torus-${goal}-logs
logfile=${HOME}/torus-${goal}-logs/k8s-init.log
k8stokens=${HOME}/torus-${goal}-logs/k8s-tokens.log
kb_web=${HOME}/torus-${goal}-logs/kb_web_access.log
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
    sudo snap install core 2>&1 >> $logfile
    sudo snap install microk8s --classic --channel=1.21 2>&1 >> $logfile
    echo -e "\n\n------------------------------\n\n" 2>&1 >> $logfile
    sudo usermod -a -G microk8s $USER
    sudo chown -f -R $USER ~/.kube
}

after_reboot(){
    if [ $nodetype = "m" ]; then
        echo "master..."
        echo -e "\n\n\n Follow these instructions to join a node to the cluster... \n\n"
        i=0
        microk8s enable dns dashboard storage
        microk8s enable dns dashboard storage 2>&1 >> $logfile
        echo -e "\n\n------------------------------\n\n" 2>&1 >> $logfile
        microk8s enable kubeflow 2>&1 >> $logfile
        echo -e "\n\n------------------------------\n\n" 2>&1 >> $logfile
        for i in {1..$numnodes}; do
            microk8s add-node 2>&1 >> $k8stokens
            cat $k8stokens >> $logfile
            echo -e "\n-----------------\n" >> $logfile
        done
        echo -e "\n\n Intructions and tokens saved at $k8stokens \n\n"
        echo -e "\n\n Microk8s installed...\n Tokens logged...\n check out 'microk8s kubectl' for more... \n\n"
        echo -e "\n\n------------------------------\n\n" 2>&1 >> $logfile
        echo -e "\n\n\n Follow these instructions to access kubeflow dashboard... \n\n"
        microk8s enable kubeflow 2>&1 >> $kb_web
        cat $kb_web >> $logfile
        echo -e "\n\n Intructions saved at $kb_web \n\n"
        echo -e "\n\n------------------------------\n\n" 2>&1 >> $logfile

    elif [ $nodetype = "w" ]; then
        # Get Kubernetes Master Node Info
        echo "Run the following on the Master Server: "
        echo "''"
        microk8s join ${master_ip}:25000/${master_token}
        echo "ok..."
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
