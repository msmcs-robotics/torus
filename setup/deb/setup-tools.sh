#!/bin/bash

# Ideal to setup static IP adresses

# assuming using Nvidia GPU, or no GPU at all
# kub install ref - https://adamtheautomator.com/install-kubernetes-ubuntu/


# if making a worker node, change the following variable to the output of the join command from the master server.

MASTERCMD="kubeadm join exnet:port --token tokenhere \
         --discovery-token-ca-cert-hash hashhere
         "
SERVICENODE="Cluster maintainer's laptop ip adress"






read -p "Use Hardware acceleration? (y/n)> " USEGPU
read -p "Is this a Master node? (y/n)> " MASTERNODE # y/n - depends on if have nvidia gpu supporting cuda 10.2 or 11.1
if [[ ! $MASTERNODE =~ ^[Yy]$ ]]
then
	read -p "What will the Pod network be? (Ex: 10.244.0.0/16)> " PODNET
	read -p "What is the ip of the Master Node?> " APISERVERIP
	#PODNET="10.244.0.0/16"
	#APISERVERIP="10.0.0.200"	# master-node ip
else
	echo -e "\n\n\n Enter the command to join the network from the Master Node: "
	echo "Make a new line, type EOF, and press enter when done..."
	echo "\nEnter Below >"
	MASTERJOIN=$MASTERCMD

fi
read -p "What will this hosts's ID (hostname) be ?> " HOSTID
sudo hostnamectl set-hostname $HOSTID


										#networking
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 1.0.0.1" >> /etc/resolv.conf


sudo apt update
sudo apt install snapd

sudo apt install -fy python3 python3-pip golang sshd openssh-server ufw docker git htop

sudo ufw allow 22
sudo ufw allow 222
ufw allow from $MASTERNODE
ufw allow from $SERVICENODE
sudo ufw enable

										#Nvidia Drivers

# Nvidia Driver
sudo apt-key adv --fetch-keys  http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
sudo bash -c 'echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list'
sudo bash -c 'echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda_learn.list'
sudo apt update
sudo apt install libnvidia-extra-470
sudo apt install nvidia-drivers-470

# Cuda Toolkit
sudo apt install cuda-drivers-470
sudo apt install cuda-11-1

# PyTorch Cuda with Pip
if [[ ! $USEGPU =~ ^[Yy]$ ]]
then
	pip3 install torch==1.8.2+cu111 torchvision==0.9.2+cu111 torchaudio==0.8.2 -f https://download.pytorch.org/whl/lts/1.8/torch_lts.html

else
	pip3 install torch==1.8.2+cpu torchvision==0.9.2+cpu torchaudio==0.8.2 -f https://download.pytorch.org/whl/lts/1.8/torch_lts.html
fi

pip3 install matplotlib numpy 

sudo apt update
sudo apt-get install -y apt-transport-https curl
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt update
sudo apt-get install kubeadm

if [[ ! $MASTERNODE =~ ^[Yy]$ ]]
then
	# install kub for a master
	sudo apt-get install kubeadm kubelet 
	touch kubinfo.txt
	touch kubnet.txt
	kubeadm version && kubelet --version && kubectl version >> kubinfo.txt
	kubeadm init --pod-network-cidr=$PODNET --apiserver-advertise-address=$APISERVERIP >> kubnet.txt
	echo -e "\n\n\n\n\n Copy the following command to join the network: \n\n\n\n\n"
	cat kubnet.txt | grep kubeadm
	echo -e "Have you copied the command?"
	echo "If not, look in kubnet.txt"
	echo -e "Press 'c' to continue...\n\n"
	while : ; do
	read -n 1 k <&1
	if [[ $k = c ]] ; then
	printf "Ok then, moving on....."
	break
	fi
	done
	mkdir -p $HOME/.kube
	sudo cp -i /etc/Kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config

else
	# install kub for a worker
	eval " $MASTERJOIN"
fi