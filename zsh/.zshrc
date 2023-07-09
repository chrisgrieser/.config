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

# https://github.com/wez/wezterm/blob/main/assets/shell-integration/wezterm.sh shell integration for wezterm
[[ "$TERM_PROGRAM" == "WezTerm" ]] && CONFIG_FILES+=(semantic_prompts)

#───────────────────────────────────────────────────────────────────────────────

for config_file in "${CONFIG_FILES[@]}"; do
	# shellcheck disable=1090
	source "$DOTFILE_FOLDER/zsh/$config_file.zsh"
done


# https://stackoverflow.com/a/69915614 remove last login message that some terminals leave
[[ "$TERM_PROGRAM" != "WezTerm" ]] && printf '\33c\e[3J'
