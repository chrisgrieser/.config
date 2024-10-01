#!/usr/bin/env zsh
# shellcheck disable=2030,2031 # apparently still works, cause it's zsh?

current_workflow_path="$(echo "$*" | tr -d '\n')"
cd "$current_workflow_path" || return 1

echo "### $(basename "$current_workflow_path")" # for displaying in Alfred

#───────────────────────────────────────────────────────────────────────────────

# FILES IN WORKFLOW FOLDER
notfound_files=""
files=$(find . -type f \
	-not -name "*.png" -not -name "*.plist" -not -name "*.d.ts" -not -name "*.md" \
	-not -path "./.git*" -not -name ".*" |
	cut -c3-)

# CHECK IF USED IN WORKFLOW
echo "$files" | while read -r file; do
	grep -q "$file" ./**/* || notfound_files="$notfound_files- $file\n"
done

#───────────────────────────────────────────────────────────────────────────────

# UID-PNG FILES
uid_pngs=$(find . -type f -name "????????-????-????-????-????????????.png" -print0 | 
	 xargs -0 -I {} basename {} ".png")

# CHECK IF USED IN `info.plist`
deleted_uid_pngs=""
echo "$uid_pngs" | while read -r uid; do
	if ! grep -q "$uid" ./info.plist ; then
		deleted_uid_pngs="$deleted_uid_pngs- $uid.png\n"
		rm "./$uid.png"
	fi
done

#───────────────────────────────────────────────────────────────────────────────

# DISPLAY IN ALFRED
if [[ -z "$notfound_files" && -z "$deleted_uid_pngs" ]]; then
	echo "✅ No unused files found for this workflow."
	exit 0
fi

if [[ -n "$notfound_files" ]]; then
	echo "⚠️ There are files not referenced in any of this workflow's files."
	echo "(This does not necessarily mean that they are unused, but is only an indicator.)"
	echo "$notfound_files"
	echo
fi
if [[ -n "$deleted_uid_pngs" ]]; then
	echo "ℹ️ The following UID-PNG are not referenced in this workflow's \`info.plist\` and have been deleted."
	echo "$deleted_uid_pngs"
fi

