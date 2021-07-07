#!/bin/bash
# ###########################################
# Title           :Img Optimize
# Description     :This script optimizes the images quality and size.
# Author          :Rashko Petrov
# Website         :https://rashkopetrov.dev
# GitHub          :https://github.com/rashkopetrov/img-optimize
# DockerHub       :https://hub.docker.com/r/rashkopetrovdev/img-optimize
# Date            :2021-06-24
# Version         :0.21.06.24 - 2021-06-24
# Usage           :bash optimize.sh
# BashVersion     :Tested with 4.4.12
# License         :MIT License
#                 :Copyright (c) 2021 Rashko Petrov
# ###########################################
#            “Clean code always
#     looks like it was written
#        by someone who cares.“
#
#           -- Michael Feathers
#############################################

# ===========================================
    # Variables
# ===========================================

# majorVersion.year.month.day
VERSION="0.21.06.24"

SOURCE_DIR="$PWD"
FIND_ARGS=""
PNG_OPTIMIZATION_ARGS="-quiet"
TIFF_OPTIMIZATION_ARGS="-quiet"
BMP_OPTIMIZATION_ARGS="-quiet"
GIF_OPTIMIZATION_ARGS="-quiet"
JPG_OPTIMIZATION_ARGS="-p -o --all-progressive --quiet"

CWEBP_ARGS="-quiet"
CWEBP_LOSSLESS_PRESET="9"
CWEBP_QUALITY_FACTOR="82"

AVIF_ARGS=""
AVIF_COMPRESSION_LEVEL="25"
AVIF_COMPRESSION_SPEED="4"

NC="\033[0m" # No Colo
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"

# ===========================================
    # Helpers/Utils
# ===========================================

printCopyright () {
    printText text "Optimize v$VERSION Copyright (c) 2021, Rashko Petrov"
    printText nl
}

printHelp () {
    printText text "Usage: optimize [OPTIONS]..."
    printText text "Optimize/Compress images quality and size."
    printText text "A wrapper around other tools and optimization services that simplifies the process."
    printText nl
    printText text "Options:"
    printText nl
    printText text "            --jpg                          Optimize the jpg images"
    printText text "            --jpg-to-webp                  Convert the jpg images in webp"
    printText text "            --jpg-to-avif                  Convert the jpg images in avif"
    printText text "            --jpg-optimization-lvl <int>   Overrides the global optimization level"
    printText nl
    printText text "            --png                          Optimize all png images"
    printText text "            --png-to-webp                  Convert the png images in webp"
    printText text "            --png-to-avif                  Convert the png images in avif"
    printText text "            --png-optimization-lvl <int>   Overrides the global optimization level."
    printText nl
    printText text "            --tiff                         Optimize all tiff images"
    printText text "            --tiff-to-webp                 Convert the tiff images in webp"
    printText text "            --tiff-optimization-lvl <int>  Overrides the global optimization level."
    printText nl
    printText text "            --gif                          Optimize all gif images"
    printText text "            --gif-optimization-lvl <int>   Overrides the global optimization level."
    printText nl
    printText text "            --bmp                          Optimize all bmp images"
    printText text "            --bmp-optimization-lvl <int>   Overrides the global optimization level."
    printText nl
    printText text "                                           Optimization settings:"
    printText text "  -s,       --strip-markers                Strip metadata when optimizing jpg/png images"
    printText text "  -o <int>, --optimization-lvl <int>       Optimization level (0-7) [default: 2]"
    printText nl
    printText text "                                           WEBP settings:"
    printText text "            --webp-quality-factor <int>    Quality factor (0:small..100:big), [default: 82]"
    printText text "            --webp-lossless-preset <int>   Activates lossless preset with given level in [default: 9]"
    printText text "                                           (0:fast..9:slowest)"
    printText nl
    printText text "                                           AVIF settings (The Next-Gen Compression Codec):"
    printText text "            --avif-compression-level <int> Compression level (0..63), [default: 25]"
    printText text "            --avif-compression-speed <int> Compression speed (0..8), [default: 4]"
    printText nl
    printText text "            --cmin [+|-]<n>                File's status was last changed n minutes ago"
    printText text "            --allow-concurrency            Allow running the script multiple times at the same time for"
    printText text "                                           the same directory"
    printText text "  -a,       --all                          Optimize and convert all images to webp/avif if possible"
    printText text "            --source-dir <string>          Define images path [default: current directory]"
    printText text "  -v,       --version                      Print version information and quit"
    printText nl
    printText text "Examples:"
    printText text "  optimize                                 Prints the help text"
    printText text "  optimize --help                          Prints the help text"
    printText text "  optimize --png --jpg --strip-markers     Optimizes all png and jpg in current directory"
    printText text "  optimize --png --source-dir ./dir/images Optimizes all png in given directory"
    return 0
}

printText () {
    case "$1" in
        nl)
            printf "\n"
        ;;

        text)
            printf "$2\n"
        ;;

        textList)
            printf "${YELLOW}==>${NC} $2\n"
        ;;

        textSep)
            printf "${NC}---------------------${NC}\n"
        ;;

        alertText)
            printf "${RED}$2${NC}\n"
        ;;

        alertSep)
            printf "${RED}---------------------${NC}\n"
        ;;

        noticeText)
            printf "${YELLOW}$2${NC}\n"
        ;;

        noticeSep)
            printf "${YELLOW}---------------------${NC}\n"
        ;;

        successText)
            printf "${GREEN}$2${NC}\n"
        ;;

        successSep)
            printf "${GREEN}---------------------${NC}\n"
        ;;
    *)
    esac
}

commandRequired () {
    [ -z "$(command -v $1)" ] && {
        printText alertText "Error: $1 isn't installed"
        exit 1
    }
}

# ===========================================
    # Implementation
# ===========================================

run () {
    if [ "${#}" = "0" ]; then
        printText alertText "optimize: arguments missing"
        printText alertText "Try 'optimize --help' for more information."
        printText nl
        exit 1
    fi

    parseArgs "$@"
    cd $SOURCE_DIR || exit 1

    if [[ ! "$ALL_CONCURRENCY" = "y" ]]; then
        preventMultiExecutionOnSameDirectory
    fi

    optimizeImages
    convertImagesToWebp
    convertImagesToAvif

    preventMultiExecutionOnSameDirectoryReset

    printText nl
    printText successText "Image optimization performed successfully !"
    printText nl
}

preventMultiExecutionOnSameDirectory () {
    LOCK_FILE=$(echo -n "$SOURCE_DIR" | md5sum | cut -d" " -f1)

    if [ -f "/tmp/$LOCK_FILE" ]; then
        printText nl
        printText alertText "The script is currently processing the given path:"
        printText alertText "    $SOURCE_DIR"
        printText nl

        printText noticeText "The script creates file that indicates it's running."
        printText noticeText "This is necessary in order to prevent multiple executions in the same directory."
        printText noticeText "In case the script crashes or is manually interrupted, you can reset the script status."
        printText noticeText "Would you like to reset the script status and proceed with current execution?"
        read -p "=> [Yy] to confirm: " -n 1 -r USER_CONFIRMATION

        if [[ $USER_CONFIRMATION =~ ^[Yy]$ ]]; then
            printText nl
            printText noticeText "The script status has been reset."
            printText nl
        fi

        if [[ ! $USER_CONFIRMATION =~ ^[Yy]$ ]]; then
            printText nl
            exit 1
        fi
    fi

    touch "/tmp/$LOCK_FILE"
}

preventMultiExecutionOnSameDirectoryReset () {
    if [[ ! -z "$LOCK_FILE" ]]; then
        rm "/tmp/$LOCK_FILE"
    fi
}

parseArgs () {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --jpg)
                JPG_OPTIMIZATION="y"
            ;;

            --jpg-to-webp)
                JPG_TO_WEBP="y"
            ;;

            --jpg-to-avif)
                JPG_TO_AVIF="y"
            ;;

            --jpg-optimization-lvl)
                if [ -n "$2" ] && [ "$2" -ge 0 ] && [ "$2" -le 7 ]; then
                    JPG_OPTIMIZATION_QUALITY=$(bc <<< "(8 - $2) * 14")
                    if [ "$JPG_OPTIMIZATION_QUALITY" -ge 100 ]; then
                        JPG_OPTIMIZATION_QUALITY=100
                    fi

                    JPG_OPTIMIZATION_ARGS+=" -m$JPG_OPTIMIZATION_QUALITY"
                    JPG_OPTIMIZATION_LVL_OVERRIDE="y"
                    shift
                fi
            ;;

            --png)
                PNG_OPTIMIZATION="y"
            ;;

            --png-to-webp)
                PNG_TO_WEBP="y"
            ;;

            --png-to-avif)
                PNG_TO_AVIF="y"
            ;;

            --png-optimization-lvl)
                if [ -n "$2" ] && [ "$2" -ge 0 ] && [ "$2" -le 7 ]; then
                    PNG_OPTIMIZATION_ARGS+=" -o$2"
                    PNG_OPTIMIZATION_LVL_OVERRIDE="y"
                    shift
                fi
            ;;

            --tiff)
                TIFF_OPTIMIZATION="y"
            ;;

            --tiff-to-webp)
                TIFF_TO_WEBP="y"
            ;;

            --tiff-optimization-lvl)
                if [ -n "$2" ] && [ "$2" -ge 0 ] && [ "$2" -le 7 ]; then
                    TIFF_OPTIMIZATION_ARGS+=" -o$2"
                    TIFF_OPTIMIZATION_LVL_OVERRIDE="y"
                    shift
                fi
            ;;

            --gif)
                GIF_OPTIMIZATION="y"
            ;;

            --gif-optimization-lvl)
                if [ -n "$2" ] && [ "$2" -ge 0 ] && [ "$2" -le 7 ]; then
                    GIF_OPTIMIZATION_ARGS+=" -o$2"
                    GIF_OPTIMIZATION_LVL_OVERRIDE="y"
                    shift
                fi
            ;;

            --bmp)
                BMP_OPTIMIZATION="y"
            ;;

            --bmp-optimization-lvl)
                if [ -n "$2" ] && [ "$2" -ge 0 ] && [ "$2" -le 7 ]; then
                    BMP_OPTIMIZATION_ARGS+=" -o$2"
                    BMP_OPTIMIZATION_LVL_OVERRIDE="y"
                    shift
                fi
            ;;

            --cmin)
                if [ -n "$2" ]; then
                    FIND_ARGS+=" -cmin \"$2\""
                    shift
                fi
            ;;

            -s | --strip-markers)
                PNG_OPTIMIZATION_ARGS+=" -strip all"
                JPG_OPTIMIZATION_ARGS+=" -s"
            ;;

            -o | --optimization-level)
                if [ -n "$2" ] && [ "$2" -ge 0 ] && [ "$2" -le 7 ]; then
                    OPTIMIZATION_LEVEL="y"

                    if [[ ! $PNG_OPTIMIZATION_LVL_OVERRIDE = 'y' ]]; then
                        PNG_OPTIMIZATION_ARGS+=" -o$2"
                    fi

                    if [[ ! $TIFF_OPTIMIZATION_LVL_OVERRIDE = 'y' ]]; then
                        TIFF_OPTIMIZATION_ARGS+=" -o$2"
                    fi

                    if [[ ! $JPG_OPTIMIZATION_LVL_OVERRIDE = 'y' ]]; then
                        JPG_OPTIMIZATION_QUALITY=$(bc <<< "(8 - $2) * 14")
                        if [ "$JPG_OPTIMIZATION_QUALITY" -ge 100 ]; then
                            JPG_OPTIMIZATION_QUALITY=100
                        fi

                        JPG_OPTIMIZATION_ARGS+=" -m$JPG_OPTIMIZATION_QUALITY"
                    fi
                    shift
                fi
            ;;

            --webp-lossless-preset)
                if [ -n "$2" ]; then
                    CWEBP_LOSSLESS_PRESET="$2"
                    shift
                fi
            ;;

            --webp-quality-factor)
                if [ -n "$2" ]; then
                    CWEBP_QUALITY_FACTOR="$2"
                    shift
                fi
            ;;

            --avif-compression-level)
                if [ -n "$2" ]; then
                    AVIF_COMPRESSION_LEVEL="$2"
                    shift
                fi
            ;;

            --avif-compression-speed)
                if [ -n "$2" ]; then
                    AVIF_COMPRESSION_SPEED="$2"
                    shift
                fi
            ;;

            --allow-concurrency)
                ALL_CONCURRENCY="y"
            ;;

            -a | --all)
                ALL_MANIPULATIONS="y"
            ;;

            --source-dir)
                if [ -n "$2" ]; then
                    SOURCE_DIR="$2"
                    shift
                fi
            ;;

            -h | --help | help)
                printHelp
                exit 1
            ;;

            -v | --version)
                printText text $VERSION
                exit 1
            ;;
        *)

        printText alertText "Error! Unknown option '$1'."
        printHelp
        exit 1
        esac

        shift
    done
}

# Usage: findImages [png|jpg|tiff|gif|bmp]
findImages () {
    if [[ $1 = "png" || $1 = "tiff" || $1 = "gif" || $1 = "bmp" ]]; then
        find . -type f -iname "*.$1" $FIND_ARGS
    fi

    if [[ $1 = "jpg" ]]; then
        find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) $FIND_ARGS
    fi
}

# Usage: optimizeImage [png|jpg|tiff] PATH
optimizeImage () {
    if [[ ! -z "$2" ]]; then
        FILE_NAME=`basename "$2"`
        FILE_DIRECTORY=$( dirname "$2" )
        FILE_MODE=$(stat -c '%a' $2)
        FILE_OWNER_USER_ID=$(stat -c '%g' $2)
        FILE_OWNER_GROUP_ID=$(stat -c '%g' $2)
        FILE_SIZE_BEFORE_KB=$( bc <<< "scale=0; $(wc -c < $2)/1000" )

        printText textList "** Processing: $FILE_NAME"
        printText text "Path: $2"

        { # try
            if [[ $1 = "jpg" ]]; then
                jpegoptim $JPG_OPTIMIZATION_ARGS $2
            fi

            if [[ $1 = "png" ]]; then
                optipng $PNG_OPTIMIZATION_ARGS $2
            fi

            if [[ $1 = "tiff" ]]; then
                optipng $TIFF_OPTIMIZATION_ARGS $2
            fi

            if [[ $1 = "gif" ]]; then
                optipng $TIFF_OPTIMIZATION_ARGS $2
            fi

            if [[ $1 = "bmp" ]]; then
                optipng $TIFF_OPTIMIZATION_ARGS $2
            fi

            FILE_SIZE_AFTER_KB=$( bc <<< "scale=0; $(wc -c < $2)/1000" )
            FILE_SIZE_DIFFERENCE_KB=$( bc <<< "$FILE_SIZE_BEFORE_KB - $FILE_SIZE_AFTER_KB" )

            printText text "Size (kb):"
            printText text "    before: $FILE_SIZE_BEFORE_KB    after: $FILE_SIZE_AFTER_KB    difference: $FILE_SIZE_DIFFERENCE_KB"
            printText nl
        } || { # catch
            printText alertText "Err: something went wrong."
            printText alertText "Check if the image is corrupted somehow:"
            stat $2
            printText nl
        }

        # the new files are owned by root when using docker
        # so we set back the owner and the mode
        chmod $FILE_MODE $2
        chown $FILE_OWNER_USER_ID:$FILE_OWNER_GROUP_ID $2
    fi
}

optimizeImages () {
    if [[ ! $OPTIMIZATION_LEVEL = 'y' ]]; then
        PNG_OPTIMIZATION_ARGS+=" -o2"
        JPG_OPTIMIZATION_ARGS+=" -m82"
        TIFF_OPTIMIZATION_ARGS+=" -o2"
        GIF_OPTIMIZATION_ARGS+=" -o2"
        BMP_OPTIMIZATION_ARGS+=" -o2"
    fi

    if [[ "$ALL_MANIPULATIONS" = "y" || "$JPG_OPTIMIZATION" = "y" || "$PNG_OPTIMIZATION" = "y" || "$TIFF_OPTIMIZATION" = "y" || "$BMP_OPTIMIZATION" = "y" || "$GIF_OPTIMIZATION" = "y" ]]; then
        printText text "Optimizing the images..."
        printText nl
    fi

    if [[ "$ALL_MANIPULATIONS" = "y" || "$JPG_OPTIMIZATION" = "y" ]]; then
        commandRequired "jpegoptim"

        IMAGES=$(findImages jpg)
        for IMAGE in $IMAGES; do
            optimizeImage jpg $IMAGE
        done
    fi

    if [[ "$ALL_MANIPULATIONS" = "y" || "$PNG_OPTIMIZATION" = "y" ]]; then
        commandRequired "optipng"

        IMAGES=$(findImages png)
        for IMAGE in $IMAGES; do
            optimizeImage png $IMAGE
        done
    fi

    if [[ "$ALL_MANIPULATIONS" = "y" || "$TIFF_OPTIMIZATION" = "y" ]]; then
        commandRequired "optipng"

        IMAGES=$(findImages tiff)
        for IMAGE in $IMAGES; do
            optimizeImage tiff $IMAGE
        done
    fi

    if [[ "$ALL_MANIPULATIONS" = "y" || "$BMP_OPTIMIZATION" = "y" ]]; then
        commandRequired "optipng"

        IMAGES=$(findImages bmp)
        for IMAGE in $IMAGES; do
            optimizeImage bmp $IMAGE
        done
    fi

    if [[ "$ALL_MANIPULATIONS" = "y" || "$GIF_OPTIMIZATION" = "y" ]]; then
        commandRequired "optipng"

        IMAGES=$(findImages gif)
        for IMAGE in $IMAGES; do
            optimizeImage gif $IMAGE
        done
    fi
}

# Usage: convertImageToWebp PATH
convertImageToWebp () {
    if [[ ! -z "$1" ]]; then
        FILE_NAME=`basename "$1"`
        FILE_DIRECTORY=$( dirname "$1" )
        FILE_MODE=$(stat -c '%a' $1)
        FILE_OWNER_USER_ID=$(stat -c '%g' $1)
        FILE_OWNER_GROUP_ID=$(stat -c '%g' $1)
        FILE_SIZE_KB=$( bc <<< "scale=0; $(wc -c < $1)/1000" )

        printText textList "** Processing: $FILE_NAME"
        printText text "Path: $1"

        { # try
            [ ! -f $1.webp ] && {
                cwebp $CWEBP_ARGS $1 -o $1.webp || rm -f $1.webp
            }

            FILE_SIZE_WEBP_KB=$( bc <<< "scale=0; $(wc -c < $1.webp)/1000" )
            FILE_SIZE_DIFFERENCE_KB=$( bc <<< "$FILE_SIZE_KB - $FILE_SIZE_WEBP_KB" )

            printText text "Size (kb):"
            printText text "    before: $FILE_SIZE_KB    after: $FILE_SIZE_WEBP_KB    difference: $FILE_SIZE_DIFFERENCE_KB"
            printText nl
        } || { # catch
            printText alertText "Err: something went wrong."
            printText alertText "Check if the image is corrupted somehow:"
            stat $1
            printText nl
        }

        # the new files are owned by root when using docker
        # so we set back the owner and the mode
        chmod $FILE_MODE $1.webp
        chown $FILE_OWNER_USER_ID:$FILE_OWNER_GROUP_ID $1.webp
    fi
}

convertImagesToWebp () {
    CWEBP_ARGS+=" -z $CWEBP_LOSSLESS_PRESET"
    CWEBP_ARGS+=" -q $CWEBP_QUALITY_FACTOR"

    if [[ "$ALL_MANIPULATIONS" = "y" || "$JPG_TO_WEBP" = "y" || "$PNG_TO_WEBP" = "y"  ]]; then
        printText text "Converting the images to webp..."
        commandRequired "cwebp"
        printText nl
    fi

    if [[ "$ALL_MANIPULATIONS" = "y" || "$JPG_TO_WEBP" = "y" ]]; then
        IMAGES=$(findImages jpg)
        for IMAGE in $IMAGES; do
            convertImageToWebp $IMAGE
        done
    fi

    if [[ "$ALL_MANIPULATIONS" = "y" || "$PNG_TO_WEBP" = "y" ]]; then
        IMAGES=$(findImages png)
        for IMAGE in $IMAGES; do
            convertImageToWebp $IMAGE
        done
    fi

    if [[ "$ALL_MANIPULATIONS" = "y" || "$TIFF_TO_WEBP" = "y" ]]; then
        IMAGES=$(findImages tiff)
        for IMAGE in $IMAGES; do
            convertImageToWebp $IMAGE
        done
    fi
}

# Usage: convertImageToAvif PATH
convertImageToAvif () {
    if [[ ! -z "$1" ]]; then
        FILE_NAME=`basename "$1"`
        FILE_DIRECTORY=$( dirname "$1" )
        FILE_MODE=$(stat -c '%a' $1)
        FILE_OWNER_USER_ID=$(stat -c '%g' $1)
        FILE_OWNER_GROUP_ID=$(stat -c '%g' $1)
        FILE_SIZE_KB=$( bc <<< "scale=0; $(wc -c < $1)/1000" )

        printText textList "** Processing: $FILE_NAME"
        printText text "Path: $1"

        { # try
            [ ! -f $1.avif ] && {
                avif $AVIF_ARGS -e $1 -o $1.avif || rm -f $1.avif
            }

            FILE_SIZE_AVIF_KB=$( bc <<< "scale=0; $(wc -c < $1.avif)/1000" )
            FILE_SIZE_DIFFERENCE_KB=$( bc <<< "$FILE_SIZE_KB - $FILE_SIZE_AVIF_KB" )

            printText text "Size (kb):"
            printText text "    before: $FILE_SIZE_KB    after: $FILE_SIZE_AVIF_KB    difference: $FILE_SIZE_DIFFERENCE_KB"
            printText nl
        } || { # catch
            printText alertText "Err: something went wrong."
            printText alertText "Check if the image is corrupted somehow:"
            stat $1
            printText nl
        }

        # the new files are owned by root when using docker
        # so we set back the owner and the mode
        chmod $FILE_MODE $1.avif
        chown $FILE_OWNER_USER_ID:$FILE_OWNER_GROUP_ID $1.avif
    fi
}

convertImagesToAvif () {
    AVIF_ARGS+=" -q $AVIF_COMPRESSION_LEVEL"
    AVIF_ARGS+=" -s $AVIF_COMPRESSION_SPEED"

    if [[ "$ALL_MANIPULATIONS" = "y" || "$JPG_TO_AVIF" = "y" || "$PNG_TO_AVIF" = "y" ]]; then
        printText text "Converting the images to avif..."
        commandRequired "avif"
        printText nl
    fi

    if [[ "$ALL_MANIPULATIONS" = "y" || "$JPG_TO_AVIF" = "y" ]]; then
        IMAGES=$(findImages jpg)
        for IMAGE in $IMAGES; do
            convertImageToAvif $IMAGE
        done
    fi

    if [[ "$ALL_MANIPULATIONS" = "y" || "$PNG_TO_AVIF" = "y" ]]; then
        IMAGES=$(findImages png)
        for IMAGE in $IMAGES; do
            convertImageToAvif $IMAGE
        done
    fi
}

# ===========================================
    # INIT
# ===========================================

clear
printCopyright
commandRequired "bc"

run "$@"
exit 1
