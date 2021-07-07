# Image optimization bash script

Script that:

-   optimizes the images by reducing their size and quality
-   converts the images to webp and avif

## Installation:

1\) [Full installation](https://github.com/rashkopetrov/img-optimize/blob/master/README-INSTALLATION.md)

Install the image optimization script and all requriements on your machine.

2\) [Using a docker image](https://github.com/rashkopetrov/img-optimize/blob/master/README-DOCKER.md)

The docker image contains all dependencies needed. No need to install any dependencies. You can run the script on any machine that has docker installed on it.

## Usage

```txt
username@pc# optimize --help
Optimize v0.21.06.24 Copyright (c) 2021, Rashko Petrov

Usage: optimize [OPTIONS]...
Optimize/Compress images quality and size.
A wrapper around other tools and optimization services that simplifies the process.

Options:

            --jpg                          Optimize the jpg images
            --jpg-to-webp                  Convert the jpg images in webp
            --jpg-to-avif                  Convert the jpg images in avif
            --jpg-optimization-lvl <int>   Overrides the global optimization level

            --png                          Optimize all png images
            --png-to-webp                  Convert the png images in webp
            --png-to-avif                  Convert the png images in avif
            --png-optimization-lvl <int>   Overrides the global optimization level.

            --tiff                         Optimize all tiff images
            --tiff-to-webp                 Convert the tiff images in webp
            --tiff-optimization-lvl <int>  Overrides the global optimization level.

            --gif                          Optimize all gif images
            --gif-optimization-lvl <int>   Overrides the global optimization level.

            --bmp                          Optimize all bmp images
            --bmp-optimization-lvl <int>   Overrides the global optimization level.

                                           Optimization settings:
  -s,       --strip-markers                Strip metadata when optimizing jpg/png images
  -o <int>, --optimization-lvl <int>       Optimization level (0-7) [default: 2]

                                           WEBP settings:
            --webp-quality-factor <int>    Quality factor (0:small..100:big), [default: 82]
            --webp-lossless-preset <int>   Activates lossless preset with given level in [default: 9]
                                           (0:fast..9:slowest)

                                           AVIF settings (The Next-Gen Compression Codec):
            --avif-compression-level <int> Compression level (0..63), [default: 25]
            --avif-compression-speed <int> Compression speed (0..8), [default: 4]

            --cmin [+|-]<n>                File's status was last changed n minutes ago
            --allow-concurrency            Allow running the script multiple times at the same time for
                                           the same directory
  -a,       --all                          Optimize and convert all images to webp/avif if possible
            --source-dir <string>          Define images path [default: current directory]
  -v,       --version                      Print version information and quit

Examples:
  optimize                                 Prints the help text
  optimize --help                          Prints the help text
  optimize --png --jpg --strip-markers     Optimizes all png and jpg in current directory
  optimize --png --source-dir ./dir/images Optimizes all png in given directory
```

## Example

```
username@pc# optimize -s -a

Optimize v0.21.06.24 Copyright (c) 2021, Rashko Petrov

Optimizing the images...

==> ** Processing: 4k.jpg
Path: ./temp/4k.jpg
Size (kb):
    before: 18306    after: 4483    difference: 13823
    percentage difference: 75

==> ** Processing: 4k.png
Path: ./temp/4k.png
Size (kb):
    before: 47668    after: 34843    difference: 12825
    percentage difference: 26

Converting the images to webp...

==> ** Processing: 4k.jpg
Path: ./temp/4k.jpg
Size (kb):
    before: 4483    after: 3673    difference: 810
    percentage difference: 18

==> ** Processing: 4k.png
Path: ./temp/4k.png
Size (kb):
    before: 34843    after: 3295    difference: 31548
    percentage difference: 90

Converting the images to avif...

==> ** Processing: 4k.jpg
Path: ./temp/4k.jpg
Size (kb):
    before: 4483    after: 2301    difference: 2182
    percentage difference: 48

==> ** Processing: 4k.png
Path: ./temp/4k.png
Size (kb):
    before: 34843    after: 2056    difference: 32787
    percentage difference: 94
```

## Warning

The optimization/conversion process takes a while.

## Credits

-   This script was inspired by [VirtuBox / img-optimize](https://github.com/VirtuBox/img-optimize)
-   WebP conversion script was inspired by this [DigitalOcean Community Tutorial](https://www.digitalocean.com/community/tutorials/how-to-create-and-serve-webp-images-to-speed-up-your-website)
-   Tutorial about webp conversion available on [jesuisadmin.fr](https://jesuisadmin.fr/convertir-vos-images-en-webp-nginx/) (in french)
-   Article about how to build a smaller docker image [https://medium.com/@gdiener/](https://medium.com/@gdiener/how-to-build-a-smaller-docker-image-76779e18d48a)
