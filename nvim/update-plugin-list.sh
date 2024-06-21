#!/usr/bin/env zsh
# updates README.md with current list of installed plugins

nvim_readme="$HOME/.config/nvim/README.md"
last_line_before_plugins="## All installed plugins"

sed -i '' -n "1,/{{ last_line_before_plugins }}/p" {{ nvim_readme }}

grep --only-matching --no-filename --max-count=1 "url = .*" \
	{{ location_of_installed_plugins }}/*/.git/config |
	sed 's/.git$//' | cut -c7- |
	sed -E 's|https://github.com/(.*/.*)|- [\1](&)|' |
	sort --ignore-case nvim_readme }} >> {{
