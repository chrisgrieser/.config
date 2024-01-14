# DOCS https://docs.brew.sh/Manpage#environment
#───────────────────────────────────────────────────────────────────────────────

# install/update
export HOMEBREW_CASK_OPTS="--no-quarantine"
export HOMEBREW_DISPLAY_INSTALL_TIMES=1
export HOMEBREW_AUTO_UPDATE_SECS=86400 # only once per day

# cleanup
export HOMEBREW_AUTOREMOVE=1
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=60
export HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=30

# misc
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

#───────────────────────────────────────────────────────────────────────────────

alias bh='brew home'
alias bl='brew list'
alias bi='brew install'
alias br='brew reinstall'
alias bu='brew uninstall --zap'

#───────────────────────────────────────────────────────────────────────────────

function _print-section() {
	echo
	echo "$*"
	_separator
}

function _dump() {
	local dump_path="$HOME/.config/.installed-apps-and-packages/"
	local device_name
	device_name=$(scutil --get ComputerName | cut -d" " -f2-)
	brew bundle dump --force --file "$dump_path/Brewfile_$device_name.txt"

	# shellcheck disable=2010
	ls "$HOME/Library/Application Support/$BROWSER_DEFAULTS_PATH/Default/Extensions/" |
		grep -v "Temp" | sed "s|^|https://chrome.google.com/webstore/detail/|" \
		>"$dump_path/browser-extensions.txt"

	print "\e[1;38;5;247mBrewfile & browser-extensions-list dumped at \"$dump_path\" \e[0m"
}

function update() {
	_print-section "Homebrew Updates"
	brew update
	brew upgrade
	brew cleanup

	# manually update, cause brew won't update as it is in theory self-upgrading
	echo "Obsidian Installer"
	brew upgrade obsidian

	_print-section "Mac App Store"
	mas upgrade

	print "\e[1;38;5;247mRestarting sketchybar…\e[0m"
	# - sketchybar usually updated and then has to be restarted to give permission
	# - also updates the homebrew status counter
	brew services restart sketchybar
	_dump

	osascript -e 'display notification "" with title "🍺 Homebrew finished." sound name "Blow"'
}

function listall() {
	brew update
	_print-section "brew taps"
	brew tap | rs
	_print-section "brew leaves"
	brew leaves | rs
	_print-section "brew casks"
	brew list --casks
	_print-section "brew doctor"
	brew doctor

	_print-section "Mac App Store"
	mas list | rs

	echo && _dump
}
