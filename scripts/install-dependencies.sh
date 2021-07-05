#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

apt-get update

apt-get -y install \
    curl \
    jpegoptim \
    optipng \
    webp

curl -L -o /usr/local/bin/avif https://github.com/Kagami/go-avif/releases/download/v0.1.0/avif-linux-x64
chmod +x /usr/local/bin/avif
