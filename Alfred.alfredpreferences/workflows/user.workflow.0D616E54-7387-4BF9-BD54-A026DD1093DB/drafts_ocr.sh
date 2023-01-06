#!/bin/zsh
# shellcheck disable=SC2154
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH

mkdir -p "$alfred_workflow_cache"
temp_image="$alfred_workflow_cache/temp_ocr_snapshot.png"
screencapture -i "$temp_image"

scannedText=$(tesseract "$temp_image" stdout -l "$ocr_languages" 2>&1 |
	grep -Ev "Warning: Invalid resolution 0 dpi." |
	grep -Ev "Estimating resolution as")

osascript -e "tell application \"Drafts\" to make new draft with properties {content: \"$scannedText\", tags: {\"OCR\"}}" &>/dev/null

echo -n "$scannedText" # for notification
