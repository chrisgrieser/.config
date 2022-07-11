#!/bin/zsh
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH

# Abort if CLI missing
which mini-svg-data-uri &> /dev/null
if [[ $? == 1 ]]; then
	echo "mini-svg-data-uri is not installed."
	exit 1
fi

pbpaste > temp.svg
svgDataURI=$(mini-svg-data-uri temp.svg | sed -e "s/width='1em' //" | sed -e "s/height='1em' //" | sed -e "s/xmlns:.*role='img' //")
rm temp.svg

cssReady="svg.PLACEHOLDER > path { display: none }\n\nsvg.PLACEHOLDER {\n\tbackground-color: currentColor;\n\t-webkit-mask-image: url(\"$svgDataURI\");\n}"

echo "$cssReady" | pbcopy

# paste on mac
osascript -e 'tell application "System Events" to keystroke "v" using {command down}'
