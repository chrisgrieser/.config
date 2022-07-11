#!/bin/zsh
# shellcheck disable=SC2154

TEMP_IMAGE="$alfred_workflow_cache/$IMAGE_BASE_NAME $(date '+%Y-%m-%d %H.%M.%S').png"
mkdir -p "$alfred_workflow_cache"

screencapture -i "$TEMP_IMAGE"

# existence check allows for the canceling of a screenshot
if [[ -e "$TEMP_IMAGE" ]] ; then
	osascript -e "set the clipboard to POSIX file \"$TEMP_IMAGE\""
	echo "image done"
fi
