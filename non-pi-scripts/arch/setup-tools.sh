#!/bin/bash

# Ideal to setup static IP adresses

# assuming using Nvidia GPU, or no GPU at all

# kub install ref - https://dnaeon.github.io/install-and-configure-k8s-on-arch-linux/
		
		# or

#  https://gist.github.com/StephenSorriaux/fa07afa57c931c84d1886b08c704acfe


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
sudo pacman -S devtools base-devel python python-pip sshd openssh ufw docker git htop ebtables ethtool wget unzip ethtool ebtables socat conntrack-tools cfssl

sudo systemctl enable sshd
systemctl enable docker && systemctl restart docker

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
	pip install torch==1.8.2+cu111 torchvision==0.9.2+cu111 torchaudio==0.8.2 -f https://download.pytorch.org/whl/lts/1.8/torch_lts.html

else
	pip install torch==1.8.2+cpu torchvision==0.9.2+cpu torchaudio==0.8.2 -f https://download.pytorch.org/whl/lts/1.8/torch_lts.html
fi

pip install matplotlib numpy 


#add user to docker group
sudo usermod -a -G docker $archuser
									
									#Kubernetes

export CNI_VERSION="v0.6.0"
mkdir -p /opt/cni/bin
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-amd64-${CNI_VERSION}.tgz" | tar -C /opt/cni/bin -xz


export CRICTL_VERSION="v1.11.1"
mkdir -p /opt/bin
curl -L "https://github.com/kubernetes-incubator/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | tar -C /opt/bin -xz

RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"

mkdir -p /opt/bin
cd /opt/bin
curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
chmod +x {kubeadm,kubelet,kubectl}

curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/kubelet.service" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service
mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/10-kubeadm.conf" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl enable kubelet && systemctl start kubelet



if [[ ! $MASTERNODE =~ ^[Yy]$ ]]
then
	# install kub for a master
	kubeadm init --pod-network-cidr=$PODNET
	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config
	
	kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
	kubectl taint nodes --all node-role.kubernetes.io/master-
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/baremetal/service-nodeport.yaml
	
done

cd "${OLD_PWD}"
echo "> Done"

else
	# install kub for a worker
	eval " $MASTERJOIN"
