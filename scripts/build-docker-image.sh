#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
cd $( dirname "$SCRIPT_DIR" )

printText () {
	printf "$1\n"
}

read -p "Enter account name in Docker Hub https://hub.docker.com/: " ACCOUNT_NAME
while [[ -z "$ACCOUNT_NAME" ]]; do
	printText ""
	printText "Account name cannot be blank."
	printText "You can type any name and that's just fine for local use."
	read -p "Enter account name: " ACCOUNT_NAME
done

CURRENT_VERSION=$(cat ./VERSION | xargs)

docker build \
	-f ./docker/Dockerfile \
	-t $ACCOUNT_NAME/img-optimize:$CURRENT_VERSION \
	-t $ACCOUNT_NAME/img-optimize:latest \
	.

read -p "Would you like to push the images to Docker Hub? [Y/n]: " -n 1 -r PUSH_TO_DOCKER_HUB
if [[ $PUSH_TO_DOCKER_HUB =~ ^[Yy]$ ]]; then
	docker push $ACCOUNT_NAME/img-optimize:$CURRENT_VERSION
	docker push $ACCOUNT_NAME/img-optimize:latest
fi

exit 1
