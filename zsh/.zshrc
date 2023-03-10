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

# Terminal specific
# INFO if $TERM is not set for alacritty, reinstall alacritty, which
# recreates the required ~/.terminfo directory.
[[ "$TERM" == "alacritty" ]] && CONFIG_FILES+=('alacritty_theme_utilities')
[[ "$TERM" != "xterm-256color" ]] && CONFIG_FILES+=('intro-messages')

for config_file in "${CONFIG_FILES[@]}"; do
	# shellcheck disable=1090
	source "$DOTFILE_FOLDER/zsh/$config_file.zsh"
done
