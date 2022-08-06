MARTA_CONFIG=~"/Library/Application Support/org.yanex.marta/conf.marco"
DARK_THEME=Kon
LIGHT_THEME=Classic
MODE=$1

if test "$MODE" = "dark" ; then
	grep -q "theme \"$DARK_THEME\"" "$MARTA_CONFIG" && return
	sed -i '' "s/ theme \"$LIGHT_THEME\"/ theme \"$DARK_THEME\"/" "$MARTA_CONFIG"
else
	grep -q "theme \"$LIGHT_THEME\"" "$MARTA_CONFIG" && return
	sed -i '' "s/ theme \"$DARK_THEME\"/ theme \"$LIGHT_THEME\"/" "$MARTA_CONFIG"
fi

if pgrep "Marta" &> /dev/null ; then
	killall "Marta"
	sleep 0.2
	open -a "Marta"
fi
