#!/usr/bin/env zsh
# shellcheck disable=2030,2031 # apparently still works, cause it's zsh?
#───────────────────────────────────────────────────────────────────────────────

# FILES IN WORKFLOW FOLDER
current_workflow_path="$(echo "$*" | tr -d '\n')"
cd "$current_workflow_path" || return 1
files=$(find . -type f \
	-not -name "*.png" -not -name "*.plist" -not -name "*.d.ts" -not -name "*.md" \
	-not -path "./.git*" -not -name ".*" |
	cut -c3-)

# CHECK IF USED IN `info.plist`
# (only checking the `info.plist` still finds files which may be used by other scripts)
notfound=""
echo "$files" | while read -r file; do
	grep -q "$file" ./**/* || notfound="$notfound- $file\n"
done
info=$([[ -z "$notfound" ]] &&
	echo "✅ No unused files found for this workflow." ||
	echo "⚠️ There are files not referenced in any of this workflow's files. This does not not necessary mean that they are unused, but it indicates that they might be unused.")

# DISPLAY IN ALFRED
echo "### $(basename "$current_workflow_path")"
echo "$info"
echo "$notfound"
