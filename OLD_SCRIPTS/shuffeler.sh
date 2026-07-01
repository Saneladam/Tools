#!/bin/zsh
# This script randomly selects a file from the ./ directory.
#
# Usage:
#  ./shuffeler.sh $directory $selectionFile

Directory=$1
OutputFileDir=$2

OriginDirectory=$(pwd)  
cd "$Directory" || exit 1

MaxFileNumber=$(ls | wc -l)
NumberSelection=$(( 1 + RANDOM % MaxFileNumber ))
SelectedFile=$(ls | awk "NR==$NumberSelection")

cp "$SelectedFile" "$OutputFileDir"
cd "$OriginDirectory" || exit 1
