# shellcheck disable=SC2164,SC2030,SC2012

alias co="git checkout"
alias gs='git status'
alias gd='git diff'
alias gc="git commit -m"
alias ga="git add"
alias gr="git reset"
alias grh="git reset --hard"
alias push="git push"
alias pull="git pull"

# go to git root https://stackoverflow.com/a/38843585
# shellcheck disable=2031
alias g.='r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && cd "${r%%/.git/*}"'
alias gg="git checkout -" # go to last branch, analogues to `zz` switching to last directory

# open GitHub repo
function getGithubURL() {
	git remote -v | head -n1 | cut -f2 | cut -d' ' -f1 | sed -e's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git//'
}
alias gh="getGithubURL | xargs open"
alias ghi='open "$(getGithubURL)/issues"'

#───────────────────────────────────────────────────────────────────────────────

# git log
# append `true` to avoid exit code 141: https://www.ingeniousmalarkey.com/2016/07/git-log-exit-code-141.html
alias gl="git log --all --graph --pretty=format:'%C(yellow)%h%C(red)%d%C(reset) %s %C(green)(%ch) %C(bold blue)<%an>%C(reset)' ; true"

# git log (interactive)
function gli() {
	local hash key_pressed selected
	selected=$(
		git log --all --color=always --pretty=format:'%h %s %C(green)%ch %C(red)%D%C(reset)' | fzf \
			-0 \
			--query="$1" \
			--ansi \
			--nth=2.. \
			--with-nth=2.. \
			--no-sort \
			--no-info \
			--header-first --header="↵ : checkout  ^H: copy [h]ash  ^R: [r]eset" \
			--expect="ctrl-h,ctrl-r" \
			--preview-window="wrap" \
			--preview="git show {1} --name-only --color=always --pretty=format:'%C(yellow)%h %C(red)%D %n%C(green)%ch %C(blue)%an%C(reset) %n%n%C(bold)%s %n%C(reset)%n---%n%C(magenta)'"
	)
	[[ -z "$selected" ]] && return 0
	key_pressed=$(echo "$selected" | head -n1)
	hash=$(echo "$selected" | cut -d' ' -f1 | tail -n+2)

	if [[ "$key_pressed" == "ctrl-h" ]]; then
		echo "$hash" | pbcopy
		echo "$hash copied."
	elif [[ "$key_pressed" == "ctrl-r" ]]; then
		git reset "$hash"
	else
		git checkout "$hash"
	fi
}

#───────────────────────────────────────────────────────────────────────────────

# git add, commit, (pull) & push
function acp() {
	# safeguard against accidental pushing of large files
	NUMBER_LARGE_FILES=$(find . -not -path "**/.git/**" -not -path "**/*.pxd/**" -not -path "**/coc/extensions/**" -size +10M | wc -l | xargs)
	if [[ $NUMBER_LARGE_FILES -gt 0 ]]; then
		echo "$NUMBER_LARGE_FILES large file(s) detected, aborting."
		find . -not -path "**/.git/**" -not -path "**/*.pxd/**" -size +10M
		echo
		return 1
	fi

	local COMMIT_MSG="$*"
	[[ -z "$COMMIT_MSG" ]] && COMMIT_MSG="chore"
	# shellcheck disable=2155
	local first_word=$(echo "$COMMIT_MSG" | grep -e "^\w*")
	conventional_commits="feat chore build fix perf refactor style ci docs test revert"
	local MSG_LENGTH=${#COMMIT_MSG}

	if [[ $MSG_LENGTH -gt 50 ]]; then
		echo "Commit Message too long ($MSG_LENGTH chars)."
		COMMIT_MSG=${COMMIT_MSG::50}
		print -z "acp \"$COMMIT_MSG\"" # put back into buffer
		return 1
	elif ! [[ "$conventional_commits" =~ $first_word ]]; then
		echo "'$first_word' not a conventional commits keyword."
		print -z "acp \"$COMMIT_MSG\"" 
		return 1
	fi

	git add -A && git commit -m "$COMMIT_MSG"
	git pull
	git push
}

#───────────────────────────────────────────────────────────────────────────────

function clone() {
	betterClone "$*" "normal"
}

function sclone() { # shallow clone
	betterClone "$*" "shallow"
}

function betterClone() {
	if [[ "$1" =~ http ]]; then # safety net to not accidentally use https
		giturl="$(echo "$1" | sed -E 's/https?:\/\/github.com\//git@github.com:/').git"
	else
		giturl="$1"
	fi
	if [[ "$2" == "shallow" ]]; then
		git clone --depth=1 --single-branch --filter=blob:none "$giturl"
	else
		git clone "$giturl"
	fi
	# shellcheck disable=SC2012
	cd "$(ls -1 -t | head -n1)" || return
	if grep -q "obsidian" package.json &>/dev/null; then
		npm i # if it's an Obsidian plugin
		npm run build
	fi
}

function nuke {
	SSH_REMOTE=$(git remote -v | head -n1 | cut -d" " -f1 | cut -d$'	' -f2)

	# go to git repo root
	r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && cd "${r%%/.git/*}"
	LOCAL_REPO=$(pwd)
	cd ..

	rm -rvf "$LOCAL_REPO"
	echo "---"
	echo "Local repo removed."
	echo
	echo "Downloading repo again from remote…"
	echo "---"

	git clone "$SSH_REMOTE" "$LOCAL_REPO" && cd "$LOCAL_REPO"
}

#───────────────────────────────────────────────────────────────────────────────

# runs a release scripts placed at the git root
function rel() {
	# shellcheck disable=SC2164
	if [[ -f .release.sh ]]; then
		zsh .release.sh "$*"
	elif [[ -f ../.release.sh ]]; then
		cd ..
		zsh .release.sh "$*"
	elif [[ -f ../../.release.sh ]]; then
		cd ../..
		zsh .release.sh "$*"
	elif [[ -f ../../../.release.sh ]]; then
		cd ../../..
		zsh .release.sh "$*"
	else
		echo "No '.release.sh' found."
	fi
}

#───────────────────────────────────────────────────────────────────────────────

# search for [g]it [d]eleted [f]ile -> https://stackoverflow.com/a/42582877
function gdf() {
	local deleted_path deletion_commit
	if ! command -v bat &>/dev/null; then echo "bat not installed." && exit 1; fi

	# goto git root
	r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && cd "${r%%/.git/*}"

	# alternative method: `git rev-list -n 1 HEAD -- "**/*$1*"` to get the commit of a deleted file
	deleted_path=$(git log --diff-filter=D --summary | grep delete | grep -i "$*" | cut -d" " -f5-)

	if [[ $(echo "$deleted_path" | wc -l) -gt 1 ]]; then
		echo "🔍 multiple files found: "
		echo "$deleted_path"
		echo
		echo "ℹ️ narrow down query so only one file is selected."
		return 0
	elif [[ -z "$deleted_path" ]]; then
		echo "🔍 no deleted file found"
		return 1
	fi

	deletion_commit=$(git log --format='%h' --follow -- "$deleted_path" | head -n1)
	last_commit=$(git show --format='%h' "$deletion_commit^" | head -n1)

	echo "🔍 last version found: '$deleted_path' ($last_commit)"
	echo
	echo "c: checkout file, o: open file"
	read -r -k 1 DECISION
	# shellcheck disable=SC2193
	if [[ "$DECISION:l" == "c" ]]; then
		git checkout "$last_commit" -- "$deleted_path"
	elif [[ "$DECISION:l" == "o" ]]; then
		git show "$last_commit:$deleted_path" | bat
	fi
}

#───────────────────────────────────────────────────────────────────────────────
