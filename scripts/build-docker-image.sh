#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
cd $( dirname "$SCRIPT_DIR" )

NC="\033[0m" # No Colo
RED="\033[0;31m"

[ -z "$(command -v docker)" ] && {
    printf "${RED}Error: docker isn't installed${NC}\n"
    printf "${RED}https://www.docker.com/get-started${NC}\n"
    exit 1
}

read -p "Enter account name in Docker Hub https://hub.docker.com/: " ACCOUNT_NAME
while [[ -z "$ACCOUNT_NAME" ]]; do
    printf "\n${RED}The account name cannot be blank.${NC}\n"
    read -p "Enter account name: " ACCOUNT_NAME
done

# read -p "Enter the image tag: " IMAGE_TAG
# while [[ -z "$IMAGE_TAG" ]]; do
#     printf "\n${RED}The image tag cannot be blank.${NC}\n"
#     read -p "Enter image tag: " IMAGE_TAG
# done

docker build \
    --squash \
    -f ./docker/Dockerfile \
    # -t $ACCOUNT_NAME/img-optimize:$IMAGE_TAG \
    -t $ACCOUNT_NAME/img-optimize:latest \
    .

read -p "Would you like to push the images to Docker Hub? [Y/n]: " -n 1 -r PUSH_TO_DOCKER_HUB
printf "\n"

if [[ $PUSH_TO_DOCKER_HUB =~ ^[Yy]$ ]]; then
    # docker push $ACCOUNT_NAME/img-optimize:$IMAGE_TAG
    docker push $ACCOUNT_NAME/img-optimize:latest
fi

exit 1
