#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

if ! command -v rg &>/dev/null; then echo "ripgrep not installed." && exit 1; fi

url=$(echo "$*" | xargs) # remove trailing blankline
repoName=$(echo "$url" | cut -d/ -f5)

cache="/tmp/$repoName"
cd /tmp/ || exit 1

modified_recently=$(find "$cache" -mmin -120)

if [[ -z "$modified_recently" ]]; then
	[[ -e "$cache" ]] && rm -rf "$cache" # remove outdated cache

	# (re-)download repo
	giturl="$(echo "$url" | sed -E 's/https?:\/\/github.com\//git@github.com:/').git" # turn http url into github ssh remote address
	git clone --depth=1 --single-branch "$giturl" # shallow clone
else
	touch "$cache" # to update modification time
fi

cd "./$repoName" || exit 1

QUERY="local"
if ! pgrep "neovide"; then
	open -a "Neovim" # opens neovide frameless
	while ! pgrep "neovide"; do sleep 0.1 ; done
	sleep 1
fi

echo "vim.cmd([[cd $cache | grep $QUERY]])" >"/tmp/nvim-automation" # this part requires the setup in /lua/file-watcher.lua
osascript -e 'tell application "Neovide" to activate'
