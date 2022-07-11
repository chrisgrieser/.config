# Brew

if [[ $(uname -p) == "arm" ]]; then
	# M1 Mac
	eval "$(/opt/homebrew/bin/brew shellenv)"
else
	# Intel mac
	eval "$(/usr/local/bin/brew shellenv)"
fi

# Sublime
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"

# karabiner_cli
export PATH="/Library/Application Support/org.pqrs/Karabiner-Elements/bin:$PATH"
