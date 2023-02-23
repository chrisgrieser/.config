# https://forum.vivaldi.net/topic/42881/how-to-make-vivaldi-open-downloaded-files-automatically

# to auto-open files on Vivaldi, run: 
killall "Vivaldi"
while pgrep -q "Vivaldi"; do sleep 0.1; done
# NOTE on macOS, `-i` requires `''`, on other systems it does not
sed -i '' \
	's/"directory_upgrade":true/"directory_upgrade":true,"extensions_to_open":"torrent:zip:alfredworkflow:ics"/' \
	"$HOME/Library/Application Support/Vivaldi/Default/Preferences"
open -a "Vivaldi"
