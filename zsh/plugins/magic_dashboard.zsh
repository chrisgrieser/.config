#!/usr/bin/env zsh

# draws a separator line with terminal width
function _separator {
	local sep_char="═" # ─ ═
	local sep=""
	for ((i = 0; i < COLUMNS; i++)); do
		sep="$sep$sep_char"
	done
	print "\033[1;30m$sep\033[0m"
}

function _gitlog {
	# pseudo-option to suppress graph
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
			-e 's/upstream\//  /g' \
			-e 's/HEAD/󱍞 /g' \
			-e 's/tag: /  /' \
			-e 's/\* /∘ /' \
			-Ee $'s/ (improv|fix|refactor|build|ci|docs|feat|test|perf|chore|revert|break|style)(\\(.+\\)|!)?:/ \033[1;35m\\1\033[1;36m\\2\033[0m:/' \
			-Ee $'s/ (fixup|squash)!/\033[1;32m&\033[0m/g' \
			-Ee $'s/`[^`]*`/\033[1;36m&\033[0m/g' \
			-Ee $'s/#[0-9]+/\033[1;31m&\033[0m/g' # issue numbers
	# INFO inserting ansi colors via sed requires leading $
}

function _list_files_here {
	if [[ ! -x "$(command -v eza)" ]]; then print "\033[1;33mMagic Dashboard: \`eza\` not installed.\033[0m" && return 1; fi

	local max_files_lines=${MAGIC_DASHBOARD_FILES_LINES:-6}
	local eza_output
	eza_output=$(eza --width="$COLUMNS" --all --grid --color=always --icons \
		--git-ignore --ignore-glob=".DS_Store|Icon?" \
		--sort=name --group-directories-first --no-quotes \
		--git --long --no-user --no-permissions --no-filesize --no-time)

	if [[ $(echo "$eza_output" | wc -l) -gt $max_files_lines ]]; then
		local shortened
		shortened="$(echo "$eza_output" | head -n"$max_files_lines")"
		printf "%s \033[1;36m(…)\033[0m" "$shortened"
	elif [[ -n "$eza_output" ]]; then
		echo -n "$eza_output"
	fi
}

function _gitstatus {
	# so new files show up in `git diff`
	git ls-files --others --exclude-standard | xargs git add --intent-to-add &>/dev/null

	if [[ -n "$(git status --porcelain)" ]]; then
		local unstaged staged
		unstaged=$(git diff --color="always" --compact-summary --stat | sed -e '$d')
		staged=$(git diff --staged --color="always" --compact-summary --stat | sed -e '$d' \
			-e $'s/^ /+/') # add marker for staged files
		local diffs=""
		if [[ -n "$unstaged" && -n "$staged" ]]; then
			diffs="$unstaged\n$staged"
		elif [[ -n "$unstaged" ]]; then
			diffs="$unstaged"
		elif [[ -n "$staged" ]]; then
			diffs="$staged"
		fi
		print "$diffs" | sed \
			-e $'s/\\(gone\\)/\033[1;31mD     \033[0m/g' \
			-e $'s/\\(new\\)/\033[1;32mN    \033[0m/g' \
			-e 's/ Bin /    /g' \
			-e $'s/ \\| Unmerged /  \033[1;31m  \033[0m /'\
			-Ee $'s|([^/+]*)(/)|\033[1;36m\\1\033[1;33m\\2\033[0m|g' \
			-e $'s/^\\+/\033[1;35m \033[0m /' \
			-e $'s/ \\|/ \033[1;30m│\033[0m/g'
		_separator
	fi
}

#───────────────────────────────────────────────────────────────────────────────

# show files + git status + brief git log
function _magic_dashboard {
	# check if pwd still exists
	if [[ ! -d "$PWD" ]]; then
		printf '\033[1;33m"%s" has been moved or deleted.\033[0m\n' "$(basename "$PWD")"
		cd "$OLDPWD" || return 0
	fi

	if git rev-parse --is-inside-work-tree &>/dev/null; then
		local max_gitlog_lines=${MAGIC_DASHBOARD_GITLOG_LINES:-5}
		_gitlog -n "$max_gitlog_lines"
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
	local disabled_below_height=${MAGIC_DASHBOARD_DISABLED_BELOW_TERM_HEIGHT:-15}
	[[ $LINES -gt $disabled_below_height ]] || return 0

	echo && _magic_dashboard
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
			_magic_enter
			zle _magic_enter_orig_accept_line -- "$@"
		} ;;

		# If no user widget defined, call the original accept-line widget
	builtin) function _magic_enter_accept_line {
			_magic_enter
			zle .accept-line
		} ;;
esac

zle -N accept-line _magic_enter_accept_line
