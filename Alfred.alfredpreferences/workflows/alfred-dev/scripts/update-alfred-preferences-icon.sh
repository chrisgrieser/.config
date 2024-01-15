#!/usr/bin/env zsh

prefs_path="/Applications/Alfred 5.app/Contents/Preferences/Alfred Preferences.app"
icon_path="./Alfred Preferences.icns"

# http://codefromabove.com/2015/03/programmatically-adding-an-icon-to-a-folder-or-file/
# alternative: use `fileicon` cli
DeRez -only icns "$icon_path" >tmpicns.rsrc # extract the icon to its own resource file
Rez -append tmpicns.rsrc -o "$prefs_path"   # append resource to the file to icon-ize
SetFile -a C "$prefs_path"                  # use the resource to set the icon
rm -f tmpicns.rsrc
