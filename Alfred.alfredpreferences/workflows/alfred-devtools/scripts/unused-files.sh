#!/usr/bin/env zsh
# shellcheck disable=2030,2031 # apparently still works, cause it's zsh?
#───────────────────────────────────────────────────────────────────────────────

current_workflow_path="$(echo "$*" | tr -d '\n')"
cd "$current_workflow_path" || return 1

#───────────────────────────────────────────────────────────────────────────────

files=$(find . -type f \
	-not -name "*.png" -not -name "*.plist" -not -name "*.d.ts" -not path ".git*" | 
	cut -c3-)

notfound=""
echo "$files" | while read -r file; do
	grep -q "$file" ./info.plist || notfound="$notfound- $file\n"
done
info=$([[ -z "$notfound" ]] && echo "✅ No unused files found." || echo "Potentially unused files:")

#───────────────────────────────────────────────────────────────────────────────

echo "### $(basename "$current_workflow_path")"
echo "$info"
echo "$notfound"
