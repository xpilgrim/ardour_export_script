#!/bin/bash

## Dieses Skript konvertiert wav-Dateien in mp3 und passt die Lautheit mit mp3gain an
## Die mp3-Datei wird anschliessend in ein anderes Verzeichnis kopiert.
## Der Pfad zum Verzeichnis muss in target_folder_mp3 festgelegt werden.
#
## Es kann in den Ardour-Exportsettings eingetragen werden:
## /Pfad_zum_script/./ardour_export_to_mp3_st_192_gain_89.sh %f
## Es entfernt ausserdem das Wort "Projekt" im Dateinamen, welches von Ardour ergaenzt wird.
#
## lame und mp3gain muss installiert sein: sudo apt-get install lame/ sudo apt-get install mp3gain
#
# This script convert wav-files to mp3-files, analyses the mp3-gain and write the mp3gain-tag.
# After that, it copies the file in to a folder specified in target_folder_mp3 
# 
# The script may be running after Ardour export via:
# /path_to_script/./ardour_export_to_mp3_st_192_gain_89.sh %f
# It removes also the word "Projekt", that is added by Ardour export.
#
# dependent on: lame, mp3gain
# if not alraedy on your system, type for example:
# sudo apt-get install mp3gain
#
# Author: Joerg Sorge
# Distributed under the terms of GNU GPL version 2 or later
# Copyright (C) Joerg Sorge joergsorge@gmail.com
# 2015-09-28
#
#
# target folder for mp3 file
# note slashes!
target_folder_mp3="/home/$USER/MyFolder/"

function f_check_package () {
	package_install=$1
	if dpkg-query -s $1 2>/dev/null|grep -q installed; then
		echo "$package_install installiert"
	else
		zenity --error --text="Paket $package_install ist nicht installiert, Bearbeitung nicht moeglich." 
		exit
	fi
}

(

	# check for packages
	f_check_package "mp3gain"
	f_check_package "lame"
	filename=$(basename "$1")
	extension="${filename##*.}"
	# echo and progress will pulsate
	echo "10"
	echo "# Konvertierung in mp3...\n$filename"
	
	if [ "$extension" != "wav" ] && [ "$extension" != "WAV" ]; then
		zenity --error --text="Ausgewählte Datei ist keine wav-Datei:\n$filename" 
		exit
	fi
	message=$(lame -b 192 -m s -o -S "$1" "${1%%.*}.mp3" 2>&1 && echo "Ohne_Fehler_beendet")
	# remove all characters right from 'O'
	error=${message##*O}
	if [ "$error" != "hne_Fehler_beendet" ]
		then
		echo "$message" | zenity --title="mp3-Konvertierungs-Fehler " --text-info --width=500 --height=200
	fi

	echo "# mp3Gain-Anpassung...\n${filename%%.*}.mp3"
	message=$(mp3gain -r "${1%%.*}.mp3" 2>&1 && echo "Ohne_Fehler_beendet")
	# remove all characters right from 'O'
	error=${message##*O}
	if [ "$error" != "hne_Fehler_beendet" ]
		then
		echo "$message" | zenity --title="mp3Gain-Fehler " --text-info --width=500 --height=200
	fi

	# remove "Projekt" in filename if possible
	filename_mp3=$(basename "${1%%.*}.mp3")
	if [ $filename_mp3 != "Projekt.mp3" ]; then
		fstring_old="_Projekt.mp3"
		fsting_new=".mp3"
		filename_without_p=${filename_mp3/$fstring_old/$fsting_new}
		filename_mp3=$filename_without_p
	fi
	
	echo "# Kopieren...\n$filename_mp3\n$target_folder_mp3"
	cp "${1%%.*}.mp3" $target_folder_mp3$filename_mp3
	#echo "Exportiert und kopiert: $filename_mp3" | zenity --title="Exportiert " --text-info --width=500 --height=200
) | zenity --progress \
           --title="wav to mp3: Datei bearbeiten" --text="..." --width=500 --pulsate --auto-close

if [ "$?" = -1 ] ; then
	zenity --error --text="Bearbeitung abgebrochen"
fi
exit
