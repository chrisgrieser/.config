# remove last login message that some terminals leave https://stackoverflow.com/a/69915614
printf '\33c\e[3J'
#-------------------------------------------------------------------------------

CONFIG_FILES=(
	keybindings_and_vim_mode # loaded before starship, so vi-prompt is set correctly
	plugins
	cli_settings

	options
	navigation
	completion
	terminal_utils
	aliases
	docs_man
	ai_help

	git_github
	homebrew
	python
)
[[ "$OSTYPE" =~ "darwin" ]] && CONFIG_FILES+=(mac_specific)

#───────────────────────────────────────────────────────────────────────────────

for filename in "${CONFIG_FILES[@]}"; do
	# shellcheck disable=1090
	source "$ZDOTDIR/config/$filename.zsh"
done

