#!/usr/bin/env zsh

alias co="git checkout"
alias gg="git checkout -" # go to previous branch/commit, like `zz` switching to last directory
alias gs='git status'
alias ga="git add"

alias stash="git stash"
alias unstash="git stash pop"

alias grh='git reset --hard'
alias push="git push"
alias pull="git pull"
alias unshallow="git fetch --unshallow"          # https://stackoverflow.com/a/17937889
alias g.='cd "$(git rev-parse --show-toplevel)"' # goto git root

alias gi='gh issue list --state=open'
alias gI='gh issue list --state=closed'
alias pr='gh pr create --web --fill'
alias rel='make --silent release'

#───────────────────────────────────────────────────────────────────────────────

# highlight conventional commits & issue numbers
ZSH_HIGHLIGHT_REGEXP+=('(feat|fix|test|perf|build|ci|revert|refactor|chore|docs|break|improv)(\(.+\)|\\!)?:' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=('(#[0-9]+)' 'fg=red,bold')

# commit messages longer than 50 chars: yellow, longer than 72 chars: red
ZSH_HIGHLIGHT_REGEXP+=('^(gc|git commit -m) ".{72,}"' 'fg=white,bold,bg=red')
ZSH_HIGHLIGHT_REGEXP+=('^(gc|git commit -m) ".{51,71}"' 'fg=black,bg=yellow')

#───────────────────────────────────────────────────────────────────────────────

# select a fork or multiple forks to delete
function deletefork {
	if ! command -v gh &>/dev/null; then print "\033[1;33mgh not installed.\033[0m" && return 1; fi
	if ! command -v fzf &>/dev/null; then print "\033[1;33mfzf not installed.\033[0m" && return 1; fi

	to_delete=$(gh repo list --fork | fzf --multi --with-nth=1 --info=inline | cut -f1)
	[[ -z "$to_delete" ]] && return 0
	if [[ $(echo "$to_delete" | wc -l) -eq 1 ]]; then
		gh repo delete "$to_delete"
	else
		# INFO `gh repo delete` disallows multiple deletions at once
		# shellcheck disable=2001
		cmd=$(echo "$to_delete" | sed 's/^/gh repo delete --yes /')
		echo "Copied command to batch deleted forks."
		echo "$cmd" | pbcopy
	fi
}

# Github Url: open & copy url
function gu {
	url=$(git remote -v | head -n1 | cut -f2 | cut -d' ' -f1 |
		sed -e 's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git//')
	echo "$url" | pbcopy
	open "$url"
}

#───────────────────────────────────────────────────────────────────────────────
# GIT DIFF & DELTA

function gd {
	if [[ ! -x "$(command -v delta)" ]]; then print "\033[1;33mdelta not installed (\`brew install git-delta\`)\033[0m" && return 1; fi

	# make delta light/dark mode aware
	local style
	defaults read -g AppleInterfaceStyle &>/dev/null && style="dark" || style="light"
	git -c delta."$style"=true diff "$@"
}

#───────────────────────────────────────────────────────────────────────────────
# GIT LOG

# brief git log
function gl {
	local cutoff=15 # CONFIG
	_gitlog -n "$cutoff"
	# add `(…)` if commits were shortened
	[[ $(git log --oneline | wc -l) -lt $cutoff ]] || echo "(…)"
}

# interactive
function gli {
	if ! command -v fzf &>/dev/null; then echo "fzf not installed." && return 1; fi

	local hash key_pressed selected style
	local preview_format="%C(yellow)%h %C(red)%D %n%C(blue)%an %C(green)(%ch)%C(reset) %n%n%C(bold)%C(magenta)%s %C(cyan)%b%C(reset)"
	defaults read -g AppleInterfaceStyle &>/dev/null && style="--dark" || style="--light"

	selected=$(
		_gitlog --no-graph --color=always |
			fzf -0 --query="$1" --ansi --no-sort \
				--header-first --header="↵ : Checkout    ^H: Copy Hash    ^R: Rebase" \
				--expect="ctrl-h" --with-nth=2.. --preview-window=55% \
				--preview="git show {1} --stat=,30,30 --color=always --format='$preview_format' | sed -e '\$d' -e 's/^ //' ; git diff {1}^! --unified=1 | delta $style --hunk-header-decoration-style='blue ol' --file-style=omit" \
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
		_gitlog "$hash^..HEAD"
	else # pressed return
		git checkout "$hash"
	fi
}

#───────────────────────────────────────────────────────────────────────────────
# SELECT BRANCH

function gb {
	if ! command -v fzf &>/dev/null; then echo "fzf not installed." && return 1; fi
	local selected

	selected=$(
		git branch --all --color | grep -v "HEAD" |
			fzf --ansi --no-info --height=40% --header-first --header="↵ : Checkout Branch"
	)
	[[ -z "$selected" ]] && return 0
	selected=$(echo "$selected" | tr -d "* ")

	# how to checkout remote branches: https://stackoverflow.com/questions/67699/how-do-i-clone-all-remote-branches
	if [[ $selected == remotes/* ]]; then
		remote=$(echo "$selected" | cut -d/ -f2-)
		git checkout "$remote"
		selected=$(echo "$selected" | cut -d/ -f3)
	fi
	git checkout "$selected"
}

#───────────────────────────────────────────────────────────────────────────────
# GIT ADD, COMMIT, PULL-PUSH

# smart commit:
# - if there are staged changes, commit them
# - if there are no changes, stage all changes (`git add -A`) and then commit
# - if commit message is empty use `chore` as default message
# - if commit msg contains issue number, open the issue in the browser
function gc {
	local msg="$1"
	[[ -z "$msg" ]] && msg=chore || msg=$1     # fill in empty commit msg,
	git diff --staged --quiet && git add --all # if no staged changes, stage all

	printf "\033[1;36mCommit: \033[0m"
	git commit -m "$msg" || return 1

	# pull-push
	if [[ -n "$(git status --porcelain)" ]]; then
		print "\033[1;36mPush: \033[0;34mNot pushing since repo still dirty.\033[0m"
		return 0
	fi

	printf "\033[1;36mPull: \033[0m" && git pull &&
		printf "\033[1;36mPush: \033[0m" && git push
}

# amend-no-edit
function gm {
	git diff --staged --quiet && git add --all # if no staged changes, stage all
	git commit --amend --no-edit
	git status
}

# amend message only
function gM {
	git commit --amend "$1"
	git status
}

#───────────────────────────────────────────────────────────────────────────────

function clone {
	url="$1"
	# turn http into SSH remotes
	[[ "$url" =~ http ]] && url="$(echo "$1" | sed -E 's/https?:\/\/github.com\//git@github.com:/').git"

	# WARN depth=2 ensures that amending a shallow commit does not result in a
	# new commit without parent, effectively destroying git history (!!)
	git clone --depth=2 --filter=blob:none "$url"

	# shellcheck disable=SC2012
	cd "$(command ls -1 -t | head -n1)" || return 1
	_separator
	_magic_dashboard
}

# delete and re-clone git repo
function nuke {
	if ! git rev-parse --is-inside-work-tree &>/dev/null; then print "\033[1;33mfile is not ins a git repository.\033[0m" && return 1; fi
	is_submodule=$(git rev-parse --show-superproject-working-tree)
	if [[ -n "$is_submodule" ]]; then print "\033[1;33mnuke does not support submodules.\033[0m" && return 1; fi

	SSH_REMOTE=$(git remote -v | head -n1 | cut -d" " -f1 | cut -d$'	' -f2)
	# go to git repo root
	cd "$(git rev-parse --show-toplevel)" || return 1
	local_repo_path=$PWD
	cd ..

	command rm -rf "$local_repo_path"
	print "\033[1;34mLocal repo removed."
	print "Cloning repo again from remote…\033[0m"
	_separator

	# WARN depth > 1 ensures that amending a shallow commit does not result in a
	# new commit without parent, effectively destroying git history (!!)
	git clone --depth=5 "$SSH_REMOTE" "$local_repo_path" &&
		cd "$local_repo_path" || return 1
	_separator
	inspect
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
	cd "$(git rev-parse --show-toplevel)" || return 1

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
