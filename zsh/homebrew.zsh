# https://docs.brew.sh/Manpage#environment

# install/update
export HOMEBREW_CASK_OPTS="--no-quarantine"
export HOMEBREW_NO_AUTO_UPDATE=0 # updates now speedier
export HOMEBREW_DISPLAY_INSTALL_TIMES=1

# cleanup
export HOMEBREW_AUTOREMOVE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=60
export HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=30

# misc
export HOMEBREW_NO_ANALYTICS=0 # they have the server in the EU now, so it's okay?
export HOMEBREW_NO_ENV_HINTS=1

alias bh='brew home'
alias bl='brew list'
alias bi='brew install'
alias br='brew reinstall'
alias bu='brew uninstall --zap' # codespell-ignore

#───────────────────────────────────────────────────────────────────────────────

# colorize via chromaterm (recursive -> affects all brew commands)
command -v ct &>/dev/null && alias brew="ct brew"

#───────────────────────────────────────────────────────────────────────────────

function print-section() {
	echo
	echo
	echo "$*"
	separator
}

function dump() {
	local dump_path="$DOTFILE_FOLDER/_installed-apps-and-packages/"
	local device_name
	device_name=$(scutil --get ComputerName | cut -d" " -f2-)
	brew bundle dump --force --file "$dump_path/Brewfile_$device_name.txt"
	npm list --location=global --parseable | sed "1d" | sed -E "s/.*\///" >"$dump_path/NPMfile_$device_name.txt"
	pip3 list --not-required | tail -n+3 | cut -d" " -f1 >"$dump_path/Pip3file_$device_name.txt"

	# shellcheck disable=2012
	command ls "$HOME/Library/Application Support/$BROWSER_DEFAULTS_PATH/Default/Extensions/" |
		grep -v "Temp" | sed "s|^|https://chrome.google.com/webstore/detail/|" >"$dump_path/browser-extensions.txt"

	echo "Brewfile, NPM-File, Pip-File and list of browser extensions dumped at \"$dump_path\""
}

function update() {
	print-section "HOMEBREW"
	brew update
	brew upgrade
	brew cleanup

	# manually update, cause brew won't update as it is in theory self-upgrading
	print-section "Obsidian Installer"
	brew upgrade obsidian

	print-section "MAC APP STORE"
	mas upgrade

	print-section "NPM"
	npm update --location=global

	print-section "PIP"
	pip list --not-required | tail -n+3 | cut -d" " -f1 | xargs pip install --upgrade

	print-section "DUMP INSTALL LISTS"
	dump

	# - sketchybar usually updated and then has to be restarted to give permission
	# - also updates the homebrew status counter
	brew services restart sketchybar

	osascript -e 'display notification "" with title "🍺 Homebrew finished." sound name "Blow"'
}

function listall() {
	print-section "HOMEBREW"
	print-section "Taps"
	brew tap
	print-section "Leaves (formulas installed-on-request)"
	brew leaves --installed-on-request
	print-section "Casks"
	brew list --casks
	print-section "Doctor"
	brew doctor

	print-section "MAC APP STORE"
	mas list

	print-section "NPM"
	npm list --location=global

	print-section "Pip3"
	pip list --not-required

	print-section "DUMP INSTALLS"
	dump
}
