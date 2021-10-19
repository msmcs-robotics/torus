#!/bin/bash

# Ideal to setup static IP adresses

# assuming using Nvidia GPU, or no GPU at all
# kub install ref - https://adamtheautomator.com/install-kubernetes-ubuntu/


# if making a worker node, change the following variable to the output of the join command from the master server.

MASTERCMD="kubeadm join exnet:port --token tokenhere \
         --discovery-token-ca-cert-hash hashhere
         "
SERVICENODE="Cluster maintainer's laptop ip adress"





read -p "What is the normal user on this computer?> " archuser
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


sudo pacman -Sy
sudo pacman -S devtools base-devel python3 python3-pip golang sshd openssh-server ufw docker git htop yay

#yay
cd /opt
sudo git clone https://aur.archlinux.org/yay-git.git
sudo chmod -R 777 yay-git/
cd yay-git
makepkg -si
cd /opt


sudo ufw allow 22
sudo ufw allow 222
ufw allow from $MASTERNODE
ufw allow from $SERVICENODE
sudo ufw enable

										#Nvidia Drivers

# Nvidia Driver
wget https://us.download.nvidia.com/XFree86/Linux-x86_64/470.74/NVIDIA-Linux-x86_64-470.74.run
chmod +x NVIDIA-Linux-x86_64-470.74.run
echo "In a separate terminal, cd to this directory and run: ./NVIDIA-Linux-x86_64-470.74.run"

if [[ ! $USEGPU =~ ^[Yy]$ ]]
then
	# Cuda Toolkit
	yay install cuda-11.1
	# PyTorch Cuda with Pip
	pip3 install torch==1.8.2+cu111 torchvision==0.9.2+cu111 torchaudio==0.8.2 -f https://download.pytorch.org/whl/lts/1.8/torch_lts.html

else
	pip3 install torch==1.8.2+cpu torchvision==0.9.2+cpu torchaudio==0.8.2 -f https://download.pytorch.org/whl/lts/1.8/torch_lts.html
fi

pip3 install matplotlib numpy 


#add user to docker group
sudo usermod -a -G docker $archuser

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
