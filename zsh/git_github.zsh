# shellcheck disable=SC2164,SC2030,SC2012

# git log
# append `true` to avoid exit code 141: https://www.ingeniousmalarkey.com/2016/07/git-log-exit-code-141.html
alias gl="git log --graph --pretty=format:'%C(yellow)%h%C(red)%d%C(reset) %s %C(green)(%ch) %C(bold blue)<%an>%C(reset)' ; true"

# git log (interactive)
function gli() {
	local hash key_pressed selected
	selected=$(
		git log --color=always --pretty=format:'%h %s %C(green)%ch %C(red)%D%C(reset)' |
			fzf -0 \
				--query="$1" \
				--ansi \
				--nth=2.. \
				--with-nth=2.. \
				--no-sort \
				--no-info \
				--header-first --header="↵ : checkout  ^H: copy [h]ash  ^R: reset" \
				--expect=ctrl-h \
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
	local MSG_LENGTH=${#COMMIT_MSG}
	if [[ $MSG_LENGTH -gt 50 ]]; then
		echo "Commit Message too long ($MSG_LENGTH chars)."
		print -z "acp \"$COMMIT_MSG\"" # put back into buffer
		return 1
	fi
	if [[ "$COMMIT_MSG" == "" ]]; then
		COMMIT_MSG="chore"
	fi

	git add -A && git commit -m "$COMMIT_MSG"
	git pull
	git push

	# open issue automatically
	if [[ "$COMMIT_MSG" =~ "#" ]]; then
		issueNumber=$(echo "$COMMIT_MSG" | grep -Eo "#\d+" | cut -c2-)
		open "$(getGithubURL)/issues/$issueNumber"
	fi
}

function amend() {
	local COMMIT_MSG="$*"
	local LAST_COMMIT_MSG
	LAST_COMMIT_MSG=$(git log -1 --pretty=%B | head -n1)
	local MSG_LENGTH=${#COMMIT_MSG}
	if [[ $MSG_LENGTH -gt 50 ]]; then
		echo "Commit Message too long ($MSG_LENGTH chars)."
		[[ "$TERM" != "alacritty" ]] && return 1
		print -z "\"$COMMIT_MSG\""
		return 1
	fi
	if [[ -z "$COMMIT_MSG" ]]; then
		# prefile last commit message
		# shellcheck disable=1087
		FUNC_NAME="$funcstack[1]" # https://stackoverflow.com/a/62527825
		print -z "$FUNC_NAME \"$LAST_COMMIT_MSG\""
		return 0
	else
		git commit --amend -m "$COMMIT_MSG" # directly set new commit message
	fi
	# ⚠️ only when working alone – might lead to conflicts when working
	# with collaboraters: https://stackoverflow.com/a/255080
	git push --force
}

#───────────────────────────────────────────────────────────────────────────────

function gittree() { (
	r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && cd "${r%%/.git/*}"
	command exa --long --git --git-ignore --no-user --no-permissions --no-time --no-filesize --ignore-glob=.git --tree --color=always | grep -v "\--"
); }

alias gc="git checkout"
alias gs='git status'
alias gd='git diff'
alias gt='gittree'
alias add="git add"
alias commit="git commit -m"
alias push="git push"
alias pull="git pull"

# go to git root https://stackoverflow.com/a/38843585
# shellcheck disable=2031
alias g='r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && cd "${r%%/.git/*}"'
alias gg="git checkout -" # go to last branch, analogues to `zz` switching to last directory

# open GitHub repo
function getGithubURL() {
	git remote -v | head -n1 | cut -f2 | cut -d' ' -f1 | sed -e's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git//'
}
alias gh="getGithubURL | xargs open"
alias ghi='open "$(getGithubURL)/issues"'

#───────────────────────────────────────────────────────────────────────────────

function clone() {
	betterClone "$*" "normal"
}

function sclone() { # shallow clone
	betterClone "$*" "shallow"
}

function betterClone() {
	if [[ "$1" =~ "http" ]]; then # safety net to not accidentally use https
		giturl="git@github.com:$(echo "$1" | sed 's/https:\/\/github.com\///' | sed 's/.git.git/.git/')"
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
	# alternative method: `git rev-list -n 1 HEAD -- "**/*$1*"` to get the commit
	# of a deleted file
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
		git show "$last_commit:$deleted_path" | less
	fi
}
