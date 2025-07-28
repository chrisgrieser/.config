#!/usr/bin/env zsh

# CONFIG
max_gitlog_lines=${MAGIC_DASHBOARD_GITLOG_LINES:-6}
max_gitstatus_lines=${MAGIC_DASHBOARD_GITSTATUS_LINES:-12}
max_files_lines=${MAGIC_DASHBOARD_FILES_LINES:-4}
disabled_below_height=${MAGIC_DASHBOARD_DISABLED_BELOW_TERM_HEIGHT:-15}
#───────────────────────────────────────────────────────────────────────────────

# draws a separator line with terminal width
function _separator {
	local sep_char="─" # ─ ═
	local sep=""
	for ((i = 0; i < COLUMNS; i++)); do
		sep="$sep$sep_char"
	done
	print "\e[1;30m$sep\e[0m"
}

function _gitlog {
	repo=$(git remote --verbose | head -n1 | cut -f2 | cut -d' ' -f1 |
		sed -Ee 's/git@github.com://' -Ee 's/\.git$//')

	# pseudo-option to suppress graph
	local graph
	if [[ "$1" == "--no-graph" ]]; then
		shift
		graph=""
	else
		graph="--graph"
	fi

	# INFO inserting ansi colors via `sed` requires $'string'
	git log --color $graph \
		--format="%C(yellow)%h%C(red)%d%C(reset) %s %C(green)(%cr) %C(blue)%an%C(reset)" "$@" |
		sed -e 's/ seconds* ago)/s)/' \
			-e 's/ minutes* ago)/m)/' \
			-e 's/ hours* ago)/h)/' \
			-e 's/ days* ago)/d)/' \
			-e 's/ weeks* ago)/w)/' \
			-e 's/ months* ago)/mo)/' \
			-e 's/grafted/󰩫 /' \
			-e 's/origin\//󰞶  /g' \
			-e 's/upstream\//󰅧  /g' \
			-e 's/HEAD/󱍞/g' \
			-e 's/tag: / /g' \
			-e 's/ -> /   /g' \
			-e 's/\* /· /' \
			-Ee $'s/ ([a-z]+)(\\(.+\\))?(!?):/ \e[1;35m\\1\e[1;36m\\2\e[7;31m\\3\e[0;38;5;245m:\e[0m/' \
			-Ee $'s/`[^`]*`/\e[0;36m&\e[0m/g' \
			-Ee $'s/#[0-9]+/\e[0;31m&\e[0m/g' \
			-Ee "s_([a-f0-9]{7,40})_\x1b]8;;https://github.com/${repo}/commit/\1\x1b\\\\\1\x1b]8;;\x1b\\\\_"
		# INFO last replacements adds hyperlinks to hashes
}

function _list_files_here {
	if [[ ! -x "$(command -v eza)" ]]; then print "\e[0;33mMagic Dashboard: \`eza\` not installed.\e[0m" && return 1; fi

	# INFO eza needs to be called with directory: https://github.com/eza-community/eza/issues/1568#issuecomment-3116798039
	local eza_output
	eza_output=$(
		eza "." --width="$COLUMNS" --all --grid --color=always --icons \
			--git-ignore --ignore-glob=".DS_Store" \
			--sort=oldest --group-directories-first --no-quotes \
			--git --long --no-user --no-permissions --no-filesize --no-time
	)
	# not using --hyperlink PENDING https://github.com/eza-community/eza/issues/693

	if [[ $(echo "$eza_output" | wc -l) -gt $max_files_lines ]]; then
		local shortened
		shortened="$(echo "$eza_output" | head -n"$max_files_lines")"
		printf "%s   \e[1;30m...\e[0m" "$shortened"
	elif [[ -n "$eza_output" ]]; then
		echo -n "$eza_output"
	fi
}

function _gitstatus {
	# so git picks up new files
	git ls-files --others --exclude-standard | xargs -I {} git add --intent-to-add {} &> /dev/null

	if [[ -n "$(git status --porcelain)" ]]; then
		local unstaged staged
		unstaged=$(git diff --color="always" --compact-summary --stat=$COLUMNS | sed -e '$d')
		staged=$(git diff --staged --color="always" --compact-summary --stat=$COLUMNS | sed -e '$d' \
			-e $'s/^ /+/') # add marker for staged files
		local diffs
		if [[ -n "$unstaged" && -n "$staged" ]]; then
			diffs="$unstaged\n$staged"
		elif [[ -n "$unstaged" ]]; then
			diffs="$unstaged"
		elif [[ -n "$staged" ]]; then
			diffs="$staged"
		fi
		print "$diffs" | head -n"$max_gitstatus_lines" |
			sed -e 's/ => /   /' \
				-e $'s/\\(gone\\)/\e[0;31mD     \e[0m/' \
				-e $'s/\\(new\\)/\e[0;32mN    \e[0m/' \
				-e $'s/(\\(new .*\\))/\e[0;34m\\1\e[0m/' \
				-e 's/ Bin /    /' \
				-e $'s/ \\| Unmerged /  \e[1;31m  \e[0m /' \
				-Ee $'s|([^/+]*)(/)|\e[0;36m\\1\e[0;33m\\2\e[0m|g' \
				-e $'s/^\\+/\e[1;35m 󰐖\e[0m /' \
				-e $'s/ \\|/ \e[1;30m│\033[0m/'
		_separator
	fi
}

#───────────────────────────────────────────────────────────────────────────────

# show files + git status + brief git log
function _magic_dashboard {
	# check if pwd still exists
	if [[ ! -d "$PWD" ]]; then
		printf '\e[0;33m"%s" has been moved or deleted.\e[0m\n' "$(basename "$PWD")"
		if [[ -d "$OLDPWD" ]]; then
			print '\e[0;33mMoving to last directory.\e[0m\n'
			# shellcheck disable=2164
			cd "$OLDPWD"
		fi
		return 0
	fi

	# show dashboard
	if git rev-parse --is-inside-work-tree &> /dev/null; then
		_gitlog --max-count="$max_gitlog_lines"
		_separator
		_gitstatus
	fi
	_list_files_here
}

#───────────────────────────────────────────────────────────────────────────────

# Based on Magic-Enter by @dufferzafar (MIT License)
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/magic-enter

function _magic_enter {
	# GUARD only in PS1 and when BUFFER is empty
	# DOCS http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#User_002dDefined-Widgets
	[[ -z "$BUFFER" && "$CONTEXT" == "start" ]] || return 0

	# GUARD only when in terminal with sufficient height
	[[ $LINES -gt $disabled_below_height ]] || return 0

	# shellcheck disable=2012
	[[ "$(eza --git-ignore "." | wc -l)" -gt 0 ]] && echo
	_magic_dashboard
}

# WRAPPER FOR THE ACCEPT-LINE ZLE WIDGET (RUN WHEN PRESSING ENTER)
# If the wrapper already exists don't redefine it
type _magic_enter_accept_line &> /dev/null && return

widget_name="accept-line" # need to put into variable so `shfmt` does not break it

# shellcheck disable=2154
case "${widgets[$widget_name]}" in
# Override the current accept-line widget, calling the old one
user:*)
	zle -N _magic_enter_orig_accept_line "${widgets[$widget_name]#user:}"
	function _magic_enter_accept_line {
		_magic_enter
		zle _magic_enter_orig_accept_line -- "$@"
	}
	;;

	# If no user widget defined, call the original accept-line widget
builtin)
	function _magic_enter_accept_line {
		_magic_enter
		zle .accept-line
	}
	;;
esac

zle -N accept-line _magic_enter_accept_line
