#!/usr/bin/env zsh
# INFO LOCAL_REPOS defined in .zshenv
#───────────────────────────────────────────────────────────────────────────────

# use SSH instead of https
url="$(echo "$*" | sed -E 's/https?:\/\/github.com\//git@github.com:/').git"
reponame=$(echo "$*" | sed -E 's/.*\///')

[[ ! -e "$LOCAL_REPOS" ]] && mkdir -p "$LOCAL_REPOS"
cd "$LOCAL_REPOS" || exit 1

if [[ -e "$reponame" ]]; then
	osascript -e 'display notification "" with title "⚠️ Repo already exists."'
else
	# WARN depth=2 ensures that amending a shallow commit does not result in a 
	# new commit without parent, effectively destroying git history (!!)
	git clone --depth=2 --filter="blob:none" "$url" || return 1
fi

# Open in terminal via Alfred
echo -n "$LOCAL_REPOS/$reponame" 
