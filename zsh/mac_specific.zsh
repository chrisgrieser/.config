#!/usr/bin/env zsh

# eject
function e {
	volumes=$(df -h | grep -io "\s/Volumes/.*" | cut -c2-)
	if [[ -z "$volumes" ]]; then
		print "\033[1;33mNo volume connected.\033[0m"
		return 1
	fi
	if [[ ! -x "$(command -v fzf)" ]]; then print "\033[1;33mfzf not installed.\033[0m" && return 1; fi

	# if one volume, will auto-eject due to `-1`
	selected=$(echo "$volumes" | fzf -0 -1 --no-info --height=10%)
	[[ -z "$selected" ]] && return 0 # fzf aborted
	diskutil eject "$selected"
}

# app-id of macOS apps
function appid {
	local id
	id=$(osascript -e "id of app \"$1\"")
	echo "Copied appid: $id"
	echo -n "$id" | pbcopy
}

# read app and macOS system setting changes https://news.ycombinator.com/item?id=36982463
function prefs {
	if [[ "$PREF_BEFORE" -eq 0 ]]; then
		defaults read >/tmp/before
		PREF_BEFORE=1

		echo "Saved current \`defaults\` state. Make changes and run \`prefs\` again for a diff of the changes."
	else
		defaults read >/tmp/after
		local changes
		changes=$(command diff /tmp/before /tmp/after | grep -v "_DKThrottledActivityLast" | grep -E "^(<|>)")
		PREF_BEFORE=0
		echo "$changes"

		# show context, so the domain can be identified
		separator
		toGrep=$(echo "$changes" | tail -n1 | sed -e 's/^> *//')
		grep -B20 "$toGrep" /tmp/after
	fi
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
function  ..d() {
	if ! command -v trash &>/dev/null; then print "\033[1;33mmacos-trash not installed.\033[0m" && return 1; fi

	local current_dir="$PWD"
	cd ..
	trash "$current_dir" || return 1
	inspect
	auto_venv

	# add nicer trash sound
	current_vol=$(osascript -e 'output volume of (get volume settings)') # afplay play with 100% volume by default
	[[ "$current_vol" == "missing value" ]] && current_vol=50
	vol_percent=$(echo "scale=2 ; $current_vol / 100" | bc)
	(afplay --volume "$vol_percent" "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/dock/drag to trash.aif" &)
}
