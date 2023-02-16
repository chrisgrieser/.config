#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

if ! command -v iconsur &>/dev/null; then echo -n "iconsur not installed." && exit 1; fi
#───────────────────────────────────────────────────────────────────────────────

# config
CUSTOM_ICON_FOLDER="$DOTFILE_FOLDER/custom-app-icons"

PWA_FOLDER="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Brave Browser Apps.localized/"
DEVICE_NAME=$(scutil --get ComputerName | cut -d" " -f2-)
[[ "$DEVICE_NAME" =~ "Mother" ]] && PWA_FOLDER="$HOME/Applications/Brave Browser Apps.localized"

#───────────────────────────────────────────────────────────────────────────────

cd "/Applications/" || exit 1

APP_TO_UPDATE=$(basename "$*" .app)
NONE_FOUND=0
INFO_WINDOW=0

case $APP_TO_UPDATE in
"Steam")
	iconsur set "Steam.app" &>/dev/null
	;;
"Alfred Preferences")
	osascript -e "tell application \"Finder\"
			open information window of (\"Alfred 5.app/Contents/Preferences/Alfred Preferences.app\" as POSIX file as alias)
			activate
		end tell
		set the clipboard to POSIX file \"$CUSTOM_ICON_FOLDER/Alfred Prefs.icns\""
	INFO_WINDOW=1
	;;
	# cp "$CUSTOM_ICON_FOLDER/Alfred Prefs.icns" 'Alfred 5.app/Contents/Preferences/Alfred Preferences.app/Contents/Resources/appicon.icns'
	# touch 'Alfred 4.app/Contents/Preferences/Alfred Preferences.app/Contents/Resources/appicon.icns' ;;
"Cryptomator")
	cp "$CUSTOM_ICON_FOLDER/Cryptomator.icns" 'Cryptomator.app/Contents/Resources/Cryptomator.icns'
	touch "Cryptomator.app"
	;;
"Alacritty" | "alacritty")
	cp "$CUSTOM_ICON_FOLDER/alacritty alt.icns" 'Alacritty.app/Contents/Resources/alacritty.icns'
	touch "Alacritty.app"
	;;
"AppCleaner")
	cp "$CUSTOM_ICON_FOLDER/AppCleaner.icns" 'AppCleaner.app/Contents/Resources/AppCleaner.icns'
	touch "AppCleaner.app"
	;;
"Obsidian")
	cp "$CUSTOM_ICON_FOLDER/Obsidian Square.icns" 'Obsidian.app/Contents/Resources/icon.icns'
	touch "Obsidian.app"
	;;
"Discord")
	cp "$CUSTOM_ICON_FOLDER/Discord Black.icns" 'Discord.app/Contents/Resources/electron.icns'
	touch "Discord.app"
	;;
"Neovide")
	cp "$CUSTOM_ICON_FOLDER/Vimari alt.icns" 'Neovide.app/Contents/Resources/Neovide.icns'
	touch "Neovide.app"
	;;

"Microsoft Word")
	osascript -e "tell application \"Finder\"
			open information window of (\"/Applications/Microsoft Word.app\" as POSIX file as alias)
			activate
		end tell
		set the clipboard to POSIX file \"$CUSTOM_ICON_FOLDER/Word.icns\""
	INFO_WINDOW=1
	;;
"Microsoft Excel")
	osascript -e "tell application \"Finder\"
			open information window of (\"/Applications/Microsoft Excel.app\" as POSIX file as alias)
			activate
		end tell
		set the clipboard to POSIX file \"$CUSTOM_ICON_FOLDER/Excel.icns\""
	INFO_WINDOW=1
	;;
"Mimestream")
	osascript -e "tell application \"Finder\"
			open information window of (\"/Applications/Mimestream.app\" as POSIX file as alias)
			activate
		end tell
		set the clipboard to POSIX file \"$CUSTOM_ICON_FOLDER/Mail_fancy.icns\""
	INFO_WINDOW=1
	;;
	# cp "$CUSTOM_ICON_FOLDER/Mail_fancy.icns" 'Mimestream.app/Contents/Resources/AppIcon.icns'
	# touch "Mimestream.app" ;;
"Docs")
	cp "$CUSTOM_ICON_FOLDER/Google Docs.icns" "$PWA_FOLDER/Docs.app/Contents/Resources/app.icns"
	touch "$PWA_FOLDER/Docs.app"
	;;
"Inoreader")
	iconsur -k "Unread" set "$PWA_FOLDER/Inoreader.app" &>/dev/null
	;;
"YouTube" | "Youtube")
	cp "$CUSTOM_ICON_FOLDER/YouTube.icns" "$PWA_FOLDER/YouTube.app/Contents/Resources/app.icns"
	touch "$PWA_FOLDER/YouTube.app"
	;;
"Tagesschau")
	iconsur set "$PWA_FOLDER/Tagesschau.app" &>/dev/null
	;;
"CrunchyRoll")
	iconsur set "$PWA_FOLDER/CrunchyRoll.app"
	;;
"Netflix")
	iconsur set "$PWA_FOLDER/Netflix.app" &>/dev/null
	;;
"Twitch")
	iconsur set "$PWA_FOLDER/Twitch.app" &>/dev/null
	;;
*)
	NONE_FOUND=1
	;;
esac

if [[ $NONE_FOUND == 1 ]]; then
	echo -n "No icon set up for $APP_TO_UPDATE."
	return 1
fi

if [[ $INFO_WINDOW == 1 ]]; then
	sleep 0.2
	osascript -e 'tell application "System Events"
		keystroke "v" using {command down}
		delay 0.05
		keystroke "w" using {command down}
	end tell'
	sleep 0.2
fi

killall "Dock" # INFO pgrep-ing for the Dock does not work, since there is always a process called that?
killall "$APP_TO_UPDATE"
while pgrep -q "$APP_TO_UPDATE"; do sleep 0.1 ; done
sleep 0.1

open -a "$APP_TO_UPDATE"
echo -n "$APP_TO_UPDATE" # pass for notification
