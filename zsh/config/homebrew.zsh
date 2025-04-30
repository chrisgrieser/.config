# DOCS https://docs.brew.sh/Manpage#environment
#───────────────────────────────────────────────────────────────────────────────
export HOMEBREW_CASK_OPTS="--no-quarantine"
export HOMEBREW_DISPLAY_INSTALL_TIMES=1

export HOMEBREW_AUTO_UPDATE_SECS=86400 # once per day
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=60
export HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=30

export HOMEBREW_BUNDLE_FILE="$HOME/.config/Brewfile"
export HOMEBREW_BUNDLE_NO_UPGRADE=1 # brew bundle install does not upgrade

# extra update for the Obsidian, installer version, cause brew won't update as
# the main app is self-upgrading
export HOMEBREW_UPGRADE_GREEDY_CASKS="obsidian"

export HOMEBREW_COLOR=1 # force color output even for tty
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

#───────────────────────────────────────────────────────────────────────────────

alias bh='brew home'
alias bi='brew install'
alias br='brew reinstall'
alias bu='brew uninstall --zap'
alias depending_on='brew uses --installed --recursive'

#───────────────────────────────────────────────────────────────────────────────

function _print-section() {
	[[ "$2" != "first" ]] && echo
	defaults read -g AppleInterfaceStyle &> /dev/null && fg="\e[1;30m" || fg="\e[1;37m"
	print "$fg\e[1;44m $1 \e[0m"
}

#───────────────────────────────────────────────────────────────────────────────

function update() {
	_print-section "brew update" "first"
	brew update # update homebrew itself

	_print-section "brew bundle install" # install missing packages
	if ! brew bundle check; then
		brew bundle install | grep -v "^Using"
	fi

	_print-section "brew bundle cleanup" # remove unused packages
	if ! brew bundle cleanup; then
		brew bundle cleanup --force --zap
	else
		echo "No unused packages found."
	fi

	_print-section "brew upgrade"
	if ! brew outdated; then
		brew upgrade
	else
		echo "All packages already up-to-date."
	fi

	_print-section "mas upgrade"
	if ! mas outdated; then
		mas upgrade
	else
		echo "All packages already up-to-date."
	fi

	# sketchybar restart for new permissions
	sketchybar_was_updated=$(find "$HOMEBREW_PREFIX/bin/sketchybar" -mtime -1h)
	[[ -n "$sketchybar_was_updated" ]] && brew services restart sketchybar

	"$ZDOTDIR/notificator" --title "🍺 Homebrew" --message "Update finished." --sound "Blow"
}

function listall() {
	_print-section "brew info" "first"
	brew info

	_print-section "brew doctor"
	brew doctor

	_print-section "brew services list"
	brew services list

	_print-section "brew taps"
	brew tap | rs

	_print-section "brew leaves --installed-on-request"
	brew leaves --installed-on-request | rs

	_print-section "brew list --casks"
	brew list --casks

	_print-section "mas list"
	mas list
}

# $1: count of formulae/casks to list
function recent_updates() {
	local default_count=10
	local count=${1:-$default_count}
	_print-section "Recently updated formulae"
	brew list -t --formulae | head -n"$count" | rs
	_print-section "Recently updated casks"
	brew list -t --casks | head -n"$count" | rs
}
