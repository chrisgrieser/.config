# DOCS https://docs.brew.sh/Manpage#environment
#───────────────────────────────────────────────────────────────────────────────
export HOMEBREW_CASK_OPTS="--no-quarantine"
export HOMEBREW_DISPLAY_INSTALL_TIMES=1
export HOMEBREW_AUTO_UPDATE_SECS=86400 # only once per day

export HOMEBREW_CLEANUP_MAX_AGE_DAYS=60
export HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=30

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

device_name=$(scutil --get ComputerName | cut -d" " -f2-)
export HOMEBREW_BUNDLE_FILE="$HOME/.config/.installed-apps-and-packages/Brewfile_$device_name.txt"

# extra update for the Obsidian, installer version, cause brew won't update as
# the main app is self-upgrading
export HOMEBREW_UPGRADE_GREEDY_CASKS="obsidian"

#───────────────────────────────────────────────────────────────────────────────

alias bh='brew home'
alias bi='brew install'
alias br='brew reinstall'
alias bu='brew uninstall --zap'
alias depending_on='brew uses --installed --recursive'

#───────────────────────────────────────────────────────────────────────────────

# $1: count of formulae/casks to list, defaults to 6
function recent_updates() {
	local count=${1:-10}
	_print-section "Recently updated Formulae"
	brew list -t --formulae | head -n"$count" | rs

	_print-section "Recently updated Casks"
	brew list -t --casks | head -n"$count" | rs
}

# $1: title $2: no leading newline
function _print-section() {
	[[ -z "$2" ]] && echo
	print "\e[1;34m$1\e[0m"
	_separator
}

#───────────────────────────────────────────────────────────────────────────────

function update() {
	_print-section "Homebrew" 1
	brew update
	brew upgrade
	brew cleanup

	_print-section "Mac App Store"
	if [[ -n $(mas outdated) ]] ; then
		mas upgrade
	else
		echo "No Mac App Store updates available."
	fi

	# FINISH
	# sketchybar restart for new permissions
	sketchybar_was_updated=$(find "$HOMEBREW_PREFIX/bin/sketchybar" -mtime -1h)
	[[ -n "$sketchybar_was_updated" ]] && brew services restart sketchybar

	"$ZDOTDIR/notificator" --title "🍺 Homebrew" --message "Update finished." --sound "Blow"
}

function listall() {
	_print-section "brew info & doctor" 1
	brew info
	brew doctor

	_print-section "brew services list"
	brew services list

	_print-section "brew taps"
	brew tap | rs

	_print-section "brew leaves"
	brew leaves | rs

	_print-section "brew list --casks"
	brew list --casks

	_print-section "mas list"
	mas list

	brew bundle dump --force && print "\n\e[0;38;5;247mBrewfile saved.\e[0m"
}
