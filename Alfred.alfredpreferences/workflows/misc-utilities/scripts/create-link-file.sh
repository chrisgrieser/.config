#!/usr/bin/env zsh

title="$(echo "$1" | cut -d$'\t' -f1 | cut -c1-50 | tr "$€§*#?!:;.,'\"\{}" "-")"
url="$(echo "$1" | cut -d$'\t' -f2 | sed 's/&/&amp;/g')" # `&` invalid in xml

finder_path=$(osascript -l "JavaScript" -e 'decodeURIComponent(Application("Finder").insertionLocation().url()?.slice(7) || "")')
default_path="$HOME/Desktop"
target_path="${finder_path:-$default_path}"
filepath="$target_path/$title.webloc"

#───────────────────────────────────────────────────────────────────────────────

cat > "$filepath" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>URL</key>
	<string>${url}</string>
</dict>
</plist>
EOF

open -R "$filepath" # reveal in Finder
