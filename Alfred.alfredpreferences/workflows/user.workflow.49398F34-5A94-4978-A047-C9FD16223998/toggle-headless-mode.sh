#!/bin/zsh
# http://support.iconfactory.com/kb/twitterrific/advanced-settings-using-the-command-line-macos

IS_HEADLESS=$(defaults read com.iconfactory.Twitterrific5 advancedShowDockIcon)

if [[ "$IS_HEADLESS" == "0" ]] ; then
	defaults write com.iconfactory.Twitterrific5 advancedShowDockIcon -bool YES
	echo "Dock Icon re-enabled"
else
	defaults write com.iconfactory.Twitterrific5 advancedShowDockIcon -bool NO
	echo "Dock Icon hidden"
fi

killall "Twitterrific"
sleep 0.5
open -a "Twitterrific"
