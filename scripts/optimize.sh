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
# Usage		      :bash optimize.sh
# BashVersion     :Tested with 4.4.12
# License         :MIT License
#                 :Copyright (c) 2021 Rashko Petrov
# ###########################################

# ===========================================
	# Variables
# ===========================================

# majorVersion.year.month.day
VERSION="0.21.06.24"

TARGET_DIR="$PWD"
FIND_ARGS=""
PNG_OPTIMIZATION_ARGS="-quiet"
JPG_OPTIMIZATION_ARGS="-p -o --all-progressive --quiet"

CWEBP_ARGS="-quiet"
CWEBP_LOSSLESS_PRESET="9"
CWEBP_QUALITY_FACTOR="82"

NC="\033[0m" # No Colo
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"

# ===========================================
	# Helpers/Utils
# ===========================================

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

		sep)
			printf "${NC}---------------------${NC}\n"
		;;

		alert)
			printf "${RED}$2${NC}\n"
		;;

		alertSep)
			printf "${RED}---------------------${NC}\n"
		;;

		notice)
			printf "${YELLOW}$2${NC}\n"
		;;

		noticeSep)
			printf "${YELLOW}---------------------${NC}\n"
		;;

		success)
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
		printText alert "Error: $1 isn't installed"
		exit 1
	}
}

printCopyright () {
	printText text "Optimize v$VERSION Copyright (c) 2021, Rashko Petrov"
	printText nl
}

printHelp () {
	printText text "Usage: optimize [OPTIONS].... [PATH]"
	printText text "Optimize/Compress images quality and size."
	printText text "A wrapper around other tools and optimization services that simplifies the process."
	printText nl
	printText text "Options:"
	printText nl
	printText text "            --jpg                         Optimize the jpg images"
	printText text "            --jpg-to-webp                 Convert the jpg images in webp but keeps the original files"
	printText text "            --jpg-to-avif                 Convert the jpg images in avif but keeps the original files"
	printText text "            --jpg-optimization-lvl <int>  Overrides the global optimization level"
	printText nl
	printText text "            --png                         Optimize all png images"
	printText text "            --png-to-webp                 Convert the png images in webp but keeps the original files"
	printText text "            --png-to-avif                 Convert the png images in avif but keeps the original files"
	printText text "            --png-optimization-lvl <int>  Overrides the global optimization level."
	printText nl
	printText text "                                         Optimization settings:"
	printText text "  -s,       --strip-markers               Strip metadata when optimizing jpg/png images"
	printText text "  -o <int>, --optimization-lvl <int>     Optimization level (0-7) [default: 2]"
	printText nl
	printText text "                                         Webp settings:"
	printText text "            --webp-quality-factor <int>  Quality factor (0:small..100:big), [default: 82]"
	printText text "            --webp-lossless-preset <int> Activates lossless preset with given level in [default: 9]"
	printText text "                                         (0:fast..9:slowest)"
	printText nl
	printText text "            --cmin [+|-]<n>               File's status was last changed n minutes ago"
	printText text "  -a,       --all                         Optimize and convert all jpg/png images to webp/avif"
	printText text "  -p,       --path <images path>          Define images path [default: current directory]"
	printText text "  -v,       --version                     Print version information and quit"
	printText text "  -u,       --check-for-update            Check for updates"
	printText nl
	printText text "Examples:"
	printText text "  optimize                               Prints the help text"
	printText text "  optimize --help                        Prints the help text"
	printText text "  optimize --png --jpg --strip-markers   Optimizes all png and jpg in current durectory"
	return 0
}

# ===========================================
	# Implementation
# ===========================================

run () {
	if [ "${#}" = "0" ]; then
		printText alert "optimize: arguments missing"
		printText alert "Try 'optimize --help' for more information."
		printText nl
		exit 1
	fi

	preventMultiExecutionOnSameDirectory
	parseArgs "$@"

	cd $TARGET_DIR || exit 1

	optimizeImages
	convertImagesToWebp
	convertImagesToAvif

	preventMultiExecutionOnSameDirectoryReset

	printText nl
	printText success "Image optimization performed successfully !"
	printText nl
}

preventMultiExecutionOnSameDirectory () {
	LOCK_FILE=$(echo -n "$TARGET_DIR" | md5sum | cut -d" " -f1)

	if [ -f "/tmp/$LOCK_FILE" ]; then
		printText nl
		printText alert "The script is currently processing the given path:"
		printText alert "    $TARGET_DIR"
		printText nl

		printText notice "The script creates file that indicates it's running."
		printText notice "This is necessary in order to prevent multiple executions in the same directory."
		printText notice "In case the script crashes or is manually interrupted, you can reset the script status."
		printText notice "Would you like to reset the script status and proceed with current execution?"
		read -p "=> [Yy] to confirm: " -n 1 -r USER_CONFIRMATION

		if [[ $USER_CONFIRMATION =~ ^[Yy]$ ]]; then
			printText nl
			printText notice "The script status has been reset."
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

checkForUpdates () {
	printText noticeSep
	printText notice "Check for update is not implemented yet."
	printText noticeSep
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
					JPG_OPTIMIZATION_QUALITY=$(((8 - $2) * 14))
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

					if [[ ! $JPG_OPTIMIZATION_LVL_OVERRIDE = 'y' ]]; then
						JPG_OPTIMIZATION_QUALITY=$(((8 - $2) * 14))
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

			-a | --all)
				ALL_MANIPULATIONS="y"
			;;

			-p | --path)
				if [ -n "$2" ]; then
					IMG_PATH="$2"
					shift
				fi
			;;

			-h | --help | help)
				printHelp
				exit 1
			;;

			-v | --version)
				printText $VERSION
				exit 1
			;;

			-u | --check-for-update)
				checkForUpdates
				exit 1
			;;
		*)

		printText alert "Error! Unknown option '$1'."
		printHelp
		exit 1
		esac

		shift
	done
}

listImages () {
	if [[ $1 = "png" ]]; then
		find . -type f -iname "*.png" $FIND_ARGS
	fi

	if [[ $1 = "jpg" ]]; then
		find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) $FIND_ARGS
	fi
}

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

			FILE_SIZE_AFTER_KB=$( bc <<< "scale=0; $(wc -c < $2)/1000" )
			FILE_SIZE_DIFFERENCE_KB=$( bc <<< "$FILE_SIZE_BEFORE_KB - $FILE_SIZE_AFTER_KB" )

			printText text "Size (kb):"
			printText text "    before: $FILE_SIZE_BEFORE_KB    after: $FILE_SIZE_AFTER_KB    difference: $FILE_SIZE_DIFFERENCE_KB"
			printText nl
		} || { # catch
			printText alert "Err: something went wrong."
			printText alert "Check if the image is corrupted somehow:"
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
	printText text "Optimizing the images..."

	if [[ ! $OPTIMIZATION_LEVEL = 'y' ]]; then
		PNG_OPTIMIZATION_ARGS+=" -o2"
		JPG_OPTIMIZATION_ARGS+=" -m82"
	fi

	if [[ "$ALL_MANIPULATIONS" = "y" || "$JPG_OPTIMIZATION" = "y" ]]; then
		IMAGES=$(listImages jpg)
		for IMAGE in $IMAGES; do
			optimizeImage jpg $IMAGE
		done
	fi

	if [[ "$ALL_MANIPULATIONS" = "y" || "$PNG_OPTIMIZATION" = "y" ]]; then
		IMAGES=$(listImages png)
		for IMAGE in $IMAGES; do
			optimizeImage png $IMAGE
		done
	fi
}

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
			[ ! -f '{}.webp' ] && {
				cwebp $CWEBP_ARGS $1 -o $1.webp
			}

			FILE_SIZE_WEBP_KB=$( bc <<< "scale=0; $(wc -c < $1.webp)/1000" )
			FILE_SIZE_DIFFERENCE_KB=$( bc <<< "$FILE_SIZE_KB - $FILE_SIZE_WEBP_KB" )

			printText text "Size (kb):"
			printText text "    before: $FILE_SIZE_KB    after: $FILE_SIZE_WEBP_KB    difference: $FILE_SIZE_DIFFERENCE_KB"
			printText nl
		} || { # catch
			printText alert "Err: something went wrong."
			printText alert "Check if the image is corrupted somehow:"
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
	printText text "Converting the images to cwebp..."

	CWEBP_ARGS+=" -z $CWEBP_LOSSLESS_PRESET"
	CWEBP_ARGS+=" -q $CWEBP_QUALITY_FACTOR"

	if [[ "$ALL_MANIPULATIONS" = "y" || "$JPG_TO_WEBP" = "y" ]]; then
		IMAGES=$(listImages jpg)
		for IMAGE in $IMAGES; do
			convertImageToWebp $IMAGE
		done
	fi

	if [[ "$ALL_MANIPULATIONS" = "y" || "$PNG_TO_WEBP" = "y" ]]; then
		IMAGES=$(listImages png)
		for IMAGE in $IMAGES; do
			convertImageToWebp $IMAGE
		done
	fi
}

convertImagesToAvif () {
	if [[ "$ALL_MANIPULATIONS" = "y" || "$JPG_TO_AVIF" = "y" ]]; then
		printText text "Converting the jpg images to avif..."

		find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) $FIND_ARGS -print0 | xargs -0 -r -I {} \
			bash -c "[ ! -f '{}.avif' ] && { avif -e '{}' -o '{}.avif' || rm -f '{}.avif'; }"
	fi

	if [[ "$ALL_MANIPULATIONS" = "y" || "$PNG_TO_AVIF" = "y" ]]; then
		printText text "Converting the png images to avif..."

		find . -type f -iname "*.png" $FIND_ARGS -print0 | xargs -0 -r -I {} \
			bash -c "[ ! -f '{}.avif' ] && { avif -e '{}' -o '{}.avif' || rm -f '{}.avif'; }"
	fi
}

# ===========================================
	# INIT
# ===========================================

clear
printCopyright

commandRequired "jpegoptim"
commandRequired "optipng"
commandRequired "cwebp"
commandRequired "avif"
commandRequired "bc"

run "$@"
exit 1
