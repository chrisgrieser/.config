CONFIG_FILES=(
	load_plugins
	options_and_plugin_configs
	completion
	navigation
	vim_mode_config
	terminal_utils
	terminal_keybindings
	aliases
	history_config
	docs_man
	git_github
	json_utils
	homebrew
	node_npm
	python_pip
	intro_messages
)
[[ "$OSTYPE" =~ "darwin" ]] && CONFIG_FILES+=(mac_specific)

# https://github.com/wez/wezterm/blob/main/assets/shell-integration/wezterm.sh
[[ "$TERM_PROGRAM" == "WezTerm" ]] && CONFIG_FILES+=("plugins/wezterm_semantic_prompts")

#───────────────────────────────────────────────────────────────────────────────

for config_file in "${CONFIG_FILES[@]}"; do
	file="$ZDOTDIR/$config_file.zsh"
	# shellcheck disable=1090
	source "$file"
done

# remove last login message that some terminals leave
# https://stackoverflow.com/a/69915614
[[ "$TERM_PROGRAM" == "WezTerm" ]] || printf '\33c\e[3J'

#───────────────────────────────────────────────────────────────────────────────
