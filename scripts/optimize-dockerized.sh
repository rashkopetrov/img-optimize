#!/bin/bash

echo "Work In Progres. Not implemented yet."
exit 1

# ==========================================================================
	# Variables
# ==========================================================================

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
SCRIPT_FILENAME=`basename "$0"`

NC="\033[0m" # No Colo
RED="\033[0;31m"

# ==========================================================================
	# Helpers/Utils
# ==========================================================================
newLine () {
	printf "\n"
}

printText () {
	printf "$1\n"
}

printTextSep () {
	printf "---------------------\n"
}

printAlert () {
	printf "${RED}$1${NC}\n"
}

printAlertSep () {
	printf "${RED}---------------------${NC}\n"
}

# ==========================================================================
	# Implementation
# ==========================================================================

[ -z "$(command -v docker)" ] && {
	printAlert "Error: docker isn't installed"
	printAlert "https://www.docker.com/get-started"
	exit 1
}

[ -z "$DOCKER_IMAGE" ] && {
	printAlert "Error: the docker image is not defined."
	printAlert "Please define the docker image before calling the optimize script."
	newLine
	printAlert "Example:"
	printAlert "    DOCKER_IMAGE=rashkopetrovdev/img-optimize:latest bash -c '$SCRIPT_DIR/$SCRIPT_FILENAME'"
	exit 1
}
