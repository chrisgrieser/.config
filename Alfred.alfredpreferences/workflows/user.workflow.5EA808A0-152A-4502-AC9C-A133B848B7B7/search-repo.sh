#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

if ! command -v rg &>/dev/null; then echo "ripgrep not installed." && exit 1; fi

url=$(echo "$*" | xargs) # remove trailing blankline
repoName=$(echo "$url" | cut -d/ -f5)
cache="/tmp/$repoName"
modified_recently=$(find "$cache" -mmin -60)

if [[ -z "$modified_recently" ]]; then
	[[ -e "$cache" ]] && rm -rf "$cache" # remove outdated cache

	# (re-)download repo
	giturl="$(echo "$url" | sed -E 's/https?:\/\/github.com\//git@github.com:/').git" # turn http url into github ssh remote address
	cd /tmp/ || exit 1
	git clone --depth=1 --single-branch "$giturl" # shallow clone
else
	touch "$cache" # to update modification time
fi

cd "./$repoName" || exit 1
#
# if pgrep "neovide"; then
# 	# echo "cmd[[edit $LINE $file]]" >"/tmp/nvim-automation" # this part requires the setup in /lua/file-watcher.lua
# 	osascript -e 'tell application "Neovide" to activate'
# else
# 	# shellcheck disable=2086
# 	neovide --geometry=101x32 --notabs --frame="buttonless" $LINE "$file"
# fi
#
