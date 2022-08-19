# shellcheck disable=SC2164,SC1009,SC1073,SC1056

clear # messages for when launching via Alfred

if [[ "$TERMINAL" == "Alacritty" ]] ; then
	arr[1]=""   # standard
	arr[2]="-b" # Borg Mode
	arr[3]="-d" # dead
	arr[4]="-g" # greedy
	arr[5]="-p" # paranoia
	arr[6]="-s" # stoned
	arr[7]="-r" # tired
	arr[8]="-w" # wake/wired
	arr[9]="-y" # youthful
	rand=$((RANDOM % ${#arr[@]}))
	random_cow=${arr[$rand]}

	echo
	echo "$(fortune -n270 -s)" | cowsay -W=70 $random_cow
	echo

	separator
	echo
	directoryInspect
fi
