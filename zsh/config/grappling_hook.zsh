# CYCLE THROUGH DIRECTORIES

function _grappling_hook {
	# CONFIG some perma-repos & desktop
	local some_perma_repos to_open locations_count dir locations
	some_perma_repos=$(cut -d, -f2 "$HOME/.config/perma-repos.csv" | sed "s|^~|$HOME|" | head -n3)
	locations="$HOME/Desktop\n$some_perma_repos"

	to_open=$(echo "$locations" | sed -n "1p")
	locations_count=$(echo "$locations" | wc -l)

	for ((i = 1; i <= locations_count - 1; i++)); do
		dir=$(echo "$locations" | sed -n "${i}p")
		[[ "$PWD" == "$dir" ]] && to_open=$(echo "$locations" | sed -n "$((i + 1))p")
	done
	cd -q "$to_open" || return 1
	zle reset-prompt

	# so wezterm knows we are in a new directory
	[[ "$TERM_PROGRAM" == "WezTerm" ]] && wezterm set-working-directory
}

zle -N _grappling_hook
bindkey "^O" _grappling_hook # bound to cmd+enter via wezterm
