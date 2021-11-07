#!/bin/bash
clear
echo -e "Setting up Ansible...\n"
# check to see if user would like to copy the contents of an existing file

# create new hosts file and append info to
# check if using the same creds across all nodes
# for node in nodesarray, insert IP into hosts file
#mkdir ${HOME}/torus-setup-logs
#logfile=${HOME}/torus-setup-logs/ans-setup.log
clustename=$1
clusteruser=$2
clusterpass=$3
outdir=$4
if [ -z "$clustename" ]; then
    clear
    echo "Cluster has no name!!!"
    exit
fi
if [ -z "$clusteruser" ]; then
    clear
    echo "Cluster has no user!!!"
    exit
fi
if [ -z "$clusterpass" ]; then
    clear
    echo "Cluster has no password!!!"
    exit
fi
if [ -z "$outdir" ]; then
    clear
    echo "hosts file has no destination!!!"
    exit
fi

###################     HOSTS FILE     ###################
out="${outdir}/hosts"
touch ${out}
echo "[$clustename]" > ${out}
echo -e "Enter each node address on a new line, to stop, leave line empty.\n"
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