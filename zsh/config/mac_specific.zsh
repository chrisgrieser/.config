# MACKUP SYNC
# INFO since symlinks of preferences are buggy since macOS Sonoma, this
# workaround will simply copy the preferences without symlinks
function _mackup {
	ln -sf "$HOME/.config/mackup/mackup.cfg" "$HOME/.mackup.cfg"
	ln -sfh "$HOME/.config/mackup/custom-app-configs" "$HOME/.mackup"

	# path needs to be added so it can be called via Hammerspoon
	export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
	mackup "$1" --force && mackup uninstall --force

	rm -v "$HOME/.mackup" "$HOME/.mackup.cfg"
}
function saveprefs_mackup { _mackup backup; }
function loadprefs_mackup { _mackup restore; }

#───────────────────────────────────────────────────────────────────────────────

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


#───────────────────────────────────────────────────────────────────────────────

# app-id of macOS apps
function appid() {
	local id
	id=$(osascript -e "id of app \"$1\"")
	print "\e[1;32mCopied appid:\e[0m $id"
	echo -n "$id" | pbcopy
}

