#!/usr/bin/env zsh

# DOCS https://github.com/iamadamdev/bypass-paywalls-chrome?tab=readme-ov-file#installation-instructions
download_url="https://github.com/iamadamdev/bypass-paywalls-chrome/archive/master.zip"

cd "/tmp" || return 1
curl -sL "$download_url" > "bypass-paywalls.zip"
unzip "bypass-paywalls.zip"
rm "bypass-paywalls.zip"

# for easy drag-n-drop
open "chrome://extensions"
open -R "bypass-paywalls-chrome-master"
