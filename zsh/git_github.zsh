# shellcheck disable=SC2164

# ALIASES AND SMALLER UTILS
alias co="git checkout"
alias gs='git status'
alias gd='git diff'
alias gc="git commit -m"
alias ga="git add"
alias grh="git reset --hard"
alias push="git push"
alias pull="git pull --recurse-submodules"
alias gm="git commit --amend --no-edit" # a[m]end
alias gM="git commit --amend"
alias gg="git checkout -" # go to previous branch/commit, like `zz` switching to last directory

# open GitHub repo
function getGithubURL() {
	git remote -v | head -n1 | cut -f2 | cut -d' ' -f1 | sed -e's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git//'
}

# open at github % copy url
function gh() {
	getGithubURL | pbcopy
	open "$(getGithubURL)"
}
alias gi='open "$(getGithubURL)/issues"'

#───────────────────────────────────────────────────────────────────────────────
# GIT LOG

# short (only last 15 messages)
alias gl="git log -n 15 --all --graph --pretty=format:'%C(yellow)%h%C(red)%d%C(reset) %s %C(green)(%ch) %C(bold blue)<%an>%C(reset)' ; echo '(…)'"

# long
# append `true` to avoid exit code 141: https://www.ingeniousmalarkey.com/2016/07/git-log-exit-code-141.html
alias gll="git log --all --graph --pretty=format:'%C(yellow)%h%C(red)%d%C(reset) %s %C(green)(%ch) %C(bold blue)<%an>%C(reset)' ; true"

# interactive
function gli() {
	if ! command -v fzf &>/dev/null; then echo "fzf not installed." && return 1; fi

	local hash key_pressed selected
	selected=$(
		git log --all --color=always --pretty=format:'%h %s %C(green)%ch %C(red)%D%C(reset)' |
			fzf -0 \
				--query="$1" \
				--ansi \
				--nth=2.. \
				--with-nth=2.. \
				--no-sort \
				--layout=reverse-list \
				--no-info \
				--header-first --header="↵ : Checkout  ^H: Copy [H]ash  ^R: [R]eset Hard" \
				--expect="ctrl-h,ctrl-r" \
				--preview-window="wrap" \
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

	selected_branch=$(
		git branch --color | fzf \
			--ansi \
			--layout=reverse \
			--no-info \
			--query "$*" \
			--height=40% \
			--header-first --header="↵ : Checkout Branch"
	)
	[[ -z "$selected_branch" ]] && return 0

	selected_branch=$(echo "$selected_branch" | tr -d "* ")
	git checkout "$selected_branch"
}

#───────────────────────────────────────────────────────────────────────────────
# GIT ADD, COMMIT, (PULL) & PUSH

function acp() {
	# safeguard against accidental pushing of large files
	NUMBER_LARGE_FILES=$(find . -not -path "**/.git/**" -not -path "**/*.pxd/**" -size +10M | wc -l | xargs)
	if [[ $NUMBER_LARGE_FILES -gt 0 ]]; then
		echo "$NUMBER_LARGE_FILES large file(s) detected, aborting."
		find . -not -path "**/.git/**" -not -path "**/*.pxd/**" -size +10M
		echo
		return 1
	fi

	local COMMIT_MSG="$*"
	[[ -z "$COMMIT_MSG" ]] && COMMIT_MSG="chore"

	# shellcheck disable=2155
	local first_word=$(echo "$COMMIT_MSG" | grep -oe "^\w*")
	conventional_commits="feat chore build fix perf refactor style ci docs test revert"
	local MSG_LENGTH=${#COMMIT_MSG}

	# ensure no overlength
	if [[ $MSG_LENGTH -gt 50 ]]; then
		echo "Commit Message too long ($MSG_LENGTH chars)."
		COMMIT_MSG=${COMMIT_MSG::50}
		print -z "acp \"$COMMIT_MSG\"" # put back into buffer
		return 1
	# enforce conventional commits
	elif ! [[ "$conventional_commits" =~ $first_word ]]; then
		echo "'$first_word' not a conventional commits keyword."
		print -z "acp \"$COMMIT_MSG\""
		return 1
	fi

	git add -A && git commit -m "$COMMIT_MSG"
	git pull --recurse-submodules
	git push

	# check if variable starts with variable: https://unix.stackexchange.com/a/465907
	if [[ "$PWD" == "${PWD#"$DOTFILE_FOLDER"}" ]] || [[ "$PWD" == "${PWD#"$VAULT_PATH"}" ]]; then
		sketchybar --trigger repo-files-update
	fi
}

#───────────────────────────────────────────────────────────────────────────────

# regular clone, optionally take depth as first argument and url as second
function clone() {
	if [[ "$1" =~ ^[0-9]+$ ]]; then
		betterClone "$2" "$1" # switch order for betterClone function
	else
		betterClone "$1"
	fi
}

# shallow clone (depth 1, single branch, no blob)
function sclone() { # shallow clone
	betterClone "$1" "shallow"
}

# 1: remote url (github URL will be converted to SSH)
# 2: mode - shallow|number shallow clone or clone with depth
function betterClone() {
	if [[ "$1" =~ http ]]; then # safety net to not accidentally use https
		giturl="$(echo "$1" | sed -E 's/https?:\/\/github.com\//git@github.com:/').git"
	else
		giturl="$1"
	fi
	if [[ "$2" == "shallow" ]]; then
		git clone --depth=1 --single-branch --filter=blob:none "$giturl"
	elif [[ $2 =~ ^[0-9]+$ ]]; then # if a numbered argument, use it for depth
		git clone --depth="$2" "$giturl"
	else
		git clone "$giturl"
	fi
	# shellcheck disable=SC2012
	cd "$(ls -1 -t | head -n1)" || return

	if grep -q "obsidian" package.json &>/dev/null; then
		print "\n\033[1;34mDetected Obsidian plugin. Installing NPM dependencies…\033[0m"
		if ! command -v node &>/dev/null; then print "\033[1;33mnode not installed, not running npm." && return 0; fi
		npm i
		print "\n\033[1;34mBuilding…\033[0m"
		npm run build
	fi
}

# delete and re-clone git repo (with depth 10)
function nuke {
	is_submodule=$(git rev-parse --show-superproject-working-tree)
	if [[ -n "$is_submodule" ]]; then
		print "\033[1;33mAborting. nuke function has not been implemented for git submodules yet."
		return 1
	fi
	SSH_REMOTE=$(git remote -v | head -n1 | cut -d" " -f1 | cut -d$'	' -f2)

	# go to git repo root
	r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && cd "${r%%/.git/*}"
	LOCAL_REPO=$(pwd)
	cd ..

	rm -rvf "$LOCAL_REPO"
	print "\033[1;34m--------------"
	echo "Local repo removed."
	echo "Cloning repo again from remote… (with depth 10)"
	print "--------------\033[0m"

	git clone --depth=10 "$SSH_REMOTE" "$LOCAL_REPO" && cd "$LOCAL_REPO" || return 1
}

#───────────────────────────────────────────────────────────────────────────────

# runs a release scripts placed at the git root
function rel() {
	# shellcheck disable=SC2164
	if [[ -f .release.sh ]]; then
		zsh .release.sh "$*"
	elif [[ -f ../.release.sh ]]; then
		zsh ../.release.sh "$*"
	elif [[ -f ../../.release.sh ]]; then
		zsh ../../.release.sh "$*"
	elif [[ -f ../../../.release.sh ]]; then
		zsh ../../../.release.sh "$*"
	else
		print "\033[1;31mNo '.release.sh' found.\033[0m"
	fi
}

#───────────────────────────────────────────────────────────────────────────────

# search for [g]it [d]eleted [f]ile
function gdf() {
	if ! command -v fzf &>/dev/null; then echo "fzf not installed." && return 1; fi
	if ! command -v bat &>/dev/null; then echo "bat not installed." && return 1; fi

	local deleted_path deletion_commit
	r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && cd "${r%%/.git/*}" # goto git root

	# alternative method: `git rev-list -n 1 HEAD -- "**/*$1*"` to get the commit of a deleted file
	deleted_path=$(git log --diff-filter=D --summary | grep delete | grep -i "$*" | cut -d" " -f5-)

	if [[ -z "$deleted_path" ]]; then
		print "🔍\033[1;31m No deleted file found."
		return 1
	elif [[ $(echo "$deleted_path" | wc -l) -gt 1 ]]; then
		print "🔍\033[1;34m Multiple files found."
		echo
		selection=$(echo "$deleted_path" | fzf --layout=reverse --height=70%)
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
	echo "$deleted_path"
	echo
	print "\033[1;34m-------------------------------------"
	echo "[r]estore file (checkout)"
	echo "[s]how file (bat)"
	echo "[c]opy content"
	echo "[h]ash of last commit with the file"
	print "\-------------------------------------\033[0m"
	echo -n "> "
	read -r -k 1 DECISION
	echo

	# shellcheck disable=SC2193
	if [[ "$DECISION:l" == "c" ]]; then
		git show "$last_commit:$deleted_path" | pbcopy
		echo "Content copied."
	elif [[ "$DECISION:l" == "h" ]]; then
		echo "$last_commit" | pbcopy
		echo "Hash \"$last_commit\" copied."
	elif [[ "$DECISION:l" == "r" ]]; then
		git checkout "$last_commit" -- "$deleted_path"
	elif [[ "$DECISION:l" == "s" ]]; then
		ext=${deleted_path##*.}
		git show "$last_commit:$deleted_path" | bat --language="$ext"
	fi
}

#───────────────────────────────────────────────────────────────────────────────
