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
	fzf-tab-settings
	terminal_keybindings
	docs_man
	git_github
	homebrew
	lazyload-cli-completions
)

# no intro messages for embedded terminals, since I use them with lower height
if [[ "$TERM_PROGRAM" == "WezTerm" ]] ; then
	CONFIG_FILES+=('intro_messages')
	CONFIG_FILES+=('vi_mode')
fi 

#───────────────────────────────────────────────────────────────────────────────

for config_file in "${CONFIG_FILES[@]}"; do
	source "$DOTFILE_FOLDER/zsh/$config_file.zsh"
done

#───────────────────────────────────────────────────────────────────────────────
# shell integration for wezterm https://github.com/wez/wezterm/blob/main/assets/shell-integration/wezterm.sh
source "$DOTFILE_FOLDER/zsh/semantic_prompts.sh"

