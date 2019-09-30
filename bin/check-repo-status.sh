

PROJ_DIR="/proj/"

remote_command(){
	sshpass -p $PASSWD ssh -o 'StrictHostKeyChecking no'  -tt $UNAME@$DEST_IP $@
}

REF_REPO=`cd ${PROJ_DIR}; ls ${PROJ_DIR} | grep $PROJECT || echo Not Found`

COMMAND="ls ${PROJ_DIR} | grep $PROJECT || echo Not Found"
PROD_REPO=`remote_command $COMMAND | awk -F" " '{print $1}'`



PACKET_LOSS=`ping $DEST_IP -c 4 | tail -2 | head -1 | awk -F", " '{print $2}'`

if [ "$PACKET_LOSS" != "0 received" ]; then
	echo $PACKET_LOSS
	echo "Device is alive, we can proceed"
else
	echo "Device is dead, we cannot continue at this point, check if proper one was pointed out."
    exit 1
fi

if [ "$PROD_REPO" = "Not" ];then
	echo "Production repo not found, clonig a new one"
    COMMAND="git clone https://github.com/$USERNAME/$PROJECT.git"
    remote_command $COMMAND
    echo "SInce we deployed newest version now. Exiting the script"
    cd -
    exit 0
else
	echo "Prod repo found"

	COMMAND="cd ${PROJ_DIR}/$PROJECT;echo \`git log --format=format:%H -1\`"

	PRODUCT_SHA=`remote_command $COMMAND | rev | cut -c 2- | rev`
	echo $PRODUCT_SHA

fi

if [ "$REF_REPO" = "Not Found" ];then
	echo "Reference repo not found, clonig a new one"
    git clone https://github.com/$USERNAME/$PROJECT.git
    cd -
else
	cd $PROJ_DIR/$PROJECT
	echo "Reference repo found"
    git pull -r origin master

    cd ${PROJ_DIR}/$PROJECT
	REF_SHA=`git log --format=format:%H -1`
	cd -
fi



if [ "$PRODUCT_SHA" = "$REF_SHA" ];then
	echo "Latest version of Repo is deployed"
    exit 0
else
	echo "Deploying new version of repo"
    COMMAND="cd $PROJ_DIR/$PROJECT;echo \`git pull -r origin master\` > /dev/null; exit"
    remote_command $COMMAND
fi
