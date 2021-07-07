# Image optimization bash script

This script optimizes the images quality and size. It's a wrapper around other tools and optimization services that simplifies the process.

The idea for this script is taken from [VirtuBox / img-optimize](https://github.com/VirtuBox/img-optimize). The script, however, is built from the ground up based on my personal needs and views.

## Installation:

1\) [Full installation](https://github.com/rashkopetrov/img-optimize/blob/master/README-INSTALLATION.md)

Install the image optimization script and all requriements on your machine.

2\) [Using a docker image](https://github.com/rashkopetrov/img-optimize/blob/master/README-DOCKER.md)

Use the image optimization script with docker image. No need to install any dependencies.

## Usage

```
username@pc# optimize --help
Optimize v0.21.06.24 Copyright (c) 2021, Rashko Petrov

Usage: optimize [OPTIONS].... [PATH]
Optimize/Compress images quality and size.

Options:

           --jpg                        Optimize the jpg images.
           --jpg-to-webp                Convert the jpg images in webp but keeps the original files.
           --jpg-to-avif                Convert the jpg images in avif but keeps the original files.
           --jpg-optimization-lvl <ol>  Overrides the global optimization level.

           --png                        Optimize all png images.
           --png-to-webp                Convert the png images in webp but keeps the original files.
           --png-to-avif                Convert the png images in avif but keeps the original files.
           --png-optimization-lvl <ol>  Overrides the global optimization level.

           --cmin [+|-]<n>              File's status was last changed n minutes ago.
  -q,      --quiet                      Run optimization quietly.
  -s,      --strip-markers              Strip metadata when optimizing jpg/png images.
  -o <ol>, --optimization-lvl <ol>      Optimization level (0-7) [default: 2].
  -a,      --all                        Optimize and convert all jpg/png images to webp/avif.
  -p,      --path <images path>         Define images path [default: current directory].
  -v,      --version                    Print version information and quit.
  -u,      --check-for-update           Check for updates.

Examples:
  optimize              Prints the help text
  optimize --png --jpg  Optimizes all png and jpg in current durectory

```

## Credits

-   This script was inspired by [VirtuBox / img-optimize](https://github.com/VirtuBox/img-optimize)
-   WebP conversion script was inspired by this [DigitalOcean Community Tutorial](https://www.digitalocean.com/community/tutorials/how-to-create-and-serve-webp-images-to-speed-up-your-website)
-   Tutorial about webp conversion available on [jesuisadmin.fr](https://jesuisadmin.fr/convertir-vos-images-en-webp-nginx/) (in french)
