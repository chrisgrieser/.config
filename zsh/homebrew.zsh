# Configs https://docs.brew.sh/Manpage#environment
#-------------------------------------------------------------------------------

export HOMEBREW_NO_AUTO_UPDATE=0
export HOMEBREW_AUTO_UPDATE_SECS=259200 # 3 days before updating on `brew install`
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_GITHUB_API=1
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=60
export HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=30
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_AUTOREMOVE=1
export HOMEBREW_CASK_OPTS="--no-quarantine"
export HOMEBREW_DISPLAY_INSTALL_TIMES=1

BREWDUMP_PATH="$DOTFILE_FOLDER/Installed Apps and Packages/"

alias bh='brew home'
alias bl='brew list'

# -----------------------------------------------------

# Uninstaller for Mac App Store Apps
function un () {
	local APP="$*"
	APP="${(C)APP}" # capitalize input
	if [[ -e "/Applications/$APP.app" ]]; then
		open -a "AppCleaner" "/Applications/$APP.app/"
		return 0
	fi

	local SELECTED=""
	local SELECTED=$( mas list | cut -c13- | cut -d"(" -f1 | sed 's/ *$//g' | fzf \
	           -0 \
	           --query "$1" \
	           --height=80% \
	           --preview-window=right:70% \
	           )
	[[ "$SELECTED" == "" ]] && return 130
	open -a "AppCleaner" "/Applications/$SELECTED.app/"
	killall "$SELECTED" || true
}

# helper function for `br` and `bi`
function post-install () {
	local BREW_INFO=$(brew info "$1")

	if [[ "$BREW_INFO" =~ "Caveats" ]] ; then
		echo '\033[1;33m⚠️ Caveats'
		osascript -e "beep"
	fi

	[[ "$2" != "--cask" ]] && return 0

	# shellcheck disable=SC2012
	local NEWEST_APP="$(ls -tc /Applications | head -n1)"
	echo "Open \"$NEWEST_APP\"? (y/n)" # offer to open

	# stop when decision not yes
	read -r -k 1 DECISION
	[[ "$DECISION:l" != "y" ]] && return 0 # ":l" = lowercase https://scriptingosx.com/2019/12/upper-or-lower-casing-strings-in-bash-and-zsh/

	open -a "$NEWEST_APP"
}

function br () {
	if [[ $1 != "" ]] && brew list "$1" ; then
		brew reinstall "$1"
		return
	fi

	local SELECTED=""
	# shellcheck disable=SC1009,SC1056,SC1072,SC1073
	local SELECTED=$( { brew list --casks ; brew leaves --installed-on-request } | fzf \
	           -0 \
	           --query "$1" \
	           --preview 'HOMEBREW_COLOR=true brew info {}' \
	           --bind 'alt-enter:execute(brew home {})+abort' \
	           --height=80% \
	           --preview-window=right:70% \
	           )
	[[ "$SELECTED" == "" ]] && return 130
	brew reinstall "$SELECTED"

	post-install "$SELECTED"
}
function bu () {
	if [[ $1 != "" ]] && brew list "$1" ; then
		brew uninstall --zap "$1"
		return
	fi

	local SELECTED=""
	# shellcheck disable=SC1009,SC1056,SC1072,SC1073
	local SELECTED=$( { brew list --casks ; brew leaves --installed-on-request } | fzf \
	           -0 \
	           --query "$1" \
	           --preview 'HOMEBREW_COLOR=true brew info {}' \
	           --bind 'alt-enter:execute(brew home {})+abort' \
	           --height=80% \
	           --preview-window=right:70% \
	           )
	[[ "$SELECTED" == "" ]] && return 130
	brew uninstall --zap "$SELECTED"
	killall "$SELECTED" &> /dev/null || true
}

function bi (){
	local TO_INSTALL="$1"
	local TYPE="$2" # formula or cask

	# abort if already installed
	brew list "$TO_INSTALL" &> /dev/null && echo "Already installed." && return 0

	# if package does not exist, search for it via fzf
	brew info "$TO_INSTALL" &> /dev/null
	if [[ $? == 1 ]] ; then
		local SELECTED=""
		SELECTED=$( { brew formulae ; brew casks } | fzf \
		           -0\
		           --query "$TO_INSTALL" \
		           --preview 'HOMEBREW_COLOR=true brew info {}' \
		           --bind 'alt-enter:execute(brew home {})+abort' \
		           --preview-window=right:70% \
		           ) ;

		# abort if no selection made
		[[ $SELECTED == "" ]] && return 130

		local TO_INSTALL="$SELECTED"
	fi

	brew install "$TO_INSTALL" $TYPE # quotes would add empty 2nd arg if empty
	post-install "$TO_INSTALL" $TYPE
}

# helper function for `update` and `report`
function print-section () {
	echo
	echo "$*"
	separator
}

function dump () {
	local device_name=$(scutil --get ComputerName | cut -d" " -f2-)
	brew bundle dump --force --file "$BREWDUMP_PATH/Brewfile_$device_name"
	npm list --location=global --parseable | sed "1d" | sed -E "s/.*\///" > "$BREWDUMP_PATH/NPMfile_$device_name"
	pip3 list --not-required | tail -n+3 | grep -vE "Pillow|pip|pybind|setuptools|six|wheel" | cut -d" " -f1 > "$BREWDUMP_PATH/Pip3file_$device_name"
	echo "Brewfile, Pip3File & NPM-File dumped at \"$BREWDUMP_PATH\""
}

function update (){
	print-section "HOMEBREW"
	brew update
	brew upgrade
	print-section "Cleanup"
	brew cleanup

	print-section "MAC APP STORE"
	mas upgrade

	print-section "NPM"
	npm update --location=global

	print-section "Pip3"
	pip3 install --upgrade "pdfannots"
	pip3 install --upgrade "pdfminer.six"
	pip3 install --upgrade "alacritty-colorscheme"

	print-section "DUMP INSTALLS"
	dump
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
