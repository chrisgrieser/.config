# git add, commit & push
function acp (){
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

	git add -A
	git commit -m "$COMMIT_MSG"
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

alias gc="git commit -m"
alias ga="git add"
alias ignored="git status --ignored"
alias status='git status --short'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"

# go to git root https://stackoverflow.com/a/38843585
alias groot='r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && cd "${r%%/.git/*}"'

# open GitHub repo
alias gh="open \$(git remote -v | grep git@github.com | grep fetch | head -n1 | cut -f2 | cut -d' ' -f1 | sed -e's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git//' );"
alias ghi="open \$(git remote -v | grep git@github.com | grep fetch | head -n1 | cut -f2 | cut -d' ' -f1 | sed -e's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git//' )/issues;"

function clone(){
	git clone "$*"
	# shellcheck disable=SC2012
	z "$(ls -1 -t | head -n1)" || return

	grep -q "obsidian" package.json &> /dev/null && npm i # if it's an Obsidian plugin
}

function sclone(){
	git clone --depth=1 "$*"
	# shellcheck disable=SC2012
	z "$(ls -1 -t | head -n1)" || return

	grep -q "obsidian" package.json &> /dev/null && npm i # if it's an Obsidian plugin
}

function nuke {
	SSH_REMOTE=$(git remote -v | head -n1 | cut -d" " -f1 | cut -d$'	' -f2)

	# go to git repo root
	# shellcheck disable=SC2164
	r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && cd "${r%%/.git/*}"
	LOCAL_REPO=$(pwd)
	cd ..

	rm -rf "$LOCAL_REPO"
	echo "Local repo removed."

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

# searches for $1 in the git history of $2
function past (){
	start_dir="$PWD"
	query="$1"
	file_path="$2"
	file_name="$(basename "$file_path")"
	cd "$(dirname "$file_path")" || return 1

	commit_list=$(git log --pretty=format:%h -S "$query" -- "$file_path")
	if [[ -z $commit_list ]] ; then
		echo "\"$query\" cannot be found in the history of \"$file_name\"."
		return 1
	fi

	echo "$commit_list" | while read -r commit ; do
		commit_date="$(git show -s --format=%ci "$commit" | cut -d" " -f1-2 | tr ":" "-")"
		new_file="${commit_date}_$file_name"
		git show "$commit:./$file_name" > "$start_dir/$new_file"
		echo "$new_file"
		grep -i --context=1 "$query" "$new_file"
		echo "**************************************************"
	done
	cd "$start_dir"
}
