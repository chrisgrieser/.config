# Change stuff in all repos

FILE_TO_OPEN=".release.sh"
# -------------------------
DEV_VAULT=~"/Library/Mobile Documents/iCloud~md~obsidian/Documents/Development"
ALFRED_FOLDER="$DOTFILE_FOLDER/Alfred.alfredpreferences/workflows/"

open "$ALFRED_FOLDER/user.workflow.D02FCDA1-EA32-4486-B5A6-09B42C44677C/$FILE_TO_OPEN"
open "$ALFRED_FOLDER/user.workflow.765354AA-49F0-4CB1-8DB0-EA4BE2DB09F8/$FILE_TO_OPEN"
open "$ALFRED_FOLDER/user.workflow.41B90DCD-A99E-4943-A19A-E91859557FB0/$FILE_TO_OPEN"

open "$DEV_VAULT/.obsidian/plugins/"*"/$FILE_TO_OPEN"
