CONFIG_FILES=(
	keybindings_and_vim_mode # must be loaded before starship, so vi-prompt is set correctly
	load_plugins
	plugin_cli_settings

	options
	navigation
	completion
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
