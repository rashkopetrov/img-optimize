#!/bin/bash
# ##########################################################################
# Title           :Img Optimize
# Description     :This script optimizes the images quality and size.
# Author          :Rashko Petrov
# Website         :https://rashkopetrov.dev
# GitHub          :https://github.com/rashkopetrov/img-optimize
# DockerHub       :https://hub.docker.com/repository/docker/rashkopetrovdev/img-optimize
# Date            :2021-06-24
# Version         :0.21.06.24 - 2021-06-24
# Usage		      :bash optimize.sh
# BashVersion     :Tested with 4.4.12
# License         :MIT License
#                 :Copyright (c) 2021 Rashko Petrov
# ##########################################################################

# ==========================================================================
	# Variables
# ==========================================================================

# majorVersion.year.month.day
VERSION="0.21.06.24"

TARGET_DIR="$PWD"
FIND_ARGS=""
CWEBP_ARGS=""
PNG_OPTIMIZATION_ARGS=""
JPG_OPTIMIZATION_ARGS="-p --all-progressive"

NC="\033[0m" # No Colo
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"

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

printNotice () {
	printf "${YELLOW}$1${NC}\n"
}

printNoticeSep () {
	printf "${YELLOW}---------------------${NC}\n"
}

printSuccess () {
	printf "${GREEN}$1${NC}\n"
}

printSuccessSep () {
	printf "${GREEN}---------------------${NC}\n"
}

commandRequired () {
	[ -z "$(command -v $1)" ] && {
		printAlert "Error: $1 isn't installed"
		exit 1
	}
}

printHelp () {
	printText "optimize v$VERSION  Copyright (c) 2021, Rashko Petrov"
	printText ""
	printText "Usage: optimize [OPTIONS].... [PATH]"
	printText "Optimize/Compress images quality and size."
	printText ""
	printText "Options:"
	printText ""
	printText "           --jpg                        Optimize the jpg images."
	printText "           --jpg-to-webp                Convert the jpg images in webp but keeps the original files."
	printText "           --jpg-to-avif                Convert the jpg images in avif but keeps the original files."
	printText "           --jpg-optimization-lvl <ol>  Overrides the global optimization level."
	printText ""
	printText "           --png                        Optimize all png images."
	printText "           --png-to-webp                Convert the png images in webp but keeps the original files."
	printText "           --png-to-avif                Convert the png images in avif but keeps the original files."
	printText "           --png-optimization-lvl <ol>  Overrides the global optimization level."
	printText ""
	printText "           --cmin [+|-]<n>              File's status was last changed n minutes ago."
	printText "  -q,      --quiet                      Run optimization quietly."
	printText "  -s,      --strip-markers              Strip metadata when optimizing jpg/png images."
	printText "  -o <ol>, --optimization-lvl <ol>      Optimization level (0-7) [default: 2]."
	printText "  -a,      --all                        Optimize and convert all jpg/png images to webp/avif."
	printText "  -p,      --path <images path>         Define images path [default: current directory]."
	printText "  -v,      --version                    Print version information and quit."
	printText "  -u,      --check-for-update           Check for updates."
	printText ""
	printText "Examples:"
	printText "  optimize              Prints the help text"
	printText "  optimize --png --jpg  Optimizes all png and jpg in current durectory"
	return 0
}

# ==========================================================================
	# Implementation
# ==========================================================================

run () {
	if [ "${#}" = "0" ]; then
		printAlertSep
		printAlert "optimize: arguments missing"
		printAlert "Try 'optimize --help' for more information."
		printAlertSep
		exit 1
	fi

	preventMultiExecutionOnSameDirectory
	parseArgs "$@"

	cd $TARGET_DIR || exit 1

	optimizeImages
	convertImagesToWebp
	convertImagesToAvif

	rm "/tmp/$LOCK_FILE"
	printText ""
	printSuccessecho "Image optimization performed successfully !"
	printText ""
}

preventMultiExecutionOnSameDirectory () {
	LOCK_FILE=$(echo -n "$TARGET_DIR" | md5sum | cut -d" " -f1)

	if [ -f "/tmp/$LOCK_FILE" ]; then
		printAlertSep
		printAlert "The script is currently processing the given path:"
		printAlert "    :$TARGET_DIR"
		printAlertSep

		printNotice "The script creates file that indicates it's running."
		printNotice "This is necessary in order to prevent multiple executions in the same directory."
		printNotice "In case the script crashes or is manually interrupted, you can reset the script status."
		printNotice "Would you like to reset the script status and proceed with current execution?"
		printf "${YELLOW}"
		read -p "=> [Yy] to confirm: " -n 1 -r USER_CONFIRMATION
		printf "${NC}"

		if [[ $USER_CONFIRMATION =~ ^[Yy]$ ]]; then
			rm "/tmp/$LOCK_FILE"
			printNotice "The script status has been reset."
			printTextSep
		fi

		if [[ ! $USER_CONFIRMATION =~ ^[Yy]$ ]]; then
			newLine
			exit 1
		fi
	fi

	touch "/tmp/$LOCK_FILE"
}

checkForUpdates () {
	printNoticeSep
	printNotice "Check for update is not implemented yet."
	printNoticeSep
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

			-q | --quiet)
				CWEBP_ARGS+=" -quiet"
				PNG_OPTIMIZATION_ARGS+=" -quiet"
				JPG_OPTIMIZATION_ARGS+=" --quiet"
			;;

			-s | --strip-markers)
				PNG_OPTIMIZATION_ARGS+=" -strip all"
				JPG_OPTIMIZATION_ARGS+=" -s"
			;;

			-o | --optimization-level)
				if [ -n "$2" ] && [ "$2" -ge 0 ] && [ "$2" -le 7 ]; then
					OPTIMIZATION_LEVEL="y"

					if [ $PNG_OPTIMIZATION_LVL_OVERRIDE != 'y' ]; then
						PNG_OPTIMIZATION_ARGS+=" -o$2"
					fi

					if [ $JPG_OPTIMIZATION_LVL_OVERRIDE != 'y' ]; then
						JPG_OPTIMIZATION_QUALITY=$(((8 - $2) * 14))
						if [ "$JPG_OPTIMIZATION_QUALITY" -ge 100 ]; then
							JPG_OPTIMIZATION_QUALITY=100
						fi

						JPG_OPTIMIZATION_ARGS+=" -m$JPG_OPTIMIZATION_QUALITY"
					fi

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

		printAlert "Error! Unknown option '$1'."
		printHelp
		exit 1
		esac

		shift
	done
}

optimizeImages () {
	if [ $OPTIMIZATION_LEVEL != 'y' ]; then
		PNG_OPTIMIZATION_ARGS+=" -o2"
		JPG_OPTIMIZATION_ARGS+=" -m82"
	fi

	if [[ "$ALL_MANIPULATIONS" = "y" || "$JPG_OPTIMIZATION" = "y" ]]; then
		commandRequired "jpegoptim"

		find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) $FIND_ARGS -print0 | xargs -r -0 jpegoptim $JPG_OPTIMIZATION_ARGS
	fi

	if [[ "$ALL_MANIPULATIONS" = "y" || "$PNG_OPTIMIZATION" = "y" ]]; then
		commandRequired "optipng"

		find . -type f -iname '*.png' $FIND_ARGS -print0 | xargs -r -0 optipng $PNG_OPTIMIZATION_ARGS
	fi
}

convertImagesToWebp () {
	commandRequired "cwebp"

	if [[ "$ALL_MANIPULATIONS" = "y" || "$JPG_TO_WEBP" = "y" ]]; then
		find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) $FIND_ARGS -print0 | xargs -0 -r -I {} \
			bash -c "[ ! -f '{}.webp' ] && { cwebp $CWEBP_ARGS -q 82 -mt '{}' -o '{}.webp' || rm -f '{}.webp'; }"
	fi

	if [[ "$ALL_MANIPULATIONS" = "y" || "$PNG_TO_WEBP" = "y" ]]; then
		find . -type f -iname "*.png" $FIND_ARGS -print0 | xargs -0 -r -I {} \
			bash -c "[ ! -f '{}.webp' ] && { cwebp $CWEBP_ARGS -z 9 -mt '{}' -o '{}.webp'; }"
	fi
}

convertImagesToAvif () {
	commandRequired "avif"

	if [[ "$ALL_MANIPULATIONS" = "y" || "$JPG_TO_AVIF" = "y" ]]; then
		find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) $FIND_ARGS -print0 | xargs -0 -r -I {} \
			bash -c "[ ! -f '{}.avif' ] && { avif -e '{}' -o '{}.avif' || rm -f '{}.avif'; }"
	fi

	if [[ "$ALL_MANIPULATIONS" = "y" || "$PNG_TO_AVIF" = "y" ]]; then
		find . -type f -iname "*.png" $FIND_ARGS -print0 | xargs -0 -r -I {} \
			bash -c "[ ! -f '{}.avif' ] && { avif -e '{}' -o '{}.avif' || rm -f '{}.avif'; }"
	fi
}

# ==========================================================================
	# INIT
# ==========================================================================

run "$@"
exit 1
