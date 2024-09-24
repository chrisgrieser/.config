#!/usr/bin/env zsh
# shellcheck disable=2030,2031 # apparently still works, cause it's zsh?
#───────────────────────────────────────────────────────────────────────────────

# FILES IN WORKFLOW FOLDER
current_workflow_path="$(echo "$*" | tr -d '\n')"
cd "$current_workflow_path" || return 1
files=$(find . -type f \
	-not -name "*.png" -not -name "*.plist" -not -name "*.d.ts" -not -name "*.md" \
	-not -path "./.git*" -not -name ".*" -not -name "LICENSE" -not -iname "notificator" |
	cut -c3-)

# CHECK IF USED IN `info.plist`
# (only checking the `info.plist` still finds files which may be used by other scripts)
notfound=""
echo "$files" | while read -r file; do
	grep -q "$file" ./info.plist || notfound="$notfound- $file\n"
done
info=$([[ -z "$notfound" ]] &&
	echo "✅ No unused files found for this workflow." ||
	echo "⚠️ Files unused in this workflow's \`info.plist\`:")

# DISPLAY IN ALFRED
echo "### $(basename "$current_workflow_path")"
echo "$info"
echo "$notfound"
