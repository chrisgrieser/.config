#!/usr/bin/env zsh

alias co="git checkout"
alias gg="git checkout -" # go to previous branch/commit, like `zz` switching to last directory
alias gs='git status'
alias ga="git add"
alias push="git push"
alias pull="git pull"
alias g.='cd "$(git rev-parse --show-toplevel)"' # goto git root
alias grh='git reset --hard'

alias gi='gh issue list --state=open'
alias gI='gh issue list --state=closed'
alias rel='make --silent release'

#───────────────────────────────────────────────────────────────────────────────

# commit messages longer than 50 chars: yellow, longer than 72 chars: red
ZSH_HIGHLIGHT_REGEXP+=('^(acp?|gc -m|git commit -m) ".{72,}"' 'fg=white,bold,bg=red')
ZSH_HIGHLIGHT_REGEXP+=('^(acp?|gc -m|git commit -m) ".{51,71}"' 'fg=black,bg=yellow')

# highlight conventional commits
ZSH_HIGHLIGHT_REGEXP+=('(feat|fix|test|perf|build|ci|revert|refactor|chore|docs|break|improv)(\(.+\)|\\!)?:' 'fg=magenta,bold')

#───────────────────────────────────────────────────────────────────────────────

function pr {
	if ! command -v gh &>/dev/null; then print "\033[1;33mgh not installed.\033[0m" && return 1; fi

	# set default remote, if it lacks one
	[[ -z "$(gh repo set-default --view)" ]] && gh repo set-default

	gh pr create --web --fill || gh pr create --web || return 1

	# set remote to my fork for subsequent additions
	local reponame
	reponame=$(basename "$PWD")
	git remote set-url origin "git@github.com:chrisgrieser/$reponame.git"
}

# select a fork or multiple forks to delete
function deletefork() {
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

# select a recent commit to fixup
function fixup {
	local cutoff=15 # CONFIG

	local target
	target=$(gitlog -n "$cutoff" | fzf --ansi --no-sort --no-info | cut -d" " -f1)
	[[ -z "$target" ]] && return 0
	git commit --fixup="$target"

	# HACK to make non-interactive rebase work with --autosquash: https://www.reddit.com/r/git/comments/uzh2no/what_is_the_utility_of_noninteractive_rebase/
	git -c sequence.editor=: rebase --interactive --autosquash "$target"~1

	separator
	gitlog "$target"~2..
}

# amend no-edit
function gm {
	git add -A && git commit --amend --no-edit
	separator
	gitlog -n 4
}

# amend message only
function gM() {
	git commit --amend
	separator
	gitlog -n 4
}

# Github Url: open & copy url
function gu {
	url=$(git remote -v | head -n1 | cut -f2 | cut -d' ' -f1 |
		sed -e 's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git//')
	echo "$url" | pbcopy
	open "$url"
}

function unlock {
	rm "$(git rev-parse --git-dir)/index.lock"
	echo "Lock file removed."
}

# rebase last x commits
function rebase {
	local num="$1"
	if grep -qE '^[0-9]+$'; then
		git rebase -i HEAD~"$num"
		gitlog -n $((num + 1))
	else
		print "\033[1;33mUsage: rebase <number of commits>"
	fi
}

# https://stackoverflow.com/a/17937889
function unshallow {
	git fetch --unshallow
	git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
	git fetch origin
}

#───────────────────────────────────────────────────────────────────────────────
# GIT DIFF & DELTA

# use delta for small diffs and diff2html for big diffs
function gd {
	local threshold_lines=100 # CONFIG

	if [[ $(git diff | wc -l) -gt $threshold_lines ]]; then
		if ! command -v diff2html &>/dev/null; then echo "diff2html not installed (\`npm -g install diff2html\`)." && return 1; fi
		diff2html --hwt="$HOME/.config/diff2html/diff2html-template.html"
	else
		if ! command -v delta &>/dev/null; then echo "delta not installed (\`brew install git-delta\`)" && return 1; fi
		if defaults read -g AppleInterfaceStyle &>/dev/null; then
			git -c delta.dark=true diff
		else
			git -c delta.light=true diff
		fi
	fi
}

# make delta theme-aware
function delta {
	if defaults read -g AppleInterfaceStyle &>/dev/null; then
		command delta --dark "$@"
	else
		command delta --light "$@"
	fi
}

#───────────────────────────────────────────────────────────────────────────────
# GIT LOG

function gitlog {
	# my color format used for git log
	local format="format:%C(yellow)%h%C(red)%d%C(reset) %s %C(green)(%cr) %C(bold blue)<%an>%C(reset)"

	git log --all --color --graph --format="$format" "$@" |
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
			-Ee $'s/ (improv|fix|refactor|build|ci|docs|feat|test|perf|chore|revert|break|style)(\\(.+\\)|!)?:/ \033[1;35m\\1\033[0;34m\\2\033[0m:/' \
			-Ee $'s/(#[0-9]+)/\033[1;31m\\1\033[0m/' # issue numbers
	# INFO inserting ansi colors via sed requires leading $
	echo
}

# brief git log (only last 15)
function gl {
	local cutoff=15 # CONFIG
	gitlog -n "$cutoff"
	# add `(…)` if commits were shortened
	[[ $(git log --oneline | wc -l) -gt $cutoff ]] && echo "(…)"
}

# interactive
function gli {
	if ! command -v fzf &>/dev/null; then echo "fzf not installed." && return 1; fi

	local hash key_pressed selected
	local format="%C(yellow)%h %C(red)%D %n%C(green)%ch %C(blue)%an%C(reset) %n%n%C(bold)%s %n%C(reset)%n---%n%C(magenta)"
	selected=$(
		gitlog --color=always |
			fzf -0 --query="$1" \
				--ansi --no-sort --no-info \
				--header-first --header="↵ : Checkout   ^H: Copy [H]ash" \
				--expect="ctrl-h" \
				--preview-window=40% \
				--preview="git show {1} --name-only --color=always --format='$format'"
	)
	[[ -z "$selected" ]] && return 0
	key_pressed=$(echo "$selected" | head -n1)
	hash=$(echo "$selected" | cut -d' ' -f1 | tail -n+2)

	if [[ "$key_pressed" == "ctrl-h" ]]; then
		echo "$hash" | pbcopy
		echo "'$hash' copied."
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
# GIT ADD, COMMIT, (PULL) & PUSH

# smart commit:
# - if there are staged changes, commit them
# - if there are no changes, stage all changes (`git add -A`) and then commit
# - if commit message is empty use `chore` as default message
# - if commit msg contains issue number, open the issue in the browser
function ac() {
	local large_files commit_msg msg_length

	# guard: accidental pushing of large files
	large_files=$(find . -not -path "**/.git/**" -not -path "**/*.pxd/**" \
		-not -path "**/node_modules/**" -not -path "**/*venv*/**" -size +10M)
	if [[ -n "$large_files" ]]; then
		print "\033[1;33mLarge file(s) detected, aborting."
		print "$large_files\033[0m"
		return 1
	fi

	# fill in empty commit msg
	[[ -z "$1" ]] && commit_msg=chore || commit_msg=$1

	# ensure no overlength of commit msg
	msg_length=${#commit_msg}
	if [[ $msg_length -gt 72 ]]; then
		echo "Commit Message too long ($msg_length chars)."
		commit_msg=${commit_msg::72}
		print -z "acp \"$commit_msg\"" # put back into buffer
		return 1
	fi

	# if no staged changes, stage all
	git diff --staged --quiet && git add -A

	git commit -m "$commit_msg"

	# if commit msg contains issue number, open the issue in the browser
	if [[ "$commit_msg" =~ \#[0-9]+ ]]; then
		local issue_number url
		issue_number=$(echo "$commit_msg" | grep -Eo "#[0-9]+" | cut -c2-)
		url=$(git remote -v | head -n1 | cut -f2 | cut -d' ' -f1 |
			sed -e 's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git//')
		open "$url/issues/$issue_number"
	fi
}

# same as ac, just followed by git pull & git push
function acp {
	ac "$@" || return 1

	git pull
	git push
	sketchybar --trigger repo-files-update
}

#───────────────────────────────────────────────────────────────────────────────

function clone() {
	url="$1"
	# turn http into SSH remotes
	[[ "$url" =~ http ]] && url="$(echo "$1" | sed -E 's/https?:\/\/github.com\//git@github.com:/').git"

	# WARN depth=2 ensures that amending a shallow commit does not result in a
	# new commit without parent, effectively destroying git history (!!)
	git clone --depth=2 --filter=blob:none "$url"

	# shellcheck disable=SC2012
	cd "$(command ls -1 -t | head -n1)" || return 1
	separator
	inspect
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
	separator

	# WARN depth > 1 ensures that amending a shallow commit does not result in a
	# new commit without parent, effectively destroying git history (!!)
	git clone --depth=5 "$SSH_REMOTE" "$local_repo_path" &&
		cd "$local_repo_path" || return 1
	separator
	inspect
}

#───────────────────────────────────────────────────────────────────────────────

# search for [g]it [d]eleted [f]ile
function gdf {
	if ! command -v fzf &>/dev/null; then echo "fzf not installed." && return 1; fi
	if ! command -v bat &>/dev/null; then echo "bat not installed." && return 1; fi
	if [[ $# -eq 0 ]]; then echo "No search query provided." && return 1; fi

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
