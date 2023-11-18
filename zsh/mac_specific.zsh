#!/usr/bin/env zsh

# mackup sync
# INFO since symlinks of preferences are buggy since Sonoma, this workaround
# will simply copy the preferences without symlinks
alias saveprefs="mackup backup --force && mackup uninstall --force"
alias loadprefs="mackup restore --force && mackup uninstall --force"

#───────────────────────────────────────────────────────────────────────────────

# eject
function e {
	volumes=$(df -ih | grep -io "\s/Volumes/.*" | cut -c2-)
	if [[ -z "$volumes" ]]; then
		print "\033[1;33mNo volume mounted.\033[0m"
		return 1
	fi
	if [[ ! -x "$(command -v fzf)" ]]; then print "\033[1;33mfzf not installed.\033[0m" && return 1; fi

	# if one volume, will auto-eject due to `--select-1`
	selected=$(echo "$volumes" | fzf --exit-0 --select-1 --no-info --height=10%)
	[[ -z "$selected" ]] && return 0 # fzf aborted
	diskutil eject "$selected"
}

# safer removal
# - moves to macOS trash instead of irreversibly deleting with `rm`
# - no arg = all files in folder will be deleted
# - adds sound on success
function d {
	if ! command -v trash &>/dev/null; then print "\033[1;33mmacos-trash not installed.\033[0m" && return 1; fi

	if [[ $# == 0 ]]; then
		trash ./*(D) || return 1 # (D) makes the glob include dotfiles (zsh-specific)
	else
		trash "$@" || return 1
	fi

	## add nicer trash sound
	current_vol=$(osascript -e 'output volume of (get volume settings)')
	[[ "$current_vol" == "missing value" ]] && current_vol=50
	vol_percent=$(echo "scale=2 ; $current_vol / 100" | bc) # afplay play with 100% volume by default
	(afplay --volume "$vol_percent" "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/dock/drag to trash.aif" &)
}

# go up and delete current dir
function ..d() {
	if ! command -v trash &>/dev/null; then print "\033[1;33mmacos-trash not installed.\033[0m" && return 1; fi

	trash "$PWD" || return 1
	cd "$(dirname "$PWD")" || return 1

	# add nicer trash sound
	current_vol=$(osascript -e 'output volume of (get volume settings)') # afplay play with 100% volume by default
	[[ "$current_vol" == "missing value" ]] && current_vol=50
	vol_percent=$(echo "scale=2 ; $current_vol / 100" | bc)
	(afplay --volume "$vol_percent" "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/dock/drag to trash.aif" &)
}
