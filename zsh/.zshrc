# shellcheck disable=1090
#───────────────────────────────────────────────────────────────────────────────
# remove last login message for some terminals https://stackoverflow.com/a/69915614
# printf '\33c\e[3J'

CONFIG_FILES=(
	load_plugins
	terminal_utils
	aliases
	history_config
	general_and_plugin_configs
	# completions # not in use when using fzf-tab
	fzf-tab-settings
	terminal_keybindings
	docs_man
	git_github
	homebrew
	vi_mode
	lazyload-cli-completions
)

# no intro messages for embedded terminals, since I use them with lower height
[[ "$TERM_PROGRAM" == "WezTerm" ]] && CONFIG_FILES+=('intro_messages')

#───────────────────────────────────────────────────────────────────────────────

for config_file in "${CONFIG_FILES[@]}"; do
	source "$DOTFILE_FOLDER/zsh/$config_file.zsh"
done

#───────────────────────────────────────────────────────────────────────────────
# shell integration for wezterm https://github.com/wez/wezterm/blob/main/assets/shell-integration/wezterm.sh
source "$DOTFILE_FOLDER/zsh/semantic_prompts.sh"

