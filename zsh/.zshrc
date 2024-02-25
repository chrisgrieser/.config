# vim: filetype=sh
CONFIG_FILES=(
	load_plugins
	plugin_cli_settings

	options
	navigation
	completion
	keybindings_and_vim_mode
	terminal_utils
	aliases
	docs_man

	git_github
	homebrew
	python_pip

	intro_message
)
[[ "$OSTYPE" =~ "darwin" ]] && CONFIG_FILES+=(mac_specific)

#───────────────────────────────────────────────────────────────────────────────

for filename in "${CONFIG_FILES[@]}"; do
	# shellcheck disable=1090
	source "$ZDOTDIR/config/$filename.zsh"
done

# remove last login message that some terminals leave https://stackoverflow.com/a/69915614
[[ "$TERM_PROGRAM" == "WezTerm" ]] || printf '\33c\e[3J'
