alias gs='git status'
alias co='git checkout'
alias gd='git diff'
alias gt='git stash push && git stash show 0'
alias gT='git stash pop'
alias gi='gh issue list --state=open'
alias gI='gh issue list --state=closed'
alias grh='git clean --force -d && git reset --hard' # remove untracked files & undo all changes

alias irb='git rebase --interactive --committer-date-is-author-date' # [i]nteractive [r]e[b]ase
alias crb='git add --all ; git rebase --continue'                    # [c]ontinue [r]e[b]ase

alias cherry='git cherry-pick'
alias push='git push'
alias pull='git pull'
alias reset='git reset'

alias gundo='git reset --mixed HEAD@{1}'
alias unlock='rm -v "$(git rev-parse --git-dir)/index.lock"'
alias conflict_file='open "$(git diff --name-only --diff-filter=U --relative | head -n1)"'

alias mark_commit="git tag 'mark' && echo $'Added tag \'mark\' to current commit.'"
alias unmark_commit="git tag --delete 'mark'"

function sync_repo { "$(git rev-parse --show-toplevel)/.sync-this-repo.sh"; }

#───────────────────────────────────────────────────────────────────────────────

# lazy-export the GITHUB_TOKEN
function gh {
	_export_github_token # defined in .zshenv
	command gh "$@"
	unfunction gh
}

#───────────────────────────────────────────────────────────────────────────────

# issues numbers
ZSH_HIGHLIGHT_REGEXP+=('#[0-9]+' 'fg=blue,bold')

# commit message overlength
ZSH_HIGHLIGHT_REGEXP+=('^(gc|gg|git commit -m) ".{72,}' 'fg=white,bold,bg=red')

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

# using functions instead of aliases, so overriding completions works
function ga { git add "$@"; }
function restore { git restore "$@"; }

# custom completions: suggest changed files, not just directory parts.
_changed_git_files() {
	local -a changed_files=()
	while IFS='' read -r file; do # turn lines into array
		changed_files+=("$file")
	done < <(git -c status.relativePaths=true status --porcelain --untracked-files | cut -c4-)

	local expl && _description -V git-changed-files expl 'Changed & Untracked Files'
	compadd "${expl[@]}" -Q -- "${changed_files[@]}"
}
compdef _changed_git_files ga
compdef _changed_git_files restore

#───────────────────────────────────────────────────────────────────────────────
# SMART COMMIT

function _stageAllIfNoStagedChanges {
	git diff --staged --quiet &&
		git add --all &&
		print "\e[1;34mStaged all changes.\e[0m"
}

function _smartCommit {
	_stageAllIfNoStagedChanges

	# without arg, just open in editor
	printf "\e[1;34mCommit: \e[0m"
	if [[ -z "$1" ]]; then
		git commit || return 1
	else
		git commit --message "$@" || return 1
	fi
}

function gc {
	_smartCommit "$@"
}

# - if there are no staged changes, stage all changes (`git add -A`) and then commit
# - if the is clean after committing, pull-push
function gg {
	_smartCommit "$@"

	# GUARD do not pull/push if still dirty
	if [[ -n "$(git status --porcelain)" ]]; then
		print "\e[1;34mPush:\e[0m Not pushing since repo still dirty."
		echo
		git status
		return 0
	fi

	# PULL: only if there is a remote tracking branch
	printf "\e[1;34mPull:\e[0m"
	if git status --short --branch | grep --fixed-strings --quiet '...'; then
		git pull --no-progress
	else
		print "Not pulling since no remote tracking branch."
	fi
	# PUSH
	printf "\e[1;34mPush:\e[0m " && git push --no-progress
}

#───────────────────────────────────────────────────────────────────────────────
# SMART AMEND & FIXUP
# select a recent commit to fixup *and* autosquash (not marked for next rebase!)
function gf {
	local target
	target=$(_gitlog --max-count=15 --no-graph | fzf --ansi --no-sort --no-info | cut -d" " -f1)
	[[ -z "$target" ]] && return 0

	_stageAllIfNoStagedChanges
	git commit --fixup="$target"

	# HACK ":" is no-op-editor https://www.reddit.com/r/git/comments/uzh2no/what_is_the_utility_of_noninteractive_rebase/
	git -c sequence.editor=: rebase --committer-date-is-author-date --interactive \
		--autosquash "$target^" || return 0

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
	git commit --amend --no-verify # `--no-verify` since just editing the message
	echo
	git status
}

#───────────────────────────────────────────────────────────────────────────────
# similar to `gh pr create --web --fill`, but without dependency (and without
# the need to set `gh` remote.)

function pr {
	git push
	sleep 1 # needed for GitHub to register the new commit
	local url
	url=$(git remote --verbose | head -n1 | cut -f2 | cut -d' ' -f1 |
		sed -Ee 's|git@github.com:|https://github.com/|' -Ee 's|\.git$||')
	open "$url/pull/new/$(git branch --show-current)"
}

#───────────────────────────────────────────────────────────────────────────────

# undo shallow clones
function unshallow {
	git fetch --unshallow
	git pull --no-progress --tags # undo `git clone --no-tags`
	# undo `--single-branch` https://stackoverflow.com/a/17937889/22114136
	git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
	git fetch origin
}

function delete_git_tag {
	git fetch --tags # fetch tags, in case clone is shallow
	git tag --delete "$1" && git push origin --delete "$1"
}

function remote_info {
	git --no-pager branch --all --verbose --verbose # 2x verbose shows tracked remote branches
	echo
	git remote --verbose
	echo
	printf "\e[1;34mgh default repo:\e[0m " && gh repo set-default --view
}

# Github Url: open & copy url
function gu {
	repo=$(git remote --verbose | head -n1 | sed -E 's/.*github.com:([^[:space:]]*).*/\1/')
	url="https://github.com/$repo"
	echo "$url" | pbcopy
	open "$url"
}

function my_commits_today {
	local username the_day commits count
	username=$(gh api user --jq='.login')
	if [[ -z "$1" ]]; then the_day="$(date '+%Y-%m-%d')"; else the_day="$(date -v "-${1}d" '+%Y-%m-%d')"; fi

	commits=$(gh search commits --limit=200 --author="$username" --committer="$username" \
		--json="repository,commit" --author-date="$the_day" --sort=author-date --order=asc |
		yq --prettyPrint $'.[] | .commit.committer.date + " " + .repository.name + " " + .commit.message' |
		grep "^\d\d\d\d" | # keep only subjects, skip the body text of commits which is are new lines
		cut -c12-16,26-)   # select only HH:MM
	count=$(echo "$commits" | wc -l | tr -d ' ')

	echo "$commits" | sed \
		-Ee $'s/ (fix|refactor|build|ci|docs|feat|style|test|perf|chore|revert|break|improv)(\\(.+\\))?(!?):/ \e[1;35m\\1\e[0;36m\\2\e[7;31m\\3\e[0;38;5;245m:\e[0m/' \
		-Ee $'s/ (release|bump):/ \e[1;32m\\1\e[0;38;5;245m:\e[0m/' \
		-Ee $'s/([0-9][0-9]:[0-9][0-9]) ([^ ]* )/\e[0;38;5;245m\\1  \e[1;34m\\2\e[0m/' \
		-Ee $'s/`[^`]*`/\e[0;33m&\e[0m/g' \
		-Ee $'s/#[0-9]+/\e[0;31m&\e[0m/g'
	print "\e[1;38;5;245m───── \e[1;32mTotal: $count commits\e[1;38;5;245m ─────\e[0m"
}

#───────────────────────────────────────────────────────────────────────────────
# GIT LOG

# uses `_gitlog` from `magic-dashboard.zsh`
function gl {
	if [[ -z "$1" ]]; then
		_gitlog --max-count=15 # default
	elif [[ "$1" =~ ^[0-9]+$ ]]; then
		_gitlog --max-count="$1"
	else
		_gitlog "$@"
	fi
}
compdef _git gl

function reflog {
	if [[ -z "$1" ]]; then
		git --no-pager reflog --max-count=15 # default
	elif [[ "$1" =~ ^[0-9]+$ ]]; then
		git --no-pager reflog --max-count="$1"
	else
		git reflog "$@"
	fi
}

# INTERACTIVE GIT LOG
# uses `_gitlog` from `magic-dashboard.zsh`
function gli {
	if ! typeset -f _gitlog > /dev/null; then
	    echo "requires \`_gitlog.zsh\` from zsh magic-dashboard"
		 return 1
	fi

	local hash key_pressed selected repo

	local preview_format="%C(yellow)%h %C(red)%D %n%C(blue)%an %C(green)(%ch)%C(reset) %n%n%C(bold)%C(magenta)%s %C(cyan)%n%b%C(reset)"
	local preview_cmd="git show {1} --stat=\$FZF_PREVIEW_COLUMNS --color=always --format='$preview_format' \
		| sed '\$d' ; git --no-pager diff {1}^!"

	if [[ -x "$(command -v delta)" ]]; then
		theme="$(defaults read -g AppleInterfaceStyle &> /dev/null && echo "dark" || echo "light")"
		preview_cmd="$preview_cmd | delta --$theme"
	fi

	selected=$(
		_gitlog --no-graph --color=always |
			fzf --ansi --no-sort --track \
				--header-first --header="↵ Checkout   ^H Hash   ^G GitHub   ^D Diff" \
				--expect="ctrl-h,ctrl-g,ctrl-d" --with-nth=2.. --preview-window="55%" \
				--preview="$preview_cmd" \
				--height="100%" #required for wezterm's pane:is_alt_screen_active()
	)
	[[ -z "$selected" ]] && return 0 # aborted

	key_pressed=$(echo "$selected" | head -n1)
	hash=$(echo "$selected" | sed '1d' | cut -d' ' -f1)

	if [[ "$key_pressed" == "ctrl-h" ]]; then
		echo -n "$hash" | pbcopy
		print "\e[1;33m$hash\e[0m copied."
	elif [[ "$key_pressed" == "ctrl-g" ]]; then
		repo=$(git remote --verbose | head -n1 | cut -f2 | cut -d' ' -f1 |
			sed -Ee 's/git@github.com://' -Ee 's/\.git$//')
		local url="https://github.com/$repo/commit/$hash"
		if [[ "$OSTYPE" =~ "darwin" ]]; then
			open "$url"
		else
			echo "$url"
		fi
	elif [[ "$key_pressed" == "ctrl-d" ]]; then
		git diff "$hash"^!
	else
		git checkout "$hash"
	fi
}

#───────────────────────────────────────────────────────────────────────────────

function clone {
	# WARN depth=1 is dangerous, as amending such a commit does result in a
	# new commit without parent, effectively destroying git history (!!)
	git clone --depth=15 "$1" --no-single-branch --no-tags
	cd "$(basename "$1" .git)" || return 1
	echo
}

function delete_forks_with_no_open_prs {
	local my_prs my_forks
	my_prs=$(gh search prs --author="@me" --state=open --json="repository" --jq=".[].repository.name")
	my_forks=$(gh repo list --fork | cut -f1)
	while read -r pr; do
		my_forks=$(echo "$my_forks" | grep -v "/$pr")
	done <<< "$my_prs"

	forks_with_no_prs="$my_forks"
	[[ -z "$forks_with_no_prs" ]] && print "\e[1;33mNo forks to delete.\e[0m" && return 0

	# INFO still require confirmation as a safety net
	# shellcheck disable=2001 # does not work for prepending
	print -z "$(echo "$forks_with_no_prs" | sed 's/^/gh repo delete /')"
}
#───────────────────────────────────────────────────────────────────────────────

# pickaxe entire repo history
function pickaxe {
	[[ -z $1 ]] && print "\e[1;33mNo search query provided.\e[0m" && return 1
	print "Reminder: Mostly, these are deletion commits. Thus, the checkout target should usually be the parent commit: \e[1;36mgit checkout {hash}^\e[0m"
	echo

	git log -G"$1" --regexp-ignore-case
}

#───────────────────────────────────────────────────────────────────────────────

# search for [g]it [d]eleted [f]ile
function gdf {
	git rev-parse --is-inside-work-tree &> /dev/null || return

	local search="$1"
	[[ -z $search ]] && print "\e[1;33mNo search query provided.\e[0m" && return 1
	if ! command -v fzf &> /dev/null; then echo "fzf not installed." && return 1; fi

	cd -q "$(git rev-parse --show-toplevel)" || return 1
	if [[ $(git rev-parse --is-shallow-repository) == "true" ]]; then
		print "\e[1;33mUnshallowing repo…\e[0m"
		unshallow && echo
	fi

	local deleted_path deletion_commit last_commit
	deleted_path=$(git log --diff-filter=D --name-only --format="" | grep --ignore-case "$search")

	# FIX for whatever reason, without this, a lot of `zsh` processes all taking
	# lots of CPU are accumulating
	sleep 1

	# TEST check for accumulating zsh processes bug
	trap 'echo ; ps cAo "%cpu,command" | grep --color=never "zsh\|%CPU"' EXIT

	if [[ -z "$deleted_path" ]]; then
		print "\e[1;31mNo deleted file found with \e[1;33m$search\\e[0m"
		return 1
	elif [[ $(echo "$deleted_path" | wc -l) -gt 1 ]]; then
		print "\e[1;34mMultiple files found.\e[0m"
		selection=$(echo "$deleted_path" | fzf --height=60%)
		[[ -z "$selection" ]] && return 127
		deleted_path="$selection"
	fi

	# alternative method: `git rev-list --max-count=1 HEAD -- "path/to/file"`
	deletion_commit=$(git log --format='%h' --max-count=1 -- "$deleted_path")
	last_commit=$(git rev-parse --short "$deletion_commit^")
	print "\e[1;33m$last_commit\e[0m $deleted_path"
	echo

	# decision on how to act on file
	choices="restore file\nshow file (bat) & copy\ncheckout commit"
	decision=$(echo "$choices" | fzf --no-sort --no-info --height=5 --layout=reverse-list)

	if [[ -z "$decision" ]]; then
		echo "Aborted."
	elif [[ "$decision" =~ restore ]]; then
		git restore --source="$last_commit" -- "$deleted_path"
		echo "File restored."
		open -R "$deleted_path" # reveal in macOS Finder
	elif [[ "$decision" =~ show ]]; then
		ext=${deleted_path##*.}
		git show "$last_commit:$deleted_path" | bat --language="$ext" ||
			git show "$last_commit:$deleted_path" | bat # unknown extension
		git show "$last_commit:$deleted_path" | pbcopy
	elif [[ "$decision" =~ checkout ]]; then
		git checkout "$last_commit"
	fi
}
