# DOCS https://docs.brew.sh/Manpage#environment
#───────────────────────────────────────────────────────────────────────────────
export HOMEBREW_CASK_OPTS="--no-quarantine"
export HOMEBREW_BUNDLE_FILE="$HOME/.config/Brewfile"
export HOMEBREW_UPGRADE_GREEDY_CASKS="obsidian" # to also update installer version
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_EDITOR="open"           # open in default macOS text editor
export HOMEBREW_DISPLAY_INSTALL_TIMES=1 # also serves as summary what was installed

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

	_pretty_header "brew bundle install"
	if ! brew bundle check --no-upgrade &> /dev/null; then
		export HOMEBREW_COLOR=1                      # force color when piping output
		brew bundle install --verbose --no-upgrade | # `--verbose` shows progress
			grep --invert-match --extended-regexp "^Using |^Skipping install of "
	else
		echo "✅ Brewfile satisfied."
	fi

	_pretty_header "brew bundle cleanup"
	# not using `brew bundle install --cleanup`, since `brew bundle check` does
	# only check for missing installs, not excess installs
	if ! brew bundle cleanup &> /dev/null; then
		brew bundle cleanup --force --zap
	else
		echo "✅ No unused packages."
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

	# 10% of the time, run `brew doctor`, just to check if everything is fine
	if ((RANDOM % 100 < 10)); then
		_pretty_header "brew doctor"
		brew doctor
	fi

	"$ZDOTDIR/notificator" --title "🍺 Homebrew" --message "Update finished." --sound "Blow"
}
