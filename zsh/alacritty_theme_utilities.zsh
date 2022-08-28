# shellcheck disable=SC2012,SC2016,SC2002

# switch alacritty color scheme. requires `fzf` and `alacritty-colorscheme`
# (pip package). save alacritty themes in ~/.config/alacritty/colors, download
# from https://github.com/eendroroy/alacritty-theme
function t(){
	local selected colordemo original
	local alacritty_color_schemes=~/.config/alacritty/colors
	original=$(alacritty-colorscheme status | cut -d. -f1)
	read -r -d '' colordemo << EOM
\033[1;30mblack  \033[0m  \033[1;40mblack   \033[0m
\033[1;31mred    \033[0m  \033[1;41mred     \033[0m
\033[1;32mgreen  \033[0m  \033[1;42mgreen   \033[0m
\033[1;33myellow \033[0m  \033[1;43m\033[1;30myellow  \033[0m
\033[1;34mblue   \033[0m  \033[1;44mblue    \033[0m
\033[1;35mmagenta\033[0m  \033[1;45mmagenta \033[0m
\033[1;36mcyan   \033[0m  \033[1;46m\033[1;30mcyan    \033[0m
\033[1;37mwhite  \033[0m  \033[1;47m\033[1;30mwhite   \033[0m
EOM

	# --preview-window=0 results in a hidden preview window, with the preview
	# command still taking effect. together, they create a "live-switch" effect
	selected=$(ls "$alacritty_color_schemes"  | sort --random-sort | cut -d. -f1 | fzf \
					-0 -1 \
					--query="$*" \
					--expect=ctrl-y,ctrl-e \
					--cycle \
					--ansi \
					--height=10 \
					--border=sharp \
					--bind='ctrl-d:reload(ls "$alacritty_color_schemes"  | sort --random-sort | cut -d. -f1)' \
					--header-first --header="[$original]  ⌃E: edit, ⌃Y: copy, ⌃D: del, esc: keep original" \
					--layout=reverse \
					--info=inline \
					--preview-window="left,16,border-right" \
					--preview="alacritty-colorscheme apply {}.yaml || alacritty-colorscheme apply {}.yml ; echo \"$colordemo\"" \
	         )

	# re-apply original color scheme when aborting
	if [[ -z "$selected" ]] ; then
		alacritty-colorscheme apply "$original.yaml" || alacritty-colorscheme apply "$original.yml"
		return 0
	fi

	key_pressed=$(echo "$selected" | head -n1)
	selected=$(echo "$selected" | tail -n+2)
	theme_path="$alacritty_color_schemes/$selected"

	if [[ "$key_pressed" == "ctrl-y" ]] ; then
		echo "Yaml for '$selected' copied."
		cat "$theme_path.yaml" || cat "$theme_path.yml" | pbcopy
	elif [[ "$key_pressed" == "ctrl-e" ]] ; then
		open "$theme_path.yaml" || open "$theme_path.yml"
	else
		alacritty-colorscheme apply "$selected.yaml" || alacritty-colorscheme apply "$selected.yml"
	fi
}

function opa {
	local original values alacritty_config
	alacritty_config="$HOME/.config/alacritty/alacritty.yml"
	original=$(grep --max-count=1 "opacity" "$alacritty_config" | cut -d: -f2 | xargs)
	values=$(for i in $(seq 99 70); do echo "scale=2 ; $i / 100" | bc ; done)
	values="1.0\n$values"

	# --preview-window=0 → don't show a preview window, bur run `--preview`
	# --disabled and --bind → don't search, but use vim bindings instead
	selected=$(echo "$values" | fzf \
					--disabled --bind="k:up,j:down,g:first,G:last" \
					--height=10 \
					--header-first --header="at start: $original" \
					--layout=reverse \
					--info=hidden \
					--preview-window=0 \
					--preview="sed -i '' 's/opacity: .*/opacity: {}/' '$alacritty_config'" \
	         )

	if [[ -z "$selected" ]]; then
		sed -i '' "s/opacity: .*/opacity: $original/" "$alacritty_config"
		return 0
	fi

	sed -i '' "s/opacity: .*/opacity: $selected/" "$alacritty_config"
	echo "now: $selected"
}
