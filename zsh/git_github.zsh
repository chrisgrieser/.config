# ALIASES

# git
alias co="git checkout"
alias gg="git checkout -" # go to previous branch/commit, like `zz` switching to last directory
alias gs='git status'
alias ga="git add"
alias gM="git commit --amend" # amend + edit commit msg
alias gc="git commit"
alias push="ct git push"
alias pull="ct git pull"
alias g.='cd "$(git rev-parse --show-toplevel)"' # goto git root
alias grh='git reset --hard'

# github
alias gi='gh issue list'                # open issues
alias gI='gh issue list --state=closed' # closed issues
alias rel='ct make --silent release'

#───────────────────────────────────────────────────────────────────────────────

function pr() {
	# sset default remote, if it lacks one
	[[ -z "$(gh repo set-default --view)" ]] && gh repo set-default

	gh pr create --web --fill
}

# amend no-edit
function gm() {
	git add -A && git commit --amend --no-edit
	separator
	gitlog 4
}

# Github Url: open & copy url
function gu() {
	url=$(git remote -v | head -n1 | cut -f2 | cut -d' ' -f1 | sed -e 's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git//')
	echo "$url" | pbcopy
	open "$url"
}

function unlock() {
	rm "$(git rev-parse --git-dir)/index.lock"
	echo "Lock file removed."
}

# https://stackoverflow.com/a/17937889
function unshallow() {
	git fetch --unshallow
	git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
	git fetch origin
}

#───────────────────────────────────────────────────────────────────────────────
# GIT DIFF & DELTA

# use delta for small diffs and diff2html for big diffs
function gd() {
	if ! command -v diff2html &>/dev/null; then echo "diff2html not installed (\`npm -g install diff2html\`)." && return 1; fi
	if ! command -v delta &>/dev/null; then echo "delta not installed (\`brew install git-delta\`)" && return 1; fi

	local threshold_lines=80
	if [[ $(git diff | wc -l) -gt $threshold_lines ]]; then
		diff2html --hwt="$DOTFILE_FOLDER/diff2html/diff2html-template.html"
	else
		if defaults read -g AppleInterfaceStyle &>/dev/null; then
			git -c delta.dark=true diff
		else
			git -c delta.light=true diff
		fi
	fi
}

# make delta theme-aware
function delta() {
	if defaults read -g AppleInterfaceStyle &>/dev/null; then
		command delta --dark "$@"
	else
		command delta --light "$@"
	fi
}

#───────────────────────────────────────────────────────────────────────────────
# GIT LOG

function gitlog() {
	# DOCS https://git-scm.com/docs/git-log#_pretty_formats
	local length
	[[ -n "$1" ]] && length="-n $1"
	# shellcheck disable=2086
	git log $length --all --color --graph \
		--format='%C(yellow)%h%C(red)%d%C(reset) %s %C(green)(%cr) %C(bold blue)<%an>%C(reset)' |
		sed -e 's/ seconds ago)/s)/' \
			-e 's/ minutes ago)/m)/' \
			-e 's/ hours ago)/h)/' \
			-e 's/ days ago)/d)/' \
			-e 's/ weeks ago)/w)/' \
			-e 's/ months ago)/mo)/' \
			-e 's/grafted/ /' \
			-e 's/origin\//󰞶  /g' \
			-e 's/HEAD/󱍀 /g' \
			-e 's/->/󰔰 /g' \
			-e 's/tags: / )/' \
			-e 's/, / · /g'
}

# brief git log (only last 15)
function gl() {
	local cutoff=15
	gitlog 15
	# add `(…)` if commits were shortened
	[[ $(git log --oneline | wc -l) -gt $cutoff ]] && echo "(…)"
}

# full git log
function gll() {
	gitlog
}

# interactive
function gli() {
	if ! command -v fzf &>/dev/null; then echo "fzf not installed." && return 1; fi

	local hash key_pressed selected
	selected=$(
		git log --all --color=always --pretty=format:'%h %s %C(green)%ch %C(red)%D%C(reset)' |
			fzf -0 --query="$1" \
				--ansi --no-sort --no-info \
				--nth=2.. --with-nth=2.. \
				--header-first --header="↵ : Checkout  ^H: Copy [H]ash  ^R: [R]eset Hard" \
				--expect="ctrl-h,ctrl-r" \
				--preview="git --no-optional-locks show {1} --name-only --color=always --pretty=format:'%C(yellow)%h %C(red)%D %n%C(green)%ch %C(blue)%an%C(reset) %n%n%C(bold)%s %n%C(reset)%n---%n%C(magenta)'"
	)
	[[ -z "$selected" ]] && return 0
	key_pressed=$(echo "$selected" | head -n1)
	hash=$(echo "$selected" | cut -d' ' -f1 | tail -n+2)

	if [[ "$key_pressed" == "ctrl-h" ]]; then
		echo "$hash" | pbcopy
		echo "'$hash' copied."
	elif [[ "$key_pressed" == "ctrl-r" ]]; then
		git reset --hard "$hash"
	else # pressed return
		git checkout "$hash"
	fi
}

#───────────────────────────────────────────────────────────────────────────────
# SELECT BRANCH

function gb() {
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

# first arg: commit msg
# remaining args: files to add (no remaining args = all files)
# no args: "chore" as commit msg & all files added
function ac() {
	if ! command -v ct &>/dev/null; then print "\033[1;33mchromaterm not installed. (\`pip3 install chromaterm\`)\033[0m" && return 1; fi
	local large_files commit_msg msg_length

	# guard 1: accidental pushing of large files
	large_files=$(find . -not -path "**/.git/**" -not -path "**/*.pxd/**" -not -path "**/node_modules/**" -size +10M)
	if [[ -n "$large_files" ]]; then
		print "\033[1;33mLarge file(s) detected, aborting."
		print "$large_files\033[0m"
		return 1
	fi
	# guard 2: forgot quotes
	if [[ $# -gt 1 && ! -f "$2" ]]; then
		print "\033[1;33m'$2' not a file, aborting.\033[0m"
		return 1
	fi

	# commit msg
	if [[ $# -eq 0 ]]; then
		commit_msg="chore"
	else
		commit_msg="$1"
		# ensure no overlength of commit msg
		msg_length=${#commit_msg}
		if [[ $msg_length -gt 50 ]]; then
			echo "Commit Message too long ($msg_length chars)."
			commit_msg=${commit_msg::50}
			print -z "acp \"$commit_msg\"" # put back into buffer
			return 1
		fi
	fi
	# adding
	if [[ $# -gt 1 ]]; then
		shift
		ct git add "$@"
	else
		ct git add -A
	fi

	ct git commit -m "$commit_msg"
}

# same as ac, just git pull & push
function acp() {
	ac "$@" || return 1 # fail if ac fails

	ct git pull && ct git push
	sketchybar --trigger repo-files-update
}

#───────────────────────────────────────────────────────────────────────────────

function clone() {
	if ! command -v ct &>/dev/null; then print "\033[1;33mchromaterm not installed. (\`pip3 install chromaterm\`)\033[0m" && return 1; fi

	url="$1"
	# turn http into SSH remotes
	[[ "$url" =~ http ]] && url="$(echo "$1" | sed -E 's/https?:\/\/github.com\//git@github.com:/').git"

	# WARN depth=2 ensures that amending a shallow commit does not result in a
	# new commit without parent, effectively destroying git history (!!)
	ct git clone --depth=2 --filter=blob:none "$url"

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
	local_repo_path=$(pwd)
	# shellcheck disable=2103
	cd ..

	command rm -rf "$local_repo_path"
	printf "\033[1;34mLocal repo removed."
	printf "Cloning repo again from remote…\033[0m"
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
function gdf() {
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
		print "🔍\033[1;32m One file found:"
	else
		print "🔍\033[1;32m Selected file:"
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
