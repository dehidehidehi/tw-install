#!/bin/bash

# Source env config variables.
. src/hardcoded_variables.txt

IMAGE_NAME=tw-install

docker stop $CONTAINER	&>	/dev/null
docker rm $CONTAINER	&>	/dev/null

# Counter-intuively, the arguments to the `taskd` command come after specifying the
# docker image param.
docker run \
-p "$PORT:53589" \
-e "TW_USERNAME=$TW_USERNAME" \
-e "TW_ORGANISATION=$TW_ORGANISATION" \
--name $CONTAINER \
--entrypoint 'taskd' \
-d \
$IMAGE_NAME \
'server'

# define the hostname -> for docker this is the container id
# IP=$(sudo docker ps -aqf "name=tw-instance")
# alternatively it simply could be localhost
IP=localhost
echo "IP=$IP"
USER_UUID=$(docker exec -it $CONTAINER ls $TASKDDATA/orgs/"$TW_ORGANISATION"/users)
echo "USER_UUID=$USER_UUID"

docker cp $CONTAINER:/root/.task/ca.cert.pem ~/.task			> /dev/null	|| $SHELL
docker cp $CONTAINER:/root/.task/first.cert.pem ~/.task			> /dev/null	|| $SHELL
docker cp $CONTAINER:/root/.task/first.key.pem ~/.task			> /dev/null	|| $SHELL

yes | task config taskd.certificate	--	~/.task/first.cert.pem	> /dev/null	|| $SHELL
yes | task config taskd.key		--	~/.task/first.key.pem	> /dev/null	|| $SHELL
yes | task config taskd.ca		--	~/.task/ca.cert.pem	> /dev/null	|| $SHELL
yes | task config taskd.server 		--	"$IP":"$PORT"		> /dev/null	|| $SHELL

yes | task config taskd.credentials	-- 	"$TW_ORGANISATION"/"$TW_USERNAME"/"$USER_UUID"	> /dev/null

yes | task config taskd.trust		--	ignore hostname
yes | task sync init > /dev/null || $SHELL

