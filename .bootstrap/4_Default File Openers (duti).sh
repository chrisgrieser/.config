#!/usr/bin/env zsh
# https://chainsawonatireswing.com/2012/09/19/changing-default-applications-on-a-mac-using-the-command-line-then-a-shell-script/
#───────────────────────────────────────────────────────────────────────────────

# install duti if needed
[[ -x "$(command -v duti)" ]] || brew install duti

# open once to initialize the apps
open "$HOME/.config/obsidian/opener/Obsidian Helper.app"

#───────────────────────────────────────────────────────────────────────────────

# General
duti -s "com.apple.archiveutility" zip all
duti -s "com.apple.automator.Obsidian-Helper" md all
duti -s "com.busymac.busycal3" ics all
duti -s "com.mimestream.Mimestream" mailto # = default mail client
duti -s "net.highlightsapp.universal" pdf all
duti -s "org.m0k.transmission" magnet
duti -s "org.m0k.transmission" torrent all

# Browser & Mail
browserID=$(osascript -e 'id of app "Brave Browser"')
duti -s "$browserID" chrome
duti -s "$browserID" chrome-extension
duti -s "$browserID" svg all
duti -s "$browserID" url all    # link files
duti -s "$browserID" webloc all # link files

# video & mp3
videoplayerID="com.colliderli.iina"
duti -s "$videoplayerID" m3u all
duti -s "$videoplayerID" m3u8 all
duti -s "$videoplayerID" m4a all
duti -s "$videoplayerID" mkv all
duti -s "$videoplayerID" mov all
duti -s "$videoplayerID" mp3 all
duti -s "$videoplayerID" mp4 all
duti -s "$videoplayerID" vid all

# code
editorID="com.neovide.neovide"
duti -s "$editorID" add all # vim spell file
duti -s "$editorID" applescript all
duti -s "$editorID" bib all
duti -s "$editorID" swift all
duti -s "$editorID" c all
duti -s "$editorID" rs all
duti -s "$editorID" cff all # citation file format
duti -s "$editorID" cfg all
duti -s "$editorID" com.apple.property-list all # plist
duti -s "$editorID" com.apple.traditional-mac-plain-text all
duti -s "$editorID" conf all
duti -s "$editorID" css all
duti -s "$editorID" csv all
duti -s "$editorID" diff all
duti -s "$editorID" ini all
duti -s "$editorID" js all
duti -s "$editorID" json all
duti -s "$editorID" jsonc all
duti -s "$editorID" log all
duti -s "$editorID" lua all
duti -s "$editorID" public.data all # dotfiles without extension
duti -s "$editorID" public.make-source all
duti -s "$editorID" public.unix-executable all
duti -s "$editorID" public.yaml all
duti -s "$editorID" py all
duti -s "$editorID" pyi all
duti -s "$editorID" rb all
duti -s "$editorID" scm all # treesitter
duti -s "$editorID" scss all
duti -s "$editorID" sh all
duti -s "$editorID" svelte all
duti -s "$editorID" toml all
duti -s "$editorID" ts all
duti -s "$editorID" vim all
duti -s "$editorID" xml all
duti -s "$editorID" zsh all

#───────────────────────────────────────────────────────────────────────────────

brew uninstall duti
