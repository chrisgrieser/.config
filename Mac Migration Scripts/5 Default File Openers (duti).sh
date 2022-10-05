# https://chainsawonatireswing.com/2012/09/19/changing-default-applications-on-a-mac-using-the-command-line-then-a-shell-script/
#-------------------------------------------------------------------------------
brew install duti

# general
duti -s net.highlightsapp.universal pdf all
duti -s com.apple.automator.less-bottom pdf all
duti -s org.m0k.transmission torrent all
duti -s com.sublimetext.4 csv all
duti -s com.busymac.busycal3 ics all
duti -s com.colliderli.iina mp3 all
duti -s com.apple.automator.Obsidian-Opener md all

# video
videoplayerID="com.colliderli.iina"
duti -s "$videoplayerID" mp4 all
duti -s "$videoplayerID" vid all
duti -s "$videoplayerID" mov all
duti -s "$videoplayerID" m3u all
duti -s "$videoplayerID" m3u8 all
duti -s "$videoplayerID" mkv all
duti -s "$videoplayerID" m4a all

# text
editorID="com.apple.automator.Neovim"
duti -s "$editorID" toml all
duti -s "$editorID" sh all
duti -s "$editorID" bib all
duti -s "$editorID" html all
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
duti -s "$editorID" plist all
duti -s "$editorID" public.data all # dotfiles without extension
duti -s "$editorID" vimrc all
duti -s "$editorID" sketchybarrc all

# URI Schemes
duti -s org.m0k.transmission magnet
duti -s com.mimestream.Mimestream mailto # = default mail client
duti -s com.brave.Browser http           # = default browser
duti -s com.brave.Browser https
duti -s com.brave.Browser chrome-extension

duti -s com.brave.Browser webloc all     # link files
duti -s com.brave.Browser url all     # link files

# Marta
duti -s org.yanex.marta file             # file links
duti -s marco com.sublimetext.4 all      # marta config files
defaults write -g NSFileViewer -string org.yanex.marta
defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType="public.folder";LSHandlerRoleAll="org.yanex.marta";}'

brew uninstall duti
# -> then restart mac


# to restore Finder as default
# defaults delete -g NSFileViewer
# defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType="public.folder";LSHandlerRoleAll="com.apple.finder";}'
# Reference
# https://binarynights.com/manual#fileviewer
# https://github.com/marta-file-manager/marta-issues/issues/861
