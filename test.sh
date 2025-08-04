# common parent
changed_files="$(git status --porcelain | cut -c4- | sed 's|^|./|')"
common_parent=$(dirname "$changed_files" | head -n1) # initialize
while read -r path; do
	while [[ ! "$path" =~ ^$common_parent ]]; do
		common_parent=$(/usr/bin/dirname "$common_parent")
	done
done < <(echo "$changed_files")
echo "$common_parent"

