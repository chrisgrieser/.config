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

# bun completions
[ -s "/Users/chrisgrieser/.bun/_bun" ] && source "/Users/chrisgrieser/.bun/_bun"
