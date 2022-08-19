# shellcheck disable=SC2164,SC1009,SC1073,SC1056

clear # messages for when launching via Alfred

# requirements:
# - cowsay
# - fortune
if [[ "$TERM" == "alacritty" ]] ; then
	arr[1]=""   # standard
	arr[2]="-b" # Borg Mode
	arr[3]="-d" # dead
	arr[4]="-g" # greedy
	arr[5]="-p" # paranoia
	arr[6]="-s" # stoned
	arr[7]="-t" # tired
	arr[8]="-w" # wake/wired
	arr[9]="-y" # youthful
	rand=$((RANDOM % ${#arr[@]}))
	random_emotion=${arr[$rand]}

	width=$(($(tput cols) - 15))

	if [[ $((RANDOM%2)) == 1 ]] ; then
		say_or_think="cowsay"
	else
		say_or_think="cowthink"
	fi

	echo
	echo "$(fortune -n270 -s)" | $say_or_think -W$width $random_emotion
	echo

	separator
	echo
	directoryInspect
fi
