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
	print "\033[1;30m$sep\033[0m"
}

function _gitlog {
	repo=$(git remote get-url origin | sed -Ee 's/git@github.com://' -Ee 's/\.git$//')

	# pseudo-option to suppress graph
	local graph
	if [[ "$1" == "--no-graph" ]]; then
		shift
		graph=""
	else
		graph="--graph"
	fi

	# INFO inserting ansi colors via `sed` requires $'string'
	git log --all --color $graph \
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
			-Ee $'s/ (release|bump|publish|init|bot):/ \033[1;32m\\1\033[0;38;5;245m:\033[0m/' \
			-Ee $'s/ (fix|refactor|build|ci|docs|feat|style|test|perf|chore|revert|break|improv)(\\(.+\\))?(!?):/ \033[1;35m\\1\033[1;36m\\2\033[7;31m\\3\033[0;38;5;245m:\033[0m/' \
			-Ee $'s/ (fixup|squash)!/\033[1;32m&\033[0m/g' \
			-Ee $'s/`[^`]*`/\033[0;36m&\033[0m/g' \
			-Ee $'s/#[0-9]+/\033[0;31m&\033[0m/g' \
			-Ee "s_([a-f0-9]{7,40})_\x1b]8;;https://github.com/${repo}/commit/\1\x1b\\\\\1\x1b]8;;\x1b\\\\_"
		# INFO last replacements adds hyperlinks to hashes
}

function _list_files_here {
	if [[ ! -x "$(command -v eza)" ]]; then print "\033[0;33mMagic Dashboard: \`eza\` not installed.\033[0m" && return 1; fi

	local eza_output
	eza_output=$(
		eza --width="$COLUMNS" --all --grid --color=always --icons \
			--git-ignore --ignore-glob=".DS_Store" \
			--sort=oldest --group-directories-first --no-quotes \
			--git --long --no-user --no-permissions --no-filesize --no-time
	)
	# not using --hyperlink PENDING https://github.com/eza-community/eza/issues/693

	if [[ $(echo "$eza_output" | wc -l) -gt $max_files_lines ]]; then
		local shortened
		shortened="$(echo "$eza_output" | head -n"$max_files_lines")"
		printf "%s   \033[1;30m...\033[0m" "$shortened"
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
				-e $'s/\\(gone\\)/\033[0;31mD     \033[0m/' \
				-e $'s/\\(new\\)/\033[0;32mN    \033[0m/' \
				-e $'s/(\\(new .*\\))/\033[0;34m\\1\033[0m/' \
				-e 's/ Bin /    /' \
				-e $'s/ \\| Unmerged /  \033[1;31m  \033[0m /' \
				-Ee $'s|([^/+]*)(/)|\033[0;36m\\1\033[0;33m\\2\033[0m|g' \
				-e $'s/^\\+/\033[1;35m 󰐖\033[0m /' \
				-e $'s/ \\|/ \033[1;30m│\033[0m/'
		_separator
	fi
}

#───────────────────────────────────────────────────────────────────────────────

# show files + git status + brief git log
function _magic_dashboard {
	# check if pwd still exists
	if [[ ! -d "$PWD" ]]; then
		printf '\033[0;33m"%s" has been moved or deleted.\033[0m\n' "$(basename "$PWD")"
		if [[ -d "$OLDPWD" ]]; then
			print '\033[0;33mMoving to last directory.\033[0m\n'
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
	[[ "$(eza --git-ignore | wc -l)" -gt 0 ]] && echo
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
