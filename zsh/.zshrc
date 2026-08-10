# remove last login message that some terminals leave https://stackoverflow.com/a/69915614
if [[ "$TERM_PROGRAM" != "WezTerm" ]]; then printf '\33c\e[3J'; fi

#-------------------------------------------------------------------------------

# https://github.com/versenilvis/IRIS#configuration-guide
# still a bit buggy (use of enter for accepting, etc.)
export USE_IRIS="false"

#-------------------------------------------------------------------------------

CONFIG_FILES=(
	keybindings_and_vim_mode # loaded before starship, so vi-prompt is set correctly
	plugins
	cli_settings

	options
	navigation
	terminal_utils
	aliases
	docs_man
	magic_dashboard

	git_github
	homebrew
	python
)
[[ "$OSTYPE" =~ "darwin" ]] && CONFIG_FILES+=(mac_specific)
[[ "$USE_IRIS" == "false" ]] && CONFIG_FILES+=(completion)

for filename in "${CONFIG_FILES[@]}"; do
	# shellcheck disable=1090
	source "$ZDOTDIR/config/$filename.zsh"
done
