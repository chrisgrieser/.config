MARTA_CONFIG=~"/Library/Application Support/org.yanex.marta/conf.marco"
DARK_THEME=Kon
LIGHT_THEME=Classic
TARGET_MODE=$1

if [[ "$TARGET_MODE" == "dark" ]] ; then
	grep -q "theme \"$DARK_THEME\"" "$MARTA_CONFIG" && return
	sed -i '' "s/ theme \"$LIGHT_THEME\"/ theme \"$DARK_THEME\"/" "$MARTA_CONFIG"
else
	grep -q "theme \"$LIGHT_THEME\"" "$MARTA_CONFIG" && return
	sed -i '' "s/ theme \"$DARK_THEME\"/ theme \"$LIGHT_THEME\"/" "$MARTA_CONFIG"
fi

if pgrep "Marta" &> /dev/null ; then
	IS_FRONT_MOST=$(osascript -e 'frontmost of application "Marta"')
	killall "Marta"
	sleep 1
	if [[ "$IS_FRONT_MOST" =~ "true" ]] ; then
		open -a "Marta"
		osascript -e "beep"
	else
		open -a "Marta" -j
	fi
fi
