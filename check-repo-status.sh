#!/bin/bash

PROJ_DIR="/proj/"
PROD_DIR="/prod/"

#Check if sshpass was intalled
if [ -z `dpkg -s jenkins` ]; then
	echo "ABC"
fi


REF_REPO=`ls ${PROJ_DIR} | grep $PROJECT || echo Not Found`
PROD_REPO=`ssh  ls ${PROD_DIR} | grep $PROJECT || echo Not Found`

PACKET_LOSS=`ping $DEST_IP -c 4 | tail -2 | head -1 | awk -F", " '{print $2}'`

if [ "$PACKET_LOSS" != "0 received" ]; then
	echo $PACKET_LOSS
	echo "Device is alive, we can proceed"
else
	echo "Device is dead, we cannot continue at this point, check if proper one was pointed out."
    exit 1
fi

if [ "$PROD_REPO" = "Not Found" ];then
	echo "Production repo not found, clonig a new one"
    cd ${PROD_DIR}
    git clone https://github.com/Clewler/homeCI.git
    cd -
else
	echo "Prod repo found"
fi

if [ "$REF_REPO" = "Not Found" ];then
	echo "Reference repo not found, clonig a new one"
    cd ${PROJ_DIR}
    git clone https://github.com/Clewler/homeCI.git
    cd -
else
	echo "Reference repo found"
fi


cd ${PROJ_DIR}/$PROJECT
git pull -r
REF_SHA=`git log --format=format:%H -1`

cd -
cd ${PROD_DIR}/$PROJECT
PROD_SHA=`git log --format=format:%H -1`

if [ "$REF_SHA" = "$PROD_SHA" ]; then
	echo "Latest version of Repo is deployed"
    exit 0
else
	echo "Deploying new version of repo"
fi

