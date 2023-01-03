#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

url=$(echo "$*" | xargs) # remove trailing blankline
repoName=$(echo "$url" | cut -d/ -f5)
cache="/tmp/$repoName"
modified_recently=$(find "$cache" -mmin -60)

if [[ -n "$modified_recently" && ! -e "$cache" ]] ; then
	echo
elif [[ -n "$modified_recently" && -e "$cache" ]] ; then
	echo
else

	# turn http url into github ssh remote address
	giturl="$(echo "$url" | sed -E 's/https?:\/\/github.com\//git@github.com:/').git"
	cd /tmp/ || exit 1
	git clone --depth=1 --single-branch "$giturl" # shallow clone

	cd "./$repoName" || exit 1
	open .
fi
