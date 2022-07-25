#!/bin/zsh
sublcli="/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" # using full path makes this work even if `subl` hasn't been added to PATH

if [[ "$*" =~ ";" ]] ; then
	line=$(echo "$*" | cut -d";" -f2)
	hash=$(echo "$*" | cut -d";" -f1)
	echo $line
else
	hash="$*"
	open
fi
