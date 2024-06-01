alias gs='git status'
alias co='git checkout'
alias gd='git diff'
alias gt='git stash push && git stash show 0'
alias gT='git stash pop'
alias gi='gh issue list --state=open'
alias gI='gh issue list --state=closed'
alias grh='git clean -df && git reset --hard' # remove untracked files & undo all changes

alias cherry='git cherry-pick'
alias reflog='git reflog'
alias push='git push'
alias pull='git pull'
alias rebase='git rebase --interactive'
alias reset='git reset'
alias undo='git reset --mixed HEAD@{1}'
alias unlock='rm -v "$(git rev-parse --git-dir)/index.lock"'

alias pr='gh pr create --web --fill'
alias rel='just release' # `just` task runner

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
# STAGING
alias gaa='git add --all'
alias unadd='git restore --staged'
function restore { git restore "$@"; } # using function, so custom completions apply

# without argument, run interactively via fzf to toggle staged/unstaged
# with argument, stage the file(s). Modified completions allow for quicker selection.
function ga {
	if [[ -n "$1" ]]; then
		git add "$@"
		return 0
	fi

	local dir="$PWD"
	cd "$(git rev-parse --show-toplevel)" || return 1

	local git_status_cmd="git -c core.quotePath=false -c status.color=always status --short --untracked-files"
	local check_staged='if git diff --cached --name-only | grep -q "^"{2..}"$" ; '
	local add_or_unadd='then git restore --stage -- {2..} ; else git add -- {2..} ; fi'
	local file_diff='{ git diff --color=always -- {2..} ; git diff --staged --color=always -- {2..} }'
	local style
	style=$(defaults read -g AppleInterfaceStyle &> /dev/null && echo "--dark" || echo "--light")
	selection=$(
		eval "$git_status_cmd" | fzf \
			--ansi --nth=2.. --track \
			--preview="$file_diff | delta $style --file-style=omit" \
			--bind="enter:reload($check_staged $add_or_unadd ; $git_status_cmd)"
	)

	cd "$dir" || return 1
	return 0 # no exiting 130
}

# completions for running `ga` with argument
_change_git_files() {
	local -a changed_files=()
	while IFS='' read -r file; do # turn lines into array
		changed_files+=("$file")
	done < <(git -c status.relativePaths=true status --porcelain --untracked-files | cut -c4-)

	local expl && _description -V git-changed-files expl 'Changed & Untracked Files'
	compadd "${expl[@]}" -- "${changed_files[@]}"
}
compdef _change_git_files ga
compdef _change_git_files gd
compdef _change_git_files restore

#───────────────────────────────────────────────────────────────────────────────
# SMART COMMIT

function _stageAllIfNoStagedChanges {
	git diff --staged --quiet &&
		git add --all &&
		print "\e[1;34mStaged all changes.\e[0m"
}

# - if there are no staged changes, stage all changes (`git add -A`) and then commit
# - if the is clean after committing, pull-push
function gc {
	_stageAllIfNoStagedChanges

	# without arg, just open in editor
	if [[ -z "$1" ]]; then
		git commit
		return
	fi

	printf "\e[1;34mCommit: \e[0m"
	git commit -m "$@" || return 1

	if [[ -n "$(git status --porcelain)" ]]; then
		print "\e[1;34mPush: \e[0mNot pushing since repo still dirty."
		echo
		git status
	else
		printf "\e[1;34mPull: \e[0m" && git pull --no-rebase && # --no-rebase prevents "Cannot rebase on multiple branches"
			printf "\e[1;34mPush: \e[0m" && git push
	fi
}

function gC {
	_stageAllIfNoStagedChanges
	# without arg, just open in editor
	if [[ -z "$1" ]]; then
		git commit
		return
	fi

	printf "\e[1;34mCommit: \e[0m"
	git commit -m "$@" || return 1
}

#───────────────────────────────────────────────────────────────────────────────
# SMART AMEND & FIXUP
# select a recent commit to fixup *and* autosquash (not marked for next rebase!)
function gf {
	local target
	target=$(_gitlog --no-graph -n 15 | fzf --ansi --no-sort --no-info | cut -d" " -f1)
	[[ -z "$target" ]] && return 0

	_stageAllIfNoStagedChanges
	git commit --fixup="$target"

	# HACK ":" is no-op-editor https://www.reddit.com/r/git/comments/uzh2no/what_is_the_utility_of_noninteractive_rebase/
	git -c sequence.editor=: rebase --interactive --autosquash "$target^" || return 0

	_separator && _gitlog "$target"~2.. # confirm result
}

# amend-no-edit
function gm {
	_stageAllIfNoStagedChanges
	git commit --amend --no-edit
	echo
	git status
}

# amend message only
function gM {
	if ! git diff --staged --quiet; then
		print "\e[1;33mStaged changes found.\e[0m"
		return 1
	fi
	git commit --amend --no-verify
	echo
	git status
}

#───────────────────────────────────────────────────────────────────────────────

# undo shallow clones
function unshallow {
	git fetch --unshallow
	git pull --tags # undo --no-tags
	# undo `--single-branch` https://stackoverflow.com/a/17937889/22114136
	git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
	git fetch origin
}

function remote_info {
	git branch --all --verbose --verbose # 2x verbose shows tracked remote branches
	echo
	git remote --verbose
	echo
	printf "\e[1;34mgh default repo:\e[0m " && gh repo set-default --view
}

# Github Url: open & copy url
function gu {
	url=$(git remote --verbose | head -n1 | cut -f2 | cut -d' ' -f1 |
		sed -E 's|git@github.com:|https://github.com/|')
	echo "$url" | pbcopy
	open "$url"
}

function new_branch {
	git checkout -b "$1"
	git push --set-upstream origin "$1"
}

#───────────────────────────────────────────────────────────────────────────────
# GIT LOG
# uses `_gitlog` from magic-dashboard.zsh

function gl {
	if [[ -z "$1" ]]; then
		_gitlog --max-count=15 # default 15
	elif [[ "$1" =~ ^[0-9]+$ ]]; then
		_gitlog --max-count="$1"
	else
		_gitlog "$@"
	fi
}

# interactive
function gli {
	if [[ ! -x "$(command -v fzf)" ]]; then print "\e[1;33mfzf not installed.\e[0m" && return 1; fi
	if [[ ! -x "$(command -v delta)" ]]; then print "\e[1;33mdelta not installed (\`brew install git-delta\`)\e[0m" && return 1; fi

	local hash key_pressed selected style
	local preview_format="%C(yellow)%h %C(red)%D %n%C(blue)%an %C(green)(%ch)%C(reset) %n%n%C(bold)%C(magenta)%s %C(cyan)%n%b%C(reset)"
	style=$(defaults read -g AppleInterfaceStyle &> /dev/null && echo --dark || echo --light)

	selected=$(
		_gitlog --no-graph --color=always |
			fzf --ansi --no-sort --track \
				--header-first --header="↵ Checkout   ^H Hash   ^R Rebase   ^S Stats" \
				--expect="ctrl-h,ctrl-r,ctrl-s" --with-nth=2.. --preview-window=55% \
				--preview="git show {1} --stat=,30,30 --color=always --format='$preview_format' | sed '\$d' ; git diff {1}^! | delta $style --hunk-header-decoration-style='blue ol' --file-style=omit" \
				--height="100%" #required for wezterm's pane:is_alt_screen_active()
	)
	[[ -z "$selected" ]] && return 0 # aborted

	key_pressed=$(echo "$selected" | head -n1)
	hash=$(echo "$selected" | sed '1d' | cut -d' ' -f1)

	if [[ "$key_pressed" == "ctrl-h" ]]; then
		echo -n "$hash" | pbcopy
		print "\e[1;33m$hash\e[0m copied."
	elif [[ "$key_pressed" == "ctrl-s" ]]; then
		git show --stat "$hash"
	elif [[ "$key_pressed" == "ctrl-r" ]]; then
		git rebase --interactive "$hash^"
		_separator && _gitlog "$hash^..HEAD" # confirm result
	else
		git checkout "$hash"
	fi
}

#───────────────────────────────────────────────────────────────────────────────

function clone {
	# WARN depth=1 is dangerous, as amending such a commit does result in a
	# new commit without parent, effectively destroying git history (!!)
	git clone --depth=15 "$1" --no-single-branch --no-tags # get branches, but not tags
	cd "$(basename "$1" .git)" || return 1
}

function delete_forks_with_no_open_prs {
	if [[ ! -x "$(command -v fzf)" ]]; then print "\e[1;33mfzf not installed.\e[0m" && return 1; fi
	if [[ ! -x "$(command -v gh)" ]]; then print "\e[1;33mgh not installed.\e[0m" && return 1; fi

	local my_prs my_forks
	my_prs=$(gh search prs --author="@me" --state=open --json="repository" --jq=".[].repository.name")
	my_forks=$(gh repo list --fork | cut -f1)
	while read -r pr; do
		my_forks=$(echo "$my_forks" | grep -v "$pr")
	done <<< "$my_prs"

	forks_with_no_prs="$my_forks"
	[[ -z "$forks_with_no_prs" ]] && print "\e[1;33mNo forks to delete.\e[0m" && return 0
	# shellcheck disable=2001
	print -z "$(echo "$forks_with_no_prs" | sed 's/^/gh repo delete /')"
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
	if ! command -v fzf &> /dev/null; then echo "fzf not installed." && return 1; fi
	if ! command -v bat &> /dev/null; then echo "bat not installed." && return 1; fi
	[[ -z $1 ]] && print "\e[1;33mNo search query provided.\e[0m" && return 1
	builtin cd -q "$(git rev-parse --show-toplevel)" || return 1

	local deleted_path deletion_commit last_commit
	deleted_path=$(git log --diff-filter=D --name-only --format="" | grep -i "$*")

	if [[ -z "$deleted_path" ]]; then
		print "\e[1;31mNo deleted file found with \e[1;33m$*\\e[0m"
		return 1
	elif [[ $(echo "$deleted_path" | wc -l) -gt 1 ]]; then
		print "\e[1;34mMultiple files found.\e[0m"
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
		fzf --bind="j:down,k:up" --no-sort --no-info --height="7" \
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
