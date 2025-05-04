# DOCS https://docs.brew.sh/Manpage#environment
#───────────────────────────────────────────────────────────────────────────────
export HOMEBREW_CASK_OPTS="--no-quarantine"
export HOMEBREW_BUNDLE_FILE="$HOME/.config/Brewfile"
export HOMEBREW_UPGRADE_GREEDY_CASKS="obsidian" # to also update installer version
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_EDITOR="open" # open in default macOS text editor

alias bi='brew install'
alias bu='brew uninstall --zap'
alias br='brew reinstall'
alias bf='brew bundle edit' # opens [b]rew[f]ile with $HOMEBREW_EDITOR
alias bh='brew home'
alias depending_on='brew uses --installed --recursive'

#───────────────────────────────────────────────────────────────────────────────

function _pretty_header() {
	[[ "$2" != "no-line-break" ]] && echo
	defaults read -g AppleInterfaceStyle &> /dev/null && fg="\e[1;30m" || fg="\e[1;37m"
	bg="\e[1;44m"
	print "$fg$bg $1 \e[0m"
}

function update() {
	_pretty_header "brew update" "no-line-break"
	brew update # update homebrew itself

	_pretty_header "brew bundle install & cleanup"
	if ! brew bundle check &> /dev/null || ! brew bundle cleanup &> /dev/null; then
		export HOMEBREW_COLOR=1 # force color when piping output
		brew bundle install --verbose --no-upgrade --cleanup --zap |
			grep --invert-match --extended-regexp "^Using |^Skipping install of "
	else
		echo "✅ Brewfile satisfied."
	fi

	_pretty_header "brew upgrade"
	# not combined with `brew bundle install` to visually separate them
	if [[ -n $(brew outdated) ]]; then
		brew upgrade
	else
		echo "✅ Already up-to-date."
	fi

	_pretty_header "mas upgrade"
	if [[ -n $(mas outdated) ]]; then
		mas upgrade
	else
		echo "✅ Already up-to-date."
	fi

	# sketchybar restart for new permissions
	sketchybar_was_updated=$(find "$HOMEBREW_PREFIX/bin/sketchybar" -mtime -1h)
	[[ -n "$sketchybar_was_updated" ]] && brew services restart sketchybar

	"$ZDOTDIR/notificator" --title "🍺 Homebrew" --message "Update finished." --sound "Blow"
}
