# shellcheck disable=SC2164,SC1009,SC1073,SC1056

clear # messages when launching via Alfred

if [[ "$TERMINAL" == "Alacritty" ]] ; then
	# clear
	# 33% art, 66% fortune
	if [[ $((RANDOM%3)) == 1 ]] ; then
		bash "$DOTFILE_FOLDER/zsh/plugins/colorscript.bash" --random
	else
		echo
		echo "> $(fortune -n270 -s)"
	echo
	fi
	separator
	echo

	directoryInspect
fi
