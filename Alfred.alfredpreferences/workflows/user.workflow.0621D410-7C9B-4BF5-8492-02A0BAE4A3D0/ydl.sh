#!/usr/bin/env zsh
# shellcheck disable=SC2154
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH
CURRENT_TAB=$(osacript -e 'tell application "Brave Browser" to return URL of active tab of front window')

download_location="${download_location/#~/$HOME}"
cd "$download_location" || exit 1

# shellcheck disable=SC2086
youtube-dl --format $output_format "$CURRENT_TAB" 2>&1
