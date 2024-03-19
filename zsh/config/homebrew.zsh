# DOCS https://docs.brew.sh/Manpage#environment
#───────────────────────────────────────────────────────────────────────────────
export HOMEBREW_CASK_OPTS="--no-quarantine"
export HOMEBREW_DISPLAY_INSTALL_TIMES=1
export HOMEBREW_AUTO_UPDATE_SECS=86400 # only once per day

export HOMEBREW_AUTOREMOVE=1
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=60
export HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=30

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

alias bh='brew home'
alias bl='brew list'
alias bi='brew install'
alias br='brew reinstall'
alias bu='brew uninstall --zap'
alias depending_on='brew uses --installed --recursive'

#───────────────────────────────────────────────────────────────────────────────

function _print-section() {
	echo
	print "\e[1;34m$1\e[0m"
	_separator
}

function _dump() {
	local dump_path="$HOME/.config/.installed-apps-and-packages"
	local device_name
	device_name=$(scutil --get ComputerName | cut -d" " -f2-)
	brew bundle dump --force --file "$dump_path/Brewfile_$device_name.txt"

	# shellcheck disable=2010
	ls "$HOME/Library/Application Support/$BROWSER_DEFAULTS_PATH/Default/Extensions/" |
		grep -v "Temp" | sed "s|^|https://chrome.google.com/webstore/detail/|" \
		>"$dump_path/browser-extensions.txt"

	print "\e[1;38;5;247mBrewfile & browser-extensions-list saved at \"$(basename "$dump_path")\".\e[0m"
}

#───────────────────────────────────────────────────────────────────────────────

function update_cmdline_tools {
	local update
	update=$(softwareupdate --list |
		grep --only-matching --extended-regexp='Command Line Tools-.*$' |
		head -n1)
	softwareupdate --install "$update"
}

function update() {
	_print-section "Homebrew"
	brew update
	brew upgrade
	brew cleanup

	# manually update, cause brew won't update as it is in theory self-upgrading
	echo
	brew upgrade obsidian

	_print-section "Mac App Store"

	# HACK -> PENDING https://github.com/mas-cli/mas/issues/512
	mas outdated | grep -v "Highlights" | cut -f1 -d" " | xargs mas upgrade
	# mas upgrade

	_print-section "Finish up"
	# sketchybar needs restart for new persmission
	sketchybar_was_updated=$(find "$HOMEBREW_PREFIX/bin/sketchybar" -mtime -1h)
	[[ -n "$sketchybar_was_updated" ]] && brew services restart sketchybar

	echo
	_dump
	echo
	osascript -e 'display notification "Finished Update." with title "🍺 Homebrew" sound name "Blow"'
}

function listall() {
	brew info
	_print-section "brew taps"
	brew tap | rs
	_print-section "brew leaves --installed-on-request"
	brew leaves --installed-on-request | rs
	_print-section "brew list --casks"
	brew list --casks
	_print-section "brew doctor"
	brew doctor

	_print-section "Mac App Store"
	mas list

	echo && _dump
}
