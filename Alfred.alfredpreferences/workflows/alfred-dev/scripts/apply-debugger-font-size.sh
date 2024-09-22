#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred var
#───────────────────────────────────────────────────────────────────────────────

# set font size, found in 5.5.1 changelog: https://www.alfredapp.com/changelog/
defaults write com.runningwithcrayons.Alfred-Preferences \
	workflows.debuggerFontSize "$debugger_fontsize"

# restart
killall "Alfred Preferences"
while pgrep -xq "Alfred-Preferences"; do sleep 0.1; done
open -a "Alfred Preferences"
sleep 0.5

# open this workflow, the debugger, and post demo text
osascript -l JavaScript -e "
	Application('com.runningwithcrayons.Alfred').revealWorkflow('$alfred_workflow_bundleid')
	Application('System Events').keystroke('d', { using: ['command down'] });
"
sleep 0.2
echo "ℹ️ Debugger font size set to $debugger_fontsize" >&2
