printf '\33c\e[3J' # remove last login message https://stackoverflow.com/a/69915614

CONFIG_FILES=(
	load_plugins
	terminal_utils
	aliases
	history_config
	general_and_plugin_configs
	completions
	terminal-keybindings
	docs_man
	git_github
	homebrew
	vi-mode
)

[[ "$TERM_PROGRAM" == "WezTerm" ]] && CONFIG_FILES+=('intro-messages')

for config_file in "${CONFIG_FILES[@]}"; do
	# shellcheck disable=1090
	source "$DOTFILE_FOLDER/zsh/$config_file.zsh"
done
