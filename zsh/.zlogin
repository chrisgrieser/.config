# shellcheck disable=SC2164,SC1009,SC1073,SC1056

# fortune / color art

if [[ "$TERM_PROGRAM" != "Terminus-Sublime" ]] ; then
	clear
	# 33% art, 66% fortune
	if [[ $((RANDOM%3)) == 1 ]] ; then
		bash "$ZSH_DOTFILE_LOCATION"/plugins/colorscript.bash --random
	else
		echo
		echo "> $(fortune -n270 -s)"
	fi
	echo
fi

