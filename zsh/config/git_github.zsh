alias g='git'
alias gs='git status'
alias ga='git add'
alias gA='git add --all'

alias co='git checkout'
alias gd='git diff'
alias grh='git reset --hard'
alias gt='git stash push && git stash show 0'
alias gT='git stash pop'
alias gi='gh issue list --state=open'
alias gI='gh issue list --state=closed'

alias unadd='git restore --staged'
alias restore='git restore'
alias push='git push'
alias pull='git pull'
alias rebase='git rebase --interactive'
alias unlock='rm -v "$(git rev-parse --git-dir)/index.lock"'

alias pr='gh pr create --web --fill'
alias rel='make --silent release' # personal convention to have `make release`

#───────────────────────────────────────────────────────────────────────────────

# issues numbers & git revs
ZSH_HIGHLIGHT_REGEXP+=('#[0-9]+' 'fg=blue,bold')
ZSH_HIGHLIGHT_REGEXP+=('([0-9a-f]{6,9}|HEAD)((\^+|~)[0-9]*)?' 'fg=yellow')

# commit messages longer than 50 chars: orange, longer than 72 chars: red
ZSH_HIGHLIGHT_REGEXP+=('^(gc|gC|git commit -m) ".{51,71}' 'fg=208') # 208 = orange
ZSH_HIGHLIGHT_REGEXP+=('^(gc|gC|git commit -m) ".{72,}' 'fg=white,bold,bg=red')

# inline code with backslashes
ZSH_HIGHLIGHT_REGEXP+=($'\\\\`[^`]*\\\\`' 'fg=cyan,bold')

# highlight conventional commits
ZSH_HIGHLIGHT_REGEXP+=(
	'(feat|fix|test|perf|build|ci|revert|refactor|chore|docs|break|style|improv)(\(.+\))?(\\?\!)?:'
	'fg=magenta,bold'
)

#───────────────────────────────────────────────────────────────────────────────
# SMART COMMIT
# - if there are no staged changes, stage all changes (`git add -A`) and then commit
# - if the is clean after committing, pull-push
function gc {
	git diff --staged --quiet && # if no staged changes
		git add --all &&
		print "\e[1;36mStaged all changes.\e[0m"

	printf "\e[1;36mCommit: \e[0m" &&
		git commit -m "$@" || return 1

	if [[ -n "$(git status --porcelain)" ]]; then
		print "\e[1;36mPush: \e[0mNot pushing since repo still dirty." &&
			echo && git status
	else
		printf "\e[1;36mPull: \e[0m" &&
			git pull --no-rebase && # --no-rebase prevents "Cannot rebase on multiple branches"
			printf "\e[1;36mPush: \e[0m" &&
			git push
	fi
}

function gC {
	git diff --staged --quiet &&
		git add --all &&
		print "\e[1;36mStaged all Changes.\e[0m"

	printf "\e[1;36mCommit: \e[0m" &&
		git commit -m "$1" || return 1
}

# completions for them
_gc() {
	((CURRENT != 2)) && return # only complete first word
	local cc=("fix" "feat" "chore" "docs" "style" "refactor" "perf"
		"test" "build" "ci" "revert" "improv" "break")
	local expl && _description -V conventional-commit expl 'Conventional Commit Keyword'
	compadd "${expl[@]}" -P'"' -S":" -- "${cc[@]}"
}
compdef _gc gc
compdef _gc gC

#───────────────────────────────────────────────────────────────────────────────

function unshallow {
	git fetch --unshallow
	# undo `--single-branch` https://stackoverflow.com/a/17937889/22114136
	git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
	git fetch origin
}

# select a recent commit to fixup *and* autosquash (not marked for next rebase!)
function gf {
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
		print "\e[1;33mStaged changes detected.\e[0m"
		return 1
	fi
	git commit --amend
	git status
}

#───────────────────────────────────────────────────────────────────────────────

# remote info
function gri {
	git branch --all --verbose --verbose # 2x verbose shows tracked remote branches
	echo
	git remote --verbose
	printf "\e[1;34mgh default repo:\e[0m " && gh repo set-default --view
}

# Github Url: open & copy url
function gu {
	url=$(git remote -v | head -n1 | cut -f2 | cut -d' ' -f1 |
		sed -e 's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git//')
	echo "$url" | pbcopy
	open "$url"
}

# git log
function gl {
	if [[ -z "$1" ]]; then
		_gitlog --max-count=15
	elif [[ "$1" =~ ^[0-9]+$ ]]; then
		_gitlog --max-count="$1"
	else
		_gitlog "$@"
	fi
}

function clone {
	url="$1"
	# turn http into SSH remotes
	[[ "$url" =~ http ]] && url="$(echo "$1" | sed -E 's/https?:\/\/github.com\//git@github.com:/').git"

	# WARN depth > 1 ensures that amending a shallow commit does not result in a
	# new commit without parent, effectively destroying git history (!!)
	git clone --depth=10 "$url" --no-single-branch --no-tags # get branches, but not tags

	# shellcheck disable=SC2012
	cd "$(command ls -1 -t | head -n1)" || return 1
}

# select a fork or multiple forks to delete
function deletefork {
	if [[ ! -x "$(command -v fzf)" ]]; then print "\e[1;33mfzf not installed.\e[0m" && return 1; fi
	if [[ ! -x "$(command -v gh)" ]]; then print "\e[1;33mgh not installed.\e[0m" && return 1; fi

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
	[[ -z $1 ]] && print "\e[1;33mNo search query provided.\e[0m" && return 1
	echo "Reminder: Mostly, these are deletion commits. Thus, the checkout target should usually be the parent commit:"
	print "\e[1;36mgit checkout {hash}^\e[0m"
	echo

	_gitlog -G"$1" --regexp-ignore-case --follow
}

# search for [g]it [d]eleted [f]ile
function gdf {
	# GUARD
	if ! command -v fzf &>/dev/null; then echo "fzf not installed." && return 1; fi
	if ! command -v bat &>/dev/null; then echo "bat not installed." && return 1; fi
	[[ -z $1 ]] && print "\e[1;33mNo search query provided.\e[0m" && return 1
	builtin cd -q "$(git rev-parse --show-toplevel)" || return 1

	local deleted_path deletion_commit last_commit
	deleted_path=$(git log --diff-filter=D --name-only --format="" | grep -i "$*")

	if [[ -z "$deleted_path" ]]; then
		print "\e[1;31m No deleted file found with \e[1;33m$*\\e[0m"
		return 1
	elif [[ $(echo "$deleted_path" | wc -l) -gt 1 ]]; then
		print "\e[1;34m Multiple files found.\e[0m"
		selection=$(echo "$deleted_path" | fzf --height=60%)
		[[ -z "$selection" ]] && return 0
		deleted_path="$selection"
	fi

	# alternative method: `git rev-list --max-count=1 HEAD -- "path/to/file"`
	deletion_commit=$(git log --format='%h' --max-count=1 -- "$deleted_path")
	last_commit=$(git rev-parse --short "$deletion_commit^")
	print "\e[1;33m$last_commit\e[0m $deleted_path"
	echo

	# decision on how to act on file
	choices="restore file
copy to clipboard
show file (bat)
checkout commit"
	decision=$(echo "$choices" |
		fzf --bind="j:down,k:up" --no-sort --no-info --height="6" \
			--layout=reverse-list --header="j:↓  k:↑")

	if [[ -z "$decision" ]]; then
		echo "Aborted."
	elif [[ "$decision" =~ checkout ]]; then
		git checkout "$last_commit"
	elif [[ "$decision" =~ restore ]]; then
		git checkout "$last_commit" -- "$deleted_path"
		echo "File restored."
		open -R "$deleted_path" # reveal in macOS Finder
	elif [[ "$decision" =~ copy ]]; then
		git show "$last_commit:$deleted_path" | pbcopy
		echo "Content copied."
	elif [[ "$decision" =~ show ]]; then
		ext=${deleted_path##*.}
		git show "$last_commit:$deleted_path" | bat --language="$ext" ||
			git show "$last_commit:$deleted_path" | bat # unknown extension
	fi
}

#───────────────────────────────────────────────────────────────────────────────
