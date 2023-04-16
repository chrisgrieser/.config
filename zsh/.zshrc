# shellcheck disable=1090
#───────────────────────────────────────────────────────────────────────────────
# remove last login message for some terminals https://stackoverflow.com/a/69915614
# printf '\33c\e[3J'

CONFIG_FILES=(
	load_plugins
	general_and_plugin_configs
	terminal_utils
	terminal_keybindings
	vi_mode
	aliases
	history_config
	fzf_tab_settings
	docs_man
	git_github
	homebrew
	lazyload_cli_completions
)

# no intro messages for embedded terminals, since I use them with lower height
if [[ "$TERM_PROGRAM" == "WezTerm" ]] ; then
	CONFIG_FILES+=('intro_messages')
fi 

#───────────────────────────────────────────────────────────────────────────────

for config_file in "${CONFIG_FILES[@]}"; do
	source "$DOTFILE_FOLDER/zsh/$config_file.zsh"
done

#───────────────────────────────────────────────────────────────────────────────
# shell integration for wezterm https://github.com/wez/wezterm/blob/main/assets/shell-integration/wezterm.sh
source "$DOTFILE_FOLDER/zsh/semantic_prompts.sh"

