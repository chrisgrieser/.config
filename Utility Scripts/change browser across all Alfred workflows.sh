#!/bin/zsh


# TODO: need to change brwoser across hammerspoon configs as well

cd "$ZSH_DOTFILE_LOCATION/.." || return 1

# replace (insert Browsers here)
fd "_\[Browser\]" | xargs -I{} sed -i '.bak' 's/Brave Browser/Vivaldi/g' "{}"

# finicky
sed -i '.bak' 's/Brave Browser/Vivaldi/g' .finicky.js

# replace (insert Browsers PATHS here)
fd "_\[Browser-Path\]" | xargs -I{} sed -i '.bak' 's/BraveSoftware\/Brave Browser/BraveSoftware\/Brave-Browser/g' "{}"

# remove backups
fd ".*\.bak" | xargs -I{} mv "{}" ~/.Trash
