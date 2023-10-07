#!/usr/bin/env zsh
# https://chainsawonatireswing.com/2012/09/19/changing-default-applications-on-a-mac-using-the-command-line-then-a-shell-script/
#───────────────────────────────────────────────────────────────────────────────

# install duti if needed
unfunction duti
command -v duti &>/dev/null || brew install duti

# open once to initialize the apps
open "$HOME/.config/nvim/mac-helper/Neovide Helper.app" 
open "$HOME/.config/obsidian/Obsidian Helper.app" 

#───────────────────────────────────────────────────────────────────────────────

# Obsidian
obsiOpenerID="com.apple.automator.Obsidian-Helper"
duti -s "$obsiOpenerID" md all
duti -s "$obsiOpenerID" canvas all

# video & mp3
videoplayerID="com.colliderli.iina"
duti -s "$videoplayerID" vid all
duti -s "$videoplayerID" mp4 all
duti -s "$videoplayerID" mp3 all
duti -s "$videoplayerID" mov all
duti -s "$videoplayerID" m3u all
duti -s "$videoplayerID" m3u8 all
duti -s "$videoplayerID" mkv all
duti -s "$videoplayerID" m4a all

# code
editorID="com.apple.automator.Neovide-Helper"
duti -s "$editorID" diff all
duti -s "$editorID" public.unix-executable all 
duti -s "$editorID" scm all # treesitter
duti -s "$editorID" add all # vim spell file
duti -s "$editorID" com.apple.traditional-mac-plain-text all
duti -s "$editorID" public.make-source all
duti -s "$editorID" public.data all # dotfiles without extension
duti -s "$editorID" sketchybarrc all
duti -s "$editorID" txt all
duti -s "$editorID" conf all
duti -s "$editorID" ini all
duti -s "$editorID" cfg all
duti -s "$editorID" com.apple.property-list all # plist
duti -s "$editorID" xml all
duti -s "$editorID" vimrc all
duti -s "$editorID" vim all
duti -s "$editorID" csv all
duti -s "$editorID" log all
duti -s "$editorID" toml all
duti -s "$editorID" sh all
duti -s "$editorID" bib all
duti -s "$editorID" rb all
duti -s "$editorID" zsh all
duti -s "$editorID" bash all
duti -s "$editorID" py all
duti -s "$editorID" js all
duti -s "$editorID" ts all
duti -s "$editorID" css all
duti -s "$editorID" scss all
duti -s "$editorID" applescript all
duti -s "$editorID" lua all
duti -s "$editorID" json all
duti -s "$editorID" public.yaml all

# Browser & Mail
browserID=$(osascript -e "id of app \"$BROWSER_APP\"") # set in zshenv
duti -s "$browserID" svg all
duti -s "$browserID" chrome-extension
duti -s "$browserID" chrome
duti -s "$browserID" webloc all # link files
duti -s "$browserID" url all    # link files

mailID=$(osascript -e "id of app \"$MAIL_APP\"") # set in zshenv
duti -s "$mailID" mailto # = default mail client

# Misc
duti -s "net.highlightsapp.universal" pdf all
duti -s "org.m0k.transmission" torrent all
duti -s "org.m0k.transmission" magnet
duti -s "com.busymac.busycal3" ics all
duti -s "com.apple.archiveutility" zip all

brew uninstall duti
