#!/bin/zsh --no-rcs
# =====----------------------------------------------------===== #
# File, Please - Alfred Workflow
# Quickly reveal recent files in Downloads, Desktop, etc.
#
# Author:  Patrick Sy
# Created: 2025-03-27
# Version: 1.0.0
# Github:  https://github.com/zeitlings/alfred-workflows
# =====----------------------------------------------------===== #
DIRECTORY="$HOME/${1:-Downloads}"
PROPERTY="${property:-kMDItemDateAdded}"
RECENT=$(mdls -name $PROPERTY -name kMDItemFSName "$DIRECTORY"/* |
    awk -v prop="$PROPERTY" '
        $0 ~ prop {
            date = substr($0, index($0, "= ") + 2)
        }
        /kMDItemFSName/ {
            name = substr($0, index($0, "= \"") + 3)
            gsub(/"$/, "", name)
            print date ":" name
        }
    ' | sort -r | head -n1 | cut -d':' -f4)

FILE_PATH="$DIRECTORY/$RECENT"
ALF_ID="com.runningwithcrayons.Alfred"
WKF_ID="com.zeitlings.file.please"

case "${open_in:-finder}" in
finder)
    open -R "$FILE_PATH"
    ;;
terminal) # makes little sense: osascript -e '... with argument ${argument:h}'
    open -R "$FILE_PATH"
    ;;
browser)
    osascript -e 'tell application id '"\"$ALF_ID\""' to run trigger "browser" in workflow '"\"$WKF_ID\""' with argument '"\"$FILE_PATH\""
    ;;
esac
