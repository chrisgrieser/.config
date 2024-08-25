function eject {
	volumes=$(df -ih | grep -io "\s/Volumes/.*" | cut -c2-)
	if [[ -z "$volumes" ]]; then
		print "\033[1;33mNo volume mounted.\033[0m"
		return 1
	fi
	# if one volume, will auto-eject due to `--select-1`
	selected=$(echo "$volumes" | fzf --exit-0 --select-1 --no-info --height=10%)
	[[ -z "$selected" ]] && return 0 # fzf aborted
	diskutil eject "$selected"
}

# app-id of macOS apps
function appid() {
	local id
	id=$(osascript -e "id of app \"$1\"")
	print "\e[1;32mCopied appid:\e[0m $id"
	echo -n "$id" | pbcopy
}

# open first ejectable volume
function vol {
	first_volume=$(df | grep --max-count=1 " /Volumes/" | awk -F '   ' '{print $NF}')
	if [[ -d "$first_volume" ]]; then
		open "$first_volume"
	else
		print "\e[1;33mNo ejectable volumes found.\e[0m"
	fi
}
