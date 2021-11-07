#!/bin/bash
clear
echo -e "\n\n\nSetting up Ansible..."
# check to see if user would like to copy the contents of an existing file

# create new hosts file and append info to
# check if using the same creds across all nodes
# for node in nodesarray, insert IP into hosts file
mkdir ${HOME}/torus-setup-logs
logfile=${HOME}/torus-setup-logs/ans-setup.log
nodeuser=$1
nodepass=$2
newhostsfile=$3

out="lol.txt"
echo "Enter ip addresses of all nodes in the cluster, to stop, leave line empty."
while :
do
  read -p "IP of Node $i > " ip
  echo -e "${ip}" >> ${out}
  if [ -z "$ip" ]; then
    break
  fi
  i=$((i+1))
done
