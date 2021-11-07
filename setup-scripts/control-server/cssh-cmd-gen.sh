#!/bin/bash
echo "Setting up CSSH for mass acceptance of ssh keys..."
read -p "What is the common node user?> " nodeuser
read -p "What port is ssh using on each node?> " sshport
echo "Enter each node address on a new line, to stop, leave line empty."
i=1
out="cssh-cmd.txt"
nodes=()    
while :
do
  read -p "IP of Node $i > " nodeip
  if [ -z "$nodeip" ]; then
    break
  fi
  nodes+=("$nodeip")
  i=$((i+1))
done

echo "cssh -l $nodeuser \\" > $out

for ip in "${nodes[@]}"
do
    echo "$ip \\" >> $out
done
echo " -p $sshport" >> $out
echo "CSSH command saved at: $out"