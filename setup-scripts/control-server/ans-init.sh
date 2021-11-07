#!/bin/bash
clear
echo -e "Setting up Ansible...\n\n"
# check to see if user would like to copy the contents of an existing file

# create new hosts file and append info to
# check if using the same creds across all nodes
# for node in nodesarray, insert IP into hosts file
mkdir ${HOME}/torus-setup-logs
logfile=${HOME}/torus-setup-logs/ans-setup.log
clustename=$1
clusteruser=$2
clusterpass=$3
outdir=$4

###################     HOSTS FILE     ###################
out="${outdir}/hosts"
touch ${out}
echo "[$clustename]" > ${out}
echo "Enter each node address on a new line, to stop, leave line empty."
i=1
while :
do
  read -p "IP of Node $i > " ip
  if [ -z "$ip" ]; then
    break
  fi
  echo -e "server$i ansible_host=${ip}" >> ${out}
  i=$((i+1))
done
echo "[$clustename:vars]" >> ${out}
echo "ansible_user=$clusteruser" >> ${out}
echo "ansible_password=$clusterpass" >> ${out}
echo "Done!!!"
echo "New hosts file saved at: '${out}'"