#!/usr/bin/env zsh
# https://chainsawonatireswing.com/2012/09/19/changing-default-applications-on-a-mac-using-the-command-line-then-a-shell-script/
#-------------------------------------------------------------------------------
if ! command -v duti &>/dev/null; then echo "duti not installed." && return 1; fi

# Config
browserID="com.vivaldi.Vivaldi"
videoplayerID="com.colliderli.iina"
editorID="com.apple.automator.Neovim"
obsiOpenerID="com.apple.automator.Obsidian-Opener"

# Obsidian
duti -s "$obsiOpenerID" md all
duti -s "$obsiOpenerID" canvas all

# video & mp3
duti -s "$videoplayerID" vid all
duti -s "$videoplayerID" mp4 all
duti -s "$videoplayerID" mp3 all
duti -s "$videoplayerID" mov all
duti -s "$videoplayerID" m3u all
duti -s "$videoplayerID" m3u8 all
duti -s "$videoplayerID" mkv all
duti -s "$videoplayerID" m4a all

# code
editorID="com.apple.automator.Neovim"
duti -s "$editorID" http all
duti -s "$editorID" conf all
duti -s "$editorID" fdignore all
duti -s "$editorID" ignore all
duti -s "$editorID" ini all
duti -s "$editorID" cfg all
duti -s "$editorID" com.apple.property-list all # plist
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
duti -s "$editorID" txt all
duti -s "$editorID" applescript all
duti -s "$editorID" lua all
duti -s "$editorID" json all
duti -s "$editorID" yml all
duti -s "$editorID" yaml all
duti -s "$editorID" xml all
duti -s "$editorID" fdignore all
duti -s "$editorID" public.data all # dotfiles without extension
duti -s "$editorID" vimrc all
duti -s "$editorID" sketchybarrc all

# URI Schemes
duti -s org.m0k.transmission magnet
duti -s com.mimestream.Mimestream mailto # = default mail client

# Browser
browserID="com.vivaldi.Vivaldi"
duti -s "$browserID" chrome-extension
duti -s "$browserID" chrome
duti -s "$browserID" webloc all     # link files
duti -s "$browserID" url all     # link files

# Misc
duti -s net.highlightsapp.universal pdf all
duti -s org.m0k.transmission torrent all
duti -s com.busymac.busycal3 ics all

