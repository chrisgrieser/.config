# has to be dont via script instead of sourced function
# to allow restarting of the whole app

if [[ "$TERM_PROGRAM" == "Terminus-Sublime" ]] ; then
	echo "Terminal restart not configured for Terminus."
	return 1
fi

# some Terminals (e.g. alacritty) do not register to TERM_PROGRAM,
# others like Terminus do not register to TERM properly.
if [[ "$TERM_PROGRAM" == "" ]]; then
	TO_RESTART="$TERM"
else
	TO_RESTART="$TERM_PROGRAM"
fi

osascript -e "tell application \"$TO_RESTART\" to quit"
sleep 0.4
open -a "$TO_RESTART"
