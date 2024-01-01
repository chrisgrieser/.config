# mackup sync
# INFO since symlinks of preferences are buggy since Sonoma, this workaround
# will simply copy the preferences without symlinks
alias saveprefs="mackup backup --force && mackup uninstall --force"
alias loadprefs="mackup restore --force && mackup uninstall --force"

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

# safer removal of files
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
}

# go up and delete current dir
function ..d() {
	if ! command -v trash &>/dev/null; then print "\033[1;33mmacos-trash not installed.\033[0m" && return 1; fi

	trash "$PWD" || return 1
	cd "$(dirname "$PWD")" || return 1
}

#───────────────────────────────────────────────────────────────────────────────

# app-id of macOS apps
function appid() {
	local id
	id=$(osascript -e "id of app \"$1\"")
	print "\e[1;32mCopied appid:\e[0m $id"
	echo -n "$id" | pbcopy
}

# read app and macOS system setting changes https://news.ycombinator.com/item?id=36982463
function prefs() {
	if [[ "$PREF_BEFORE" -eq 0 ]]; then
		defaults read >/tmp/before
		PREF_BEFORE=1

		echo "Saved current \`defaults\` state. "
		echo "Make changes."
		echo "Then run \`prefs\` again for a diff of the changes."
	else
		defaults read >/tmp/after
		local changes
		changes=$(command diff /tmp/before /tmp/after | grep -v "_DKThrottledActivityLast" | grep -E "^(<|>)")
		PREF_BEFORE=0
		echo "$changes"

		# show context, so the domain can be identified
		_separator
		toGrep=$(echo "$changes" | tail -n1 | sed -e 's/^> *//')
		grep -B20 "$toGrep" /tmp/after
	fi
}
