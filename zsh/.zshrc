printf '\33c\e[3J' # remove last login message https://stackoverflow.com/a/69915614

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
CONFIG+=('alacritty_theme_utilities')
CONFIG+=('intro-messages')

# Terminal specific
if [[ $TERM != "xterm-256color" ]]; then
	CONFIG+=('vi-mode') # don't use vi mode
elif [[ $TERM == "Warp" ]]; then
	cd "$WD" || return # working directory for Warp
fi

for config_file in "${CONFIG[@]}"; do
	# shellcheck disable=1090
	source "$DOTFILE_FOLDER/zsh/$config_file.zsh"
done
