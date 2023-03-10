# printf '\33c\e[3J' # remove last login message https://stackoverflow.com/a/69915614

CONFIG=()
CONFIG+=('load_plugins')
CONFIG+=('terminal_utils')
CONFIG+=('aliases')
CONFIG+=('history_config')
CONFIG+=('general_and_plugin_configs')
CONFIG+=('completions')
CONFIG+=('terminal-keybindings')
CONFIG+=('docs_man')
CONFIG+=('git_github')
CONFIG+=('homebrew')
CONFIG+=('vi-mode')

# Terminal specific
if [[ "$TERM" == "Warp" ]]; then
	cd "$WD" || return
elif [[ "$TERM" == "alacritty" ]]; then
	# INFO if $TERM is not set for alacritty, reinstall alacritty, which
	# recreates the required ~/.terminfo directory.
	CONFIG+=('alacritty_theme_utilities')
	CONFIG+=('intro-messages')
fi

for config_file in "${CONFIG[@]}"; do
	# shellcheck disable=1090
	source "$DOTFILE_FOLDER/zsh/$config_file.zsh"
done
