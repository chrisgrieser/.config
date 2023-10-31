#!/usr/bin/env zsh

# draws a separator line with terminal width
function separator {
	local sep_char="═"           # ─ ═
	local sep_color="\033[1;30m" # black

	local sep=""
	for ((i = 0; i < COLUMNS; i++)); do
		sep="$sep$sep_char"
	done
	print "$sep_color$sep\033[0m"
}

function gitlog {
	# HACK pseudo-option to suppress graph
	if [[ "$1" == "--no-graph" ]]; then
		shift
		graph=""
	else
		graph="--graph"
	fi

	# shellcheck disable=2086
	git log --all --color $graph \
		--format="%C(yellow)%h%C(red)%d%C(reset) %s %C(green)(%cr) %C(bold blue)%an%C(reset)" "$@" |
		sed -e 's/ seconds* ago)/s)/' \
			-e 's/ minutes* ago)/m)/' \
			-e 's/ hours* ago)/h)/' \
			-e 's/ days* ago)/d)/' \
			-e 's/ weeks* ago)/w)/' \
			-e 's/ months* ago)/mo)/' \
			-e 's/grafted/ /' \
			-e 's/origin\//󰞶  /g' \
			-e 's/HEAD/󱍀 /g' \
			-e 's/->/󰔰 /g' \
			-e 's/tags: / )/' \
			-Ee $'s/ (improv|fix|refactor|build|ci|docs|feat|test|perf|chore|revert|break|style)(\\(.+\\)|!)?:/ \033[1;35m\\1\033[1;36m\\2\033[0m:/' \
			-Ee $'s/(`[^`]*`)/\033[1;36m\\1\033[0m/g' \
			-Ee $'s/(#[0-9]+)/\033[1;31m\\1\033[0m/g' # issue numbers
	# INFO inserting ansi colors via sed requires leading $
}

# show files + git status + brief git log
function inspect {
	if [[ ! -x "$(command -v git)" ]]; then print "\033[1;33mgit not installed.\033[0m" && return 1; fi
	if [[ ! -x "$(command -v eza)" ]]; then print "\033[1;33meza not installed.\033[0m" && return 1; fi
	if [[ ! -x "$(command -v rs)" ]]; then print "\033[1;33mrs not installed.\033[0m" && return 1; fi

	# check if pwd still exists
	if [[ ! -d "$PWD" ]]; then
		printf '\033[1;33m"%s" has been moved or deleted.\033[0m\n' "$(basename "$PWD")"
		command cd "$OLDPWD" || return 1
	fi

	# CONFIG
	local max_gitlog_lines=5
	local max_files_lines=6

	# GIT LOG
	if git rev-parse --is-inside-work-tree &>/dev/null; then
		gitlog -n "$max_gitlog_lines"
		separator
	fi

	# GIT STATUS
	if git rev-parse --is-inside-work-tree &>/dev/null && [[ -n "$(git status --short --porcelain)" ]]; then
		# show changed files in a more informative way than normal `git status`
		git diff --color="always" --compact-summary \
			--stat=$((COLUMNS / 2)),$((COLUMNS / 4)) | # half-width
			sed '$d' |         # remove summary
			rs -e -w"$COLUMNS" # reflow

		# untracked (new) files
		git status --short | grep "??" |         # select only untracked (new) files
			sed $'s/??/\033[1;32m [new]\033[0m/' |    # color them
			rs -e -w"$COLUMNS"                    # reflow

		separator
	fi

	# FILES
	local eza_output
	eza_output=$(eza --width="$COLUMNS" --all --grid --color=always --icons \
		--git-ignore --ignore-glob=".DS_Store|Icon?" \
		--sort=name --group-directories-first --no-quotes \
		--git --long --no-user --no-permissions --no-filesize --no-time)

	if [[ $(echo "$eza_output" | wc -l) -gt $max_files_lines ]]; then
		echo -n "$(echo "$eza_output" | head -n"$max_files_lines")"
		printf "\033[1;36m (…)\033[0m" # blue = eza's default folder color
	elif [[ -n "$eza_output" ]]; then
		echo -n "$eza_output"
	fi
}

#───────────────────────────────────────────────────────────────────────────────

# Based on Magic-Enter by @dufferzafar (MIT License)
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/magic-enter

function magic_enter {
	# GUARD only in PS1 and when BUFFER is empty
	# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#User_002dDefined-Widgets
	[[ -z "$BUFFER" && "$CONTEXT" == "start" ]] || return

	# GUARD only when in terminal with sufficient height
	local disabled_below_term_height=15
	[[ $LINES -gt $disabled_below_term_height ]] || return

	echo && inspect
}

# WRAPPER FOR THE ACCEPT-LINE ZLE WIDGET (RUN WHEN PRESSING ENTER)
# If the wrapper already exists don't redefine it
type _magic_enter_accept_line &>/dev/null && return

# WARN running the `shfmt` on this section will break it
# shellcheck disable=2154
case "${widgets[accept-line]}" in
		# Override the current accept-line widget, calling the old one
	user:*) zle -N _magic_enter_orig_accept_line "${widgets[accept-line]#user:}"
		function _magic_enter_accept_line {
			magic_enter
			zle _magic_enter_orig_accept_line -- "$@"
		} ;;

		# If no user widget defined, call the original accept-line widget
	builtin) function _magic_enter_accept_line {
			magic_enter
			zle .accept-line
		} ;;
esac

zle -N accept-line _magic_enter_accept_line
