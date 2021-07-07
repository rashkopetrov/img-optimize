[Go Back](https://github.com/rashkopetrov/img-optimize/)

## Prerequisite

-   docker

## Prerequisite installation

**Debian & Debian-based Linux distributions:**

1\) Apt Install

```bash
apt update
apt -y install docker-ce docker-ce-cli containerd.io
```

2\) Install manually

```bash
apt -y install apt-transport-https ca-certificates curl
curl -fsSL https://get.docker.com/ | sh
```

**Test the docker installation**

```bash
docker run hello-world
```

## Usage

The the following script

```bash
docker run -v {image directory}:/workdir {docker image} {script argument}
```

Example:

```bash
docker run \
    -v $(pwd)/images:/workdir \
    rashkopetrovdev/img-optimize:latest \
    --help
```

## Build docker image

You can build your own docker image:

```bash
docker build \
    --squash \
    -f ./docker/Dockerfile \
    -t {docker hub account}/{image name}:{image tag} \
    -t {docker hub account}/{image name}:latest \
    .
```

Example:

```bash
docker build \
    --squash \
    -f ./docker/Dockerfile \
    -t rashkopetrovdev/img-optimize:stretch-slim-0.21.06.24 \
    -t rashkopetrovdev/img-optimize:latest \
    .
```

## Push the local docker image to docker hub

Push your image to the docker hub repository

```bash
git push {docker hub account}/{image name}:{image tag}
git push {docker hub account}/{image name}:latest
```

Example:

```bash
git push rashkopetrovdev/img-optimize:stretch-slim-0.21.06.24
git push rashkopetrovdev/img-optimize:latest
```

### Create alias to simplify the process

```bash
echo "alias optimize='docker run -v \$(pwd):/workdir {docker image} {script argument}'" >> $HOME/.bashrc
source $HOME/.bashrc
```

Example:

```bash
echo "alias optimize='docker run -v \$(pwd):/workdir rashkopetrovdev/img-optimize:latest'" >> $HOME/.bashrc
source $HOME/.bashrc
optimize --help
```
