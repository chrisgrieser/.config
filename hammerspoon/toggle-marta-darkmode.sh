MARTA_CONFIG=~"/Library/Application Support/org.yanex.marta/conf.marco"
DARK_THEME=Kon
LIGHT_THEME=Classic
TARGET_MODE=$1

if [[ "$TARGET_MODE" == "dark" ]] ; then
	grep -q "theme \"$DARK_THEME\"" "$MARTA_CONFIG" && return
	sed -i '' "s/ theme \"$LIGHT_THEME\"/ theme \"$DARK_THEME\"/" "$MARTA_CONFIG"
	echo "to dark"
else
	grep -q "theme \"$LIGHT_THEME\"" "$MARTA_CONFIG" && return
	sed -i '' "s/ theme \"$DARK_THEME\"/ theme \"$LIGHT_THEME\"/" "$MARTA_CONFIG"
	echo "to light"
fi

if pgrep "Marta" &> /dev/null ; then
	IS_FRONT_MOST=$(osascript -e 'frontmost of application "Marta"')
	killall "Marta"
	sleep 0.2
	open -a "Marta"
	if [[ "$IS_FRONT_MOST" == "false" ]] ; then
		osascript -e 'tell application "System Events" to tell process "Marta" to set visible to false'
	fi
fi
