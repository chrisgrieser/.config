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

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

#───────────────────────────────────────────────────────────────────────────────

alias bh='brew home'
alias bi='brew install'
alias br='brew reinstall'
alias bu='brew uninstall --zap'
alias depending_on='brew uses --installed --recursive'

#───────────────────────────────────────────────────────────────────────────────

function pretty_header() {
	[[ "$2" != "no-line-break" ]] && echo
	local fg bg
	defaults read -g AppleInterfaceStyle &> /dev/null && fg="\e[1;30m" || fg="\e[1;37m"
	bg="\e[1;44m"
	print "$fg$bg $1 \e[0m"
}

#───────────────────────────────────────────────────────────────────────────────

function update() {
	pretty_header "brew update" "no-line-break"
	brew update # update homebrew itself, based on HOMEBREW_AUTO_UPDATE_SECS

	pretty_header "brew bundle install"
	if ! brew bundle check; then
		export HOMEBREW_COLOR=1                      # force color when piping output
		brew bundle install --verbose --no-upgrade | # `--verbose` shows installn progress
			grep --invert-match --extended-regexp "^Using |^Skipping install of "
	fi

	pretty_header "brew bundle cleanup"
	# not using `brew bundle install --cleanup`, since `brew bundle check` does
	# only check for missing installs, not excess installs
	if ! brew bundle cleanup &> /dev/null; then
		brew bundle cleanup --force --zap
	else
		echo "No unused packages found."
	fi

	pretty_header "brew upgrade"
	# not using `brew bundle install --upgrade`, simply to separate upgrades from
	# installs only visually
	if ! brew outdated; then
		brew upgrade
	else
		echo "No unused packages found."
	fi

	pretty_header "mas upgrade"
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
	pretty_header "brew info" "first"
	brew info

	pretty_header "brew doctor"
	brew doctor

	pretty_header "brew services list"
	brew services list

	pretty_header "brew taps"
	brew tap | rs

	pretty_header "brew leaves"
	brew leaves | rs

	pretty_header "brew list --casks"
	brew list --casks

	pretty_header "mas list"
	mas list
}

# $1: count of formulae/casks to list
function recent_updates() {
	local default_count=10
	local count=${1:-$default_count}
	pretty_header "Recently updated formulae"
	brew list -t --formulae | head -n"$count" | rs
	pretty_header "Recently updated casks"
	brew list -t --casks | head -n"$count" | rs
}
