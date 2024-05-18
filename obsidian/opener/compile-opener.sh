#!/usr/bin/env zsh

# CONFIG
readonly bundle_id="de.chris-grieser.obsidian-opener"
readonly name="Obsidian Opener"
readonly icon="/Applications/Obsidian.app/Contents/Resources/icon.icns"
readonly app="./${name}.app"
readonly jxa_script="./obsidian-opener.js"

#───────────────────────────────────────────────────────────────────────────────


/bin/mkdir -p "$(basename "${app}")"
[[ -d "${app}" ]] && /bin/rm -r "${app}"
/usr/bin/osacompile -l JavaScript -o "${app}" "${jxa_script}" 2>/dev/null

/bin/cp "$icon" "${app}/Contents/Resources/applet.icns"

readonly plist="${app}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "add :CFBundleIdentifier string ${bundle_id}.notificator" "${plist}"
/usr/libexec/PlistBuddy -c 'add :LSUIElement string 1' "${plist}"

/usr/bin/codesign --remove-signature "${app}"
/usr/bin/codesign --sign - "${app}"

#───────────────────────────────────────────────────────────────────────────────

open -R "${app}"
