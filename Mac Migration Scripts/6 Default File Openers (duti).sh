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

# images
# duti -s com.apple.Preview png all
# duti -s com.apple.Preview jpg all
# duti -s com.apple.Preview jpeg all
# duti -s com.apple.Preview tiff all
# duti -s com.apple.Preview webp all
# duti -s com.apple.Preview ico all
# duti -s com.apple.Preview icns all

# text
duti -s com.sublimetext.4 public.data all # dotfiles do not have a UTI or file extensions
duti -s com.apple.automator.Obsidian-Opener md all
duti -s sh com.sublimetext.4 all
duti -s bib com.sublimetext.4 all
duti -s html com.sublimetext.4 all
duti -s zsh com.sublimetext.4 all
duti -s bash com.sublimetext.4 all
duti -s py com.sublimetext.4 all
duti -s js com.sublimetext.4 all
duti -s ts com.sublimetext.4 all
duti -s css com.sublimetext.4 all
duti -s scss com.sublimetext.4 all
duti -s txt com.sublimetext.4 all
duti -s applescript com.sublimetext.4 all
duti -s lua com.sublimetext.4 all
duti -s json com.sublimetext.4 all
duti -s yml com.sublimetext.4 all
duti -s yaml com.sublimetext.4 all
duti -s xml com.sublimetext.4 all
duti -s plist com.sublimetext.4 all

# URI Schemes
duti -s org.m0k.transmission magnet
duti -s com.mimestream.Mimestream mailto # = default mail client
duti -s com.brave.Browser http           # = default browser
duti -s com.brave.Browser https
duti -s com.brave.Browser webloc all
duti -s com.brave.Browser url all

# Marta
duti -s org.yanex.marta file             # file links
duti -s marco com.sublimetext.4 all      # marta config files
defaults write -g NSFileViewer -string org.yanex.marta
defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType="public.folder";LSHandlerRoleAll="org.yanex.marta";}'
# ACT then restart mac

# to restore Finder as default
# defaults delete -g NSFileViewer
# defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType="public.folder";LSHandlerRoleAll="com.apple.finder";}'

# Reference
# https://binarynights.com/manual#fileviewer
# https://github.com/marta-file-manager/marta-issues/issues/861
