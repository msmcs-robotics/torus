#!/bin/bash

NAME=$1
NUMBER=$2

if [ -z "$NAME" ]; then
    clear
    echo -e "!!! NO NAME PROVIDED !!!\n"
    exit
fi
if [ -z "$NUMBER" ]; then
    clear
    echo -e "!!! No Number Provided !!!\n"
    exit
fi

mkdir ${NAME}_keys
for ((i=1;i<=NUMBER;i++)); do
ssh-keygen -t ed25519 -C "${NAME}${i}@dev00ps.com" << EOF 
${NAME}_keys/${NAME}${i}


EOF

done
