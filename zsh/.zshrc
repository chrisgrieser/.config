CONFIG_FILES=(
	load_plugins
	general_and_plugin_configs
	fzf-tab_and_completion_settings
	terminal_utils
	terminal_keybindings
	# vi_mode
	aliases
	history_config
	docs_man
	git_github
	homebrew
	intro_messages
)

for config_file in "${CONFIG_FILES[@]}"; do
	# shellcheck disable=1090
	source "$DOTFILE_FOLDER/zsh/$config_file.zsh"
done

#───────────────────────────────────────────────────────────────────────────────

if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
	# https://github.com/wez/wezterm/blob/main/assets/shell-integration/wezterm.sh shell integration for wezterm
	source "$DOTFILE_FOLDER/zsh/semantic_prompts.sh"
else
	# https://stackoverflow.com/a/69915614 remove last login message that some terminals leave
	printf '\33c\e[3J'
fi
