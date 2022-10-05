# shellcheck disable=SC1091,SC1090

CONFIG=()
CONFIG+=('load_plugins')
CONFIG+=('terminal_utils')
CONFIG+=('aliases')
CONFIG+=('history_config')
CONFIG+=('general_and_plugin_configs')
CONFIG+=('completions')
CONFIG+=('keybindings')
CONFIG+=('vi-mode')
CONFIG+=('docs_man')
CONFIG+=('git_github')
CONFIG+=('homebrew')
CONFIG+=('alacritty_theme_utilities')
CONFIG+=('../pandoc/pandoc')
CONFIG+=('intro-messages')

for config_file in "${CONFIG[@]}"; do
	source "$DOTFILE_FOLDER/zsh/$config_file.zsh"
done


