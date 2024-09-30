# Homebrew Setup
if [[ $(uname -p) == "arm" ]]; then
	eval "$(/opt/homebrew/bin/brew shellenv)" # M1 Mac
else
	eval "$(/usr/local/bin/brew shellenv)" # Intel mac
fi

#───────────────────────────────────────────────────────────────────────────────
# NPM
# do not crowd `$HOME`. (Set in .zprofile, so it's also applied to Neovide.)
export npm_config_cache="$HOME/.cache/npm" 
