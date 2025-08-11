#!/usr/bin/env zsh

title="$(echo "$1" | cut -d$'\t' -f1 | tr "$€§*#?!:;.,'\"\{}" "-")"
url="$(echo "$1" | cut -d$'\t' -f2)"
filepath="$HOME/Desktop/$title.webloc"

# multiline string:
cat > "$filepath" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" \
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>URL</key>
    <string>$url</string>
</dict>
</plist>
EOF

open -R "$filepath"
