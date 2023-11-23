#!/usr/bin/env zsh

alias co='git checkout'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'

alias gd='git diff'
alias gt='git stash push && git stash show 0'
alias gT='git stash pop'
alias grh='git reset --hard'

alias push='git push'
alias pull='git pull'
alias rebase='git rebase --interactive'
alias unshallow='git fetch --unshallow' # make shallow clone complete again
alias unlock='rm -v "$(git rev-parse --git-dir)/index.lock"'

alias gi='gh issue list --state=open'
alias gI='gh issue list --state=closed'
alias pr='gh pr create --web --fill'
alias rel='make --silent release' # personal convention to have `make release`

#───────────────────────────────────────────────────────────────────────────────

# highlight conventional commits
ZSH_HIGHLIGHT_REGEXP+=('(feat|fix|test|perf|build|ci|revert|refactor|chore|docs|break|style|improv)(\(.+\)|\\!)?:' 'fg=magenta,bold')

ZSH_HIGHLIGHT_REGEXP+=('#[0-9]+' 'fg=red')                                # issues numbers
ZSH_HIGHLIGHT_REGEXP+=('([0-9a-f]{6,}|HEAD)((\^+|~)[0-9]*)?' 'fg=yellow') # git revs

# commit messages longer than 50 chars: yellow, longer than 72 chars: red
ZSH_HIGHLIGHT_REGEXP+=('^(gc|git commit -m) ".{72,}' 'fg=white,bold,bg=red')
ZSH_HIGHLIGHT_REGEXP+=('^(gc|git commit -m) ".{51,71}' 'fg=black,bg=yellow')

#───────────────────────────────────────────────────────────────────────────────
# GIT ADD, COMMIT, PULL-PUSH

# smart commit:
# - if there are staged changes, commit them
# - if there are no changes, stage all changes (`git add -A`) and then commit
function gc {
	git diff --staged --quiet && git add --all # if no staged changes, stage all

	printf "\033[1;36mCommit: \033[0m"
	git commit -m "$1" || return 1

	if [[ -n "$(git status --porcelain)" ]]; then
		print "\033[1;36mPush: \033[0mNot pushing since repo still dirty."
		return 0
	fi

	# --no-rebase to prevent "Cannot rebase on multiple branches"
	printf "\033[1;36mPull: \033[0m" && git pull --no-rebase &&
		printf "\033[1;36mPush: \033[0m" && git push
}

# completions for it
_gc() {
	((CURRENT != 2)) && return # only complete first word
	local cc=("fix" "feat" "chore" "docs" "style" "refactor" "perf"
		"test" "build" "ci" "revert" "improv" "break")
	local expl
	_description -V conventional-commit expl 'Conventional Commit Keyword'
	compadd "${expl[@]}" -P'"' -S":" -- "${cc[@]}"
}
compdef _gc gc

#───────────────────────────────────────────────────────────────────────────────

# select a recent commit to fixup *and* autosquash (not marked for next rebase!)
function fixup {
	local target
	target=$(_gitlog --no-graph -n 15 | fzf --ansi --no-sort --no-info | cut -d" " -f1)
	[[ -z "$target" ]] && return 0
	git commit --fixup="$target"

	# HACK ":" is no-op-editor https://www.reddit.com/r/git/comments/uzh2no/what_is_the_utility_of_noninteractive_rebase/
	git -c sequence.editor=: rebase --interactive --autosquash "$target^" || return 0

	_separator && _gitlog "$target"~2.. # confirm result
}

# amend-no-edit
function gm {
	git diff --staged --quiet && git add --all # if no staged changes, stage all
	git commit --amend --no-edit
	git status
}

# amend message only
function gM {
	if ! git diff --staged --quiet; then
		print "\033[1;33mStaged changes detected.\033[0m"
		return 1
	fi
	git commit --amend
	git status
}

#───────────────────────────────────────────────────────────────────────────────

# remote info
function grem {
	git branch --all --verbose --verbose
	echo
	git remote --verbose
	printf "\e[1;34mgh\e[0m default repo: "&& gh repo set-default --view
}

# Github Url: open & copy url
function gu {
	url=$(git remote -v | head -n1 | cut -f2 | cut -d' ' -f1 |
		sed -e 's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git//')
	echo "$url" | pbcopy
	open "$url"
}

#───────────────────────────────────────────────────────────────────────────────
# GIT LOG

function gl {
	if [[ -z "$1" ]]; then
		_gitlog -n 15
	elif [[ "$1" =~ ^[0-9]+$ ]]; then
		_gitlog -n "$1"
	else
		_gitlog "$@"
	fi
}

# interactive
function gli {
	if [[ ! -x "$(command -v fzf)" ]]; then print "\033[1;33mfzf not installed.\033[0m" && return 1; fi
	if [[ ! -x "$(command -v delta)" ]]; then print "\033[1;33mdelta not installed (\`brew install git-delta\`)\033[0m" && return 1; fi

	local hash key_pressed selected style
	local preview_format="%C(yellow)%h %C(red)%D %n%C(blue)%an %C(green)(%ch)%C(reset) %n%n%C(bold)%C(magenta)%s %C(cyan)%b%C(reset)"
	defaults read -g AppleInterfaceStyle &>/dev/null && style="--dark" || style="--light"

	selected=$(
		_gitlog --no-graph --color=always |
			fzf --ansi --no-sort \
				--header-first --header="↵ : Checkout    ^H: Copy Hash    ^R: Rebase" \
				--expect="ctrl-h,ctrl-r" --with-nth=2.. --preview-window=55% \
				--preview="git show {1} --stat=,30,30 --color=always --format='$preview_format' | sed '\$d' ; git diff {1}^! | delta $style --hunk-header-decoration-style='blue ol' --file-style=omit" \
				--height="100%" #required for wezterm's pane:is_alt_screen_active()
	)
	[[ -z "$selected" ]] && return 0 # abort

	key_pressed=$(echo "$selected" | head -n1)
	hash=$(echo "$selected" | sed '1d' | cut -d' ' -f1)

	if [[ "$key_pressed" == "ctrl-h" ]]; then
		echo -n "$hash" | pbcopy
		print "\033[1;33m$hash\033[0m copied."
	elif [[ "$key_pressed" == "ctrl-r" ]]; then
		git rebase -i "$hash^"
		_separator && _gitlog "$hash^..HEAD" # confirm result
	else                                  # pressed return
		git checkout "$hash"
	fi
}

#───────────────────────────────────────────────────────────────────────────────

function clone {
	url="$1"
	# turn http into SSH remotes
	[[ "$url" =~ http ]] && url="$(echo "$1" | sed -E 's/https?:\/\/github.com\//git@github.com:/').git"

	# WARN depth=2 ensures that amending a shallow commit does not result in a
	# new commit without parent, effectively destroying git history (!!)
	git clone --depth=2 --no-single-branch "$url"

	# shellcheck disable=SC2012
	builtin cd "$(command ls -1 -t | head -n1)" || return 1
	_separator
	_magic_dashboard
}

#───────────────────────────────────────────────────────────────────────────────

# select a fork or multiple forks to delete
function deletefork {
	if [[ ! -x "$(command -v fzf)" ]]; then print "\033[1;33mfzf not installed.\033[0m" && return 1; fi
	if [[ ! -x "$(command -v gh)" ]]; then print "\033[1;33mgh not installed.\033[0m" && return 1; fi

	to_delete=$(gh repo list --fork | fzf --multi --with-nth=1 --info=inline | cut -f1)
	[[ -z "$to_delete" ]] && return 0 # aborted

	if [[ $(echo "$to_delete" | wc -l) -eq 1 ]]; then
		gh repo delete "$to_delete"
	else
		# INFO `gh repo delete` disallows multiple deletions at once
		# shellcheck disable=2001
		cmd=$(echo "$to_delete" | sed 's/^/gh repo delete /')
		echo "Copied command to batch deleted forks."
		echo "$cmd" | pbcopy
	fi
}
#───────────────────────────────────────────────────────────────────────────────

# pickaxe entire repo history
function pickaxe {
	[[ -z $1 ]] && print "\033[1;33mNo search query provided.\033[0m" && return 1
	echo "Reminder: Mostly, these are deletion commits. Thus, the checkout target should usually be the parent commit:"
	print "\033[1;36mgit checkout {hash}^\033[0m"
	echo

	_gitlog --pickaxe-regex --regexp-ignore-case -S"$1"
}

# search for [g]it [d]eleted [f]ile
function gdf {
	if ! command -v fzf &>/dev/null; then echo "fzf not installed." && return 1; fi
	if ! command -v bat &>/dev/null; then echo "bat not installed." && return 1; fi
	[[ -z $1 ]] && print "\033[1;33mNo search query provided.\033[0m" && return 1

	local deleted_path deletion_commit
	builtin cd -q "$(git rev-parse --show-toplevel)" || return 1

	# alternative method: `git rev-list -n 1 HEAD -- "**/*$1*"` to get the commit of a deleted file
	deleted_path=$(git log --diff-filter=D --summary | grep "delete" | grep -i "$*" | cut -d" " -f5-)

	if [[ -z "$deleted_path" ]]; then
		print "🔍\033[1;33m No deleted file found."
		return 1
	elif [[ $(echo "$deleted_path" | wc -l) -gt 1 ]]; then
		print "🔍\033[1;34m Multiple files found."
		echo
		selection=$(echo "$deleted_path" | fzf --height=60%)
		[[ -z "$selection" ]] && return 0
		deleted_path="$selection"
	fi

	deletion_commit=$(git log --format='%h' --follow -- "$deleted_path" | head -n1)
	last_commit=$(git show --format='%h' "$deletion_commit^" | head -n1)
	if [[ -z "$selection" ]]; then
		print "🔍\033[1;32m One file found:\033[0m"
	else
		print "🔍\033[1;32m Selected file:\033[0m"
	fi

	# decision on how to act on file
	echo "$deleted_path -- $last_commit"
	echo

	choices="restore file (checkout)
copy to clipboard
show file (bat)"
	decision=$(echo "$choices" |
		fzf --bind="j:down,k:up" --no-sort --no-info --height="5" \
			--layout=reverse-list --header="j:↓  k:↑")

	if [[ -z "$decision" ]]; then
		echo "Aborted."
		return 0
	elif [[ "$decision" =~ restore ]]; then
		git checkout "$last_commit" -- "$deleted_path"
		echo "File restored."
		open -R "$deleted_path" # reveal in macOS Finder
	elif [[ "$decision" =~ copy ]]; then
		git show "$last_commit:$deleted_path" | pbcopy
		echo "Content copied."
	elif [[ "$decision" =~ show ]]; then
		ext=${deleted_path##*.}
		git show "$last_commit:$deleted_path" | bat --language="$ext"
	fi
}

#───────────────────────────────────────────────────────────────────────────────
