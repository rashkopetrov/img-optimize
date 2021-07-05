[Go Back](https://github.com/rashkopetrov/img-optimize/)

## Prerequisite

-   jpegoptim for jpg optimization
-   optipng for png optimization
-   cwebp for WebP conversion
-   go-avif for Avif conversion
-   libaom-dev required by go-avif

## Prerequisite Installation

**Debian & Debian-based Linux distributions:**

1\) Install manually

```bash
apt install jpegoptim optipng webp -y

curl -L -o /usr/local/bin/avif https://github.com/Kagami/go-avif/releases/download/v0.1.0/avif-linux-x64
chmod +x /usr/local/bin/avif
```

2\) Install via a script - run the script as sudo user

```bash
./scripts/install-dependencies.sh
```

## Script installation

### Clone the repository

```bash
git clone https://github.com/rashkopetrov/img-optimize.git $HOME/.img-optimize
```

### Install the script

**Method 1** : Add an alias in .bashrc

With this method img-optimize can only be used by the current user

```bash
echo "alias img-optimize=$HOME/.img-optimize/optimize.sh" >> $HOME/.bashrc
source $HOME/.bashrc
```

**Method 2** : Copy the script itself to ~/.local/bin and remove the `.img-optimize` directory

With this method img-optimize can only be used by the current user. Only the script file is kept on your machine and not the entire GitHub repository.

```bash
cp $HOME/.img-optimize/scripts/optimize.sh $HOME/.local/bin/img-optimize
chmod +x $HOME/.local/bin/img-optimize
rm -rf $HOME/.img-optimize
```

**Method 3** : Add an alias to the script in /usr/local/bin

With this method img-optimize can be used by all users

```bash
sudo ln -s $HOME/.img-optimize/optimize.sh /usr/local/bin/img-optimize
sudo chmod +x /usr/local/bin/img-optimize
```

## Usage

Simple type `img-optimize` in your terminal.
