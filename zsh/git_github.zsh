# shellcheck disable=SC2164

# git log
alias gl="git log --graph --pretty=format:'%C(yellow)%h%C(red)%D%C(reset) %s %C(green)(%ch) %C(bold blue)<%an>%C(reset)'"

# git log (interactive)
function gli (){
	local hash key_pressed selected

	selected=$(git log --color=always --pretty=format:'%h %s %C(green)%ch %C(red)%D%C(reset)' | \
	   fzf -0 \
		--query="$1" \
		--ansi \
		--nth=2.. \
		--with-nth=2.. \
		--no-sort \
		--no-info \
		--header-first --header="↵ : checkout   ^H: copy [h]ash" \
		--expect=ctrl-h \
		--preview-window="wrap" \
		--preview="git show {1} --name-only --color=always --pretty=format:'%C(yellow)%h %C(red)%D %n%C(green)%ch %C(blue)%an%C(reset) %n%n%C(bold)%s %n%C(reset)%C(magenta)'"\
	)
	[[ -z "$selected" ]] && return 0
	key_pressed=$(echo "$selected" | head -n1)
	hash=$(echo "$selected" | cut -d' ' -f1 | tail -n+2)

	if [[ "$key_pressed" == "ctrl-h" ]] ; then
		echo "$hash" | pbcopy
		echo "$hash copied."
	else
		git checkout "$hash"
	fi
}

# git add, commit, (pull) & push
function acp (){
	# safeguard against accidental pushing of large files
	NUMBER_LARGE_FILES=$(find . -not -path "**/.git/**" -size +10M | wc -l | xargs)
	if [[ $NUMBER_LARGE_FILES -gt 0 ]]; then
		echo -n "$NUMBER_LARGE_FILES Large files detected, aborting automatic git sync."
		exit 1
	fi

	local COMMIT_MSG="$*"
	local MSG_LENGTH=${#COMMIT_MSG}
	if [[ $MSG_LENGTH -gt 50 ]]; then
		echo "Commit Message too long ($MSG_LENGTH chars)."
		# shellcheck disable=SC1087,SC2154
		FUNC_NAME="$funcstack[1]" # https://stackoverflow.com/a/62527825
		print -z "$FUNC_NAME \"$COMMIT_MSG\"" # put back into buffer
		return 1
	fi
	if [[ "$COMMIT_MSG" == "" ]] ; then
		COMMIT_MSG="patch"
	fi

	git add -A && git commit -m "$COMMIT_MSG"
	git pull
	git push
}

function amend () {
	local COMMIT_MSG="$*"
	local LAST_COMMIT_MSG
	LAST_COMMIT_MSG=$(git log -1 --pretty=%B | head -n1)
	local MSG_LENGTH=${#COMMIT_MSG}
	if [[ $MSG_LENGTH -gt 50 ]]; then
		echo "Commit Message too long ($MSG_LENGTH chars)."
		print -z "\"$COMMIT_MSG\""
		return 1
	fi
	if [[ "$COMMIT_MSG" == "" ]] ; then
		# prefile last commit message
		print -z "amend \"$LAST_COMMIT_MSG\""
		return 0
	else
		git commit --amend -m "$COMMIT_MSG" # directly set new commit message
	fi
	# ⚠️ only when working alone – might lead to conflicts when working
	# with collaboraters: https://stackoverflow.com/a/255080
	git push --force
}

function gittree(){
	(
		r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && cd "${r%%/.git/*}"
		command exa --long --git --git-ignore --no-user --no-permissions --no-time --no-filesize --ignore-glob=.git --tree --color=always | grep -v "\--"
	)
}

alias gc="git checkout"
alias add="git add -A"
alias commit="git commit -m"
alias push="git push"
alias pull="git pull"
alias ignored="git status --ignored"

# go to git root https://stackoverflow.com/a/38843585
alias g='r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && cd "${r%%/.git/*}"'
alias gs='git status'
alias gt='gittree'

# open GitHub repo
alias gh="open \$(git remote -v | grep git@github.com | grep fetch | head -n1 | cut -f2 | cut -d' ' -f1 | sed -e's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git//' );"
alias ghi="open \$(git remote -v | grep git@github.com | grep fetch | head -n1 | cut -f2 | cut -d' ' -f1 | sed -e's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git//' )/issues;"

function clone(){
	git clone "$*"
	# shellcheck disable=SC2012
	z "$(ls -1 -t | head -n1)" || return

	grep -q "obsidian" package.json &> /dev/null && npm i # if it's an Obsidian plugin
}

# shallow clone
function sclone(){
	git clone --depth=1 "$*"
	# shellcheck disable=SC2012
	z "$(ls -1 -t | head -n1)" || return

	grep -q "obsidian" package.json &> /dev/null && npm i # if it's an Obsidian plugin
}

function nuke {
	SSH_REMOTE=$(git remote -v | head -n1 | cut -d" " -f1 | cut -d$'	' -f2)

	# go to git repo root
	r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && cd "${r%%/.git/*}"
	LOCAL_REPO=$(pwd)
	cd ..

	rm -rf "$LOCAL_REPO"
	echo "---"
	echo "Local repo removed."
	echo
	echo "Downloading repo again from remote…"
	echo "---"

	git clone "$SSH_REMOTE"
	cd "$LOCAL_REPO" || return 1
}

# runs a release scripts placed at the git root
function rel(){
	# shellcheck disable=SC2164
	r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && cd "${r%%/.git/*}"
	if [[ -f .release.sh ]] ; then
		zsh .release.sh "$*"
	else
		echo "No '.release.sh' found."
	fi
}

