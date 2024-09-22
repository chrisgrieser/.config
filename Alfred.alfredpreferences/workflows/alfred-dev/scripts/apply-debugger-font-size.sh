#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred var

# found in 5.5.1 changelog: https://www.alfredapp.com/changelog/

defaults write com.runningwithcrayons.Alfred-Preferences \
	workflows.debuggerFontSize "$debugger_fontsize"

# restart
killall "Alfred Preferences"
while pgrep -xq "Alfred-Preferences"; do sleep 0.1; done
open -a "Alfred Preferences"

osascript -l JavaScript "./scripts/open-last-workflow.js"
osascript -e 'tell application "System Events" to keystroke "d" using {command down}'
