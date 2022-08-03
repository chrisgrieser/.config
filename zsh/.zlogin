# shellcheck disable=SC2164,SC1009,SC1073,SC1056

if [[ "$TERM_PROGRAM" != "Terminus-Sublime" ]] ; then
	clear
	# 33% art, 66% fortune
	if [[ $((RANDOM%3)) == 1 ]] ; then
		bash "$DOTFILE_FOLDER/zsh/plugins/colorscript.bash" --random
	else
		echo
		echo "> $(fortune -n270 -s)"
	fi
	echo
	separator
fi

# show files if there are any
if [[ $(ls | wc -l) -gt 0 ]] ; then
	exa
	separator
	echo
fi


