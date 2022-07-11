cd ~/Desktop || return

# -------------------

#Application Support
mkdir -p ~'/Library/Application Support/Alfred/Workflow Data/com.vdesabou.spotify.mini.player/'
mv -v 'Spotify-Mini-Player/' ~'/Library/Application Support/Alfred/Workflow Data/com.vdesabou.spotify.mini.player/'

# Fonts
mkdir -p ~'/Library/Fonts'
mv -v 'Fonts/'* ~'/Library/Fonts'

# iCloud
mv -vR 'iCloud-Folder/'*(D) ~"/Library/Mobile Documents/com~apple~CloudDocs"

# Browser-Default-Folder
mkdir -p ~"/Library/Application Support/BraveSoftware/Brave-Browser/Default/"
mv ~"/Library/Application Support/BraveSoftware/Brave-Browser/Default/" ~/.Trash
mv -vR 'Browser-Default-Folder/'* ~"/Library/Application Support/BraveSoftware/Brave-Browser/Default/"

# -------------------

# seperate import plist, explanation https://manytricks.com/osticket/kb/faq.php?id=53
# defaults import com.manytricks.Moom com.manytricks.Moom.plist

# import preferences
# untested yet, should work though: https://github.com/koalaman/shellcheck/wiki/Sc2045#correct-code
cd ~/Desktop/Preferences/ || return
for f in *.plist ; do
	[[ -e "$f" ]] || break  # handle the case of no *.plist files
	f=$(basename "$f" .plist)
	defaults import "$f" "$f".plist
done

for d in */ ; do
	mv -v "$d" ~/Library/Preferences/
done
