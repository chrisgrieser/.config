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
duti -s org.yanex.marta zip all

# video
duti -s com.colliderli.iina mp4 all
duti -s com.colliderli.iina vid all
duti -s com.colliderli.iina mov all
duti -s com.colliderli.iina m3u all
duti -s com.colliderli.iina m3u8 all
duti -s com.colliderli.iina mkv all
duti -s com.colliderli.iina m4a all

# text
duti -s com.apple.automator.Obsidian-Opener md all

duti -s com.sublimetext.4 public.data all # dotfiles without extension
duti -s com.sublimetext.4 sh all
duti -s com.sublimetext.4 bib all
duti -s com.sublimetext.4 html all
duti -s com.sublimetext.4 zsh all
duti -s com.sublimetext.4 bash all
duti -s com.sublimetext.4 py all
duti -s com.sublimetext.4 js all
duti -s com.sublimetext.4 ts all
duti -s com.sublimetext.4 css all
duti -s com.sublimetext.4 scss all
duti -s com.sublimetext.4 txt all
duti -s com.sublimetext.4 applescript all
duti -s com.sublimetext.4 lua all
duti -s com.sublimetext.4 json all
duti -s com.sublimetext.4 yml all
duti -s com.sublimetext.4 yaml all
duti -s com.sublimetext.4 xml all
duti -s com.sublimetext.4 plist all

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
