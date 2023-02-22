# https://docs.brew.sh/Manpage#environment

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=60
export HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=30
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_AUTOREMOVE=1
export HOMEBREW_CASK_OPTS="--no-quarantine"

BREWDUMP_PATH="$DOTFILE_FOLDER/installed-apps-and-packages/"

# aliases already get tab-completion
alias bh='brew home'
alias bl='brew list'
alias bi='brew install'
alias br='brew reinstall'
alias bu='brew uninstall --zap'

#───────────────────────────────────────────────────────────────────────────────

function print-section () {
	echo
	echo
	echo "$*"
	separator
}

function dump () {
	local device_name
	device_name=$(scutil --get ComputerName | cut -d" " -f2-)
	brew bundle dump --force --file "$BREWDUMP_PATH/Brewfile_$device_name"
	command npm list --location=global --parseable | sed "1d" | sed -E "s/.*\///" > "$BREWDUMP_PATH/NPMfile_$device_name"
	pip3 list --not-required | tail -n+3 | grep -vE "Pillow|pip|pybind|setuptools|six|wheel" | cut -d" " -f1 > "$BREWDUMP_PATH/Pip3file_$device_name"
	echo "Brewfile, Pip3File & NPM-File dumped at \"$BREWDUMP_PATH\""
}

function update (){
	print-section "HOMEBREW"
	print-section "update"
	brew update
	print-section "upgrade"
	brew upgrade
	print-section "cleanup"
	brew cleanup

	print-section "MAC APP STORE"
	mas upgrade

	print-section "NPM"
	command npm update --location=global

	print-section "Pip3"
	pip3 install --upgrade "pdfannots"
	pip3 install --upgrade "pdfminer.six"
	pip3 install --upgrade "alacritty-colorscheme"

	print-section "DUMP INSTALLS"
	dump
	
	print-section "\033[1;33mREMINDER"
	echo "If sketchybar or espanso updated, they need to be re-given permissions."
}

function report (){
	print-section "HOMEBREW"
	print-section "Taps"
	brew tap
	print-section "Doctor"
	brew doctor
	print-section "Formula/Leaves (installed on request)"
	brew leaves --installed-on-request
	print-section "Formula/Leaves (installed as dependency)"
	brew leaves --installed-as-dependency
	print-section "Casks"
	brew list --casks

	print-section "MAC APP STORE"
	mas list

	print-section "NPM"
	npm list --location=global

	print-section "DUMP INSTALLS"
	dump
}
