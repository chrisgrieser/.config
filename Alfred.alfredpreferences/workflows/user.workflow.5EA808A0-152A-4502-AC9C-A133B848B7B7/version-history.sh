#!/bin/zsh

# get path of current Finder Selection (macOS)
FINDER_SEL=$(osascript -e 'tell application "Finder"
	set sel to selection
	if ((count sel) > 1) then return POSIX path of ((item 1 of sel) as text)
	if ((count sel) = 1) then return POSIX path of (sel as text)
	if ((count sel) = 0) then return "no selection"
end tell')

[[ "$FINDER_SEL" == "no selection" ]] && exit 1
[[ -d "$FINDER_SEL" ]] && exit 1 # selection is not a file

FOLDER=$(dirname "$FINDER_SEL")
FILE=$(basename "$FINDER_SEL")
EXT="${FILE##*.}"
FILE_SAVE_NAME="${FILE/\./-}"


cd "$FOLDER" || exit 1
[[ $(git rev-parse --git-dir) ]] || exit 1 # not a git directory

working_folder="${working_folder/#\~/$HOME}"
output_dir="$working_folder/$FILE_SAVE_NAME/"
mkdir -p "$output_dir"
open "$output_dir"

#-------------------------------------------------------------------------------

# https://stackoverflow.com/questions/1964142/how-can-i-list-all-the-different-versions-of-a-file-and-diff-them-also/32849134#32849134
for commit_hash in $(git log --pretty=format:%h "$FILE") ; do
	commit_date=$(git show -s --format=%ci "$commit_hash" | cut -c-16)
	out="$output_dir/$commit_date ($commit_hash).$EXT"
	git show "$commit_hash:./$FILE" > "$out"
done

