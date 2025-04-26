function eject {
	volumes=$(df -ih | grep -io "\s/Volumes/.*" | grep -v "/Volumes/Recovery" | cut -c2-)
	if [[ -z "$volumes" ]]; then
		print "\e[1;33mNo volume mounted.\e[0m"
		return 1
	fi
	# if one volume, will auto-eject due to `--select-1`
	selected=$(echo "$volumes" | fzf --exit-0 --select-1 --no-info --height=10%)
	[[ -z "$selected" ]] && return 0 # fzf aborted

	diskutil eject "$selected" ||
		diskutil unmount "$selected" || # if unejectable, `unmount` says which process is blocking
		print "If \e[1;33mmds_stores\e[0m is blocking, try \e[1;33msudo mdutil -i off -d /Volumes/<volume_name>\e[0m to stop Spotlight from indexing."
}

# open first ejectable volume
function vvv {
	first_volume=$(df | grep " /Volumes/" | grep -v "/Volumes/Recovery" | awk -F '   ' '{print $NF}' | head -n1)
	if [[ -d "$first_volume" ]]; then
		open "$first_volume"
	else
		print "\e[1;33mNo ejectable volumes found.\e[0m"
	fi
}

function run_infat {
	[[ -x "$(command -v infat)" ]] || brew install philocalyst/tap/infat
	infat # without arg, applies `~/.config/infat/config.toml`
	brew uninstall infat && brew untap philocalyst/tap
}
