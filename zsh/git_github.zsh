# shellcheck disable=SC2164,SC2030,SC2012

# git log
# append `true` to avoid exit code 141: https://www.ingeniousmalarkey.com/2016/07/git-log-exit-code-141.html
alias gl="git log --graph --pretty=format:'%C(yellow)%h%C(red)%d%C(reset) %s %C(green)(%ch) %C(bold blue)<%an>%C(reset)' ; true"

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
	NUMBER_LARGE_FILES=$(find . -not -path "**/.git/**" -not -path "**/*.pxd/**" -size +10M | wc -l | xargs)
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

	# update sketchybar
	if [[ "$(git remote -v)" =~ "dotfiles" || "$(git remote -v)" =~ "vault" ]] ; then
		sketchybar --update
	fi
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

function gg(){
	git branch --format='%(refname:short)'

}

alias gc="git checkout"
alias gs='git status'
alias gt='gittree'
alias add="git add"
alias commit="git commit -m"
alias push="git push"
alias pull="git pull"
alias ignored="git status --ignored"

# go to git root https://stackoverflow.com/a/38843585
alias g='r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && cd "${r%%/.git/*}"'
alias gg="git checkout -" # go to last branch, analogues to `zz` switching to last directory


# open GitHub repo
alias gh="open \$(git remote -v | grep git@github.com | grep fetch | head -n1 | cut -f2 | cut -d' ' -f1 | sed -e's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git//' );"
alias ghi="open \$(git remote -v | grep git@github.com | grep fetch | head -n1 | cut -f2 | cut -d' ' -f1 | sed -e's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git//' )/issues;"

function clone(){
	git clone "$*"
	# shellcheck disable=SC2012
	z "$(ls -1 -t | head -n1)" || return

	if grep -q "obsidian" package.json ; then
		npm i # if it's an Obsidian plugin
	fi
}

# shallow clone
function sclone(){
	git clone --depth=1 "$*"
	z "$(ls -1 -t | head -n1)" || return

	if grep -q "obsidian" package.json ; then
		npm i # if it's an Obsidian plugin
	fi
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
	if [[ -f .release.sh ]] ; then
		zsh .release.sh "$*"
	elif [[ -f ../.release.sh ]] ; then
		zsh ../.release.sh "$*"
	elif [[ -f ../../.release.sh ]] ; then
		zsh ../../.release.sh "$*"
	else
		echo "No '.release.sh' found."
	fi
}

# search for [g]it [d]eleted [f]ile -> https://stackoverflow.com/a/42582877
function gdf() {
	local deleted_path deletion_commit
	deleted_path=$(git log --diff-filter=D --summary | grep delete | grep -i "$*" | cut -d" " -f5-)
	if [[ $(echo "$deleted_path" | wc -l) -gt 1 ]] ; then
		echo "🔍 multiple files found: "
		echo "$deleted_path"
		echo
		echo "ℹ️ narrow down query so only one file is selected."
		return 0
	elif [[ -z "$deleted_path" ]] ; then
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
	if [[ "$DECISION:l" == "c" ]] ; then
		git checkout "$last_commit" -- "$deleted_path"
	elif [[ "$DECISION:l" == "o" ]] ; then
		git show "$last_commit:$deleted_path" | less
	fi
}
