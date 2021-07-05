#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

if [[ $UID != 0 ]]; then
	echo "Please run this script with sudo:"
	# echo "sudo $0 $*"
	echo "sudo $*"
	exit
fi

apt update

apt -y install \
    curl \
    jpegoptim \
    optipng \
    webp

curl -L -o /usr/local/bin/avif https://github.com/Kagami/go-avif/releases/download/v0.1.0/avif-linux-x64
chmod +x /usr/local/bin/avif
