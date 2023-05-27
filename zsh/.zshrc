# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
#───────────────────────────────────────────────────────────────────────────────
# GENERAL CONFIGS
CONFIG_FILES=(
	load_plugins
	general_and_plugin_configs
	terminal_utils
	terminal_keybindings
	vi_mode
	aliases
	history_config
	# fzf_tab_settings
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
# TERMINAL SPECIFIC

if [[ "$TERM_PROGRAM" == "WezTerm" ]] ; then
	# shell integration for wezterm 
	# https://github.com/wez/wezterm/blob/main/assets/shell-integration/wezterm.sh
	source "$DOTFILE_FOLDER/zsh/semantic_prompts.sh"
else
	# remove last login message that some terminals leave 
	# https://stackoverflow.com/a/69915614
	printf '\33c\e[3J'
fi

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
