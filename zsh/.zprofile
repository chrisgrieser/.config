# Homebrew Setup
if [[ $(uname -p) == "arm" ]]; then
	# M1 Mac
	eval "$(/opt/homebrew/bin/brew shellenv)"
else
	# Intel mac
	eval "$(/usr/local/bin/brew shellenv)"
fi
