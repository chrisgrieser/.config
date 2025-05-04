# DOCS https://docs.brew.sh/Manpage#environment
#───────────────────────────────────────────────────────────────────────────────
export HOMEBREW_CASK_OPTS="--no-quarantine"
export HOMEBREW_INSTALL_BADGE="󱄖 "
export HOMEBREW_BUNDLE_FILE="$HOME/.config/Brewfile"
export HOMEBREW_UPGRADE_GREEDY_CASKS="obsidian" # to also update installer version
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

#───────────────────────────────────────────────────────────────────────────────

alias bi='brew install'
alias bu='brew uninstall --zap'
alias br='brew reinstall'
alias dr='brew doctor'
alias depending_on='brew uses --installed --recursive'

#───────────────────────────────────────────────────────────────────────────────

function pretty_header() {
	[[ "$2" != "no-line-break" ]] && echo
	defaults read -g AppleInterfaceStyle &> /dev/null && fg="\e[1;30m" || fg="\e[1;37m"
	bg="\e[1;44m"
	print "$fg$bg $1 \e[0m"
}

function update() {
	pretty_header "brew update" "no-line-break"
	brew update # update homebrew itself

	pretty_header "brew bundle"
	if ! brew bundle check || brew bundle cleanup &> /dev/null; then
		export HOMEBREW_COLOR=1                      # force color when piping output
		brew bundle install --verbose --cleanup --upgrade --zap | # `--verbose` shows progress
			grep --invert-match --extended-regexp "^Using |^Skipping install of "
	fi

	pretty_header "mas upgrade"
	if [[ -n $(mas outdated) ]]; then
		mas upgrade
	else
		echo "Already up-to-date."
	fi

	# sketchybar restart for new permissions
	sketchybar_was_updated=$(find "$HOMEBREW_PREFIX/bin/sketchybar" -mtime -1h)
	[[ -n "$sketchybar_was_updated" ]] && brew services restart sketchybar

	"$ZDOTDIR/notificator" --title "🍺 Homebrew" --message "Update finished." --sound "Blow"
}
