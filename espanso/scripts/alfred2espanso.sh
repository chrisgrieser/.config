#!/bin/zsh

# Convert Alfred snippets to Espanso files
# ----------------------------------------------
OUTPUT_FOLDER="$WD"
ALFRED_SNIPPET_FOLDER="/Users/chrisgrieser/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Dotfiles/Alfred.alfredpreferences/snippets/"

# requirements: yq
# `brew install yq`

# -----------------------

cd "$ALFRED_SNIPPET_FOLDER" || return 1

for folder in */; do
	cd "$folder" || return 1
	echo "$PWD"

	NAME=$(basename "$PWD")
	for f in *.json ; do
		f=$(basename "$f" .json)
		yq -P '.' "$f.json" >> "$OUTPUT_FOLDER/$NAME.yml"
	done

	cd ..
done

cd "$OUTPUT_FOLDER" || return 1
for file in *.yml; do
	echo "$file"

	sed -i '' '/alfredsnippet:/d' "$file"
	sed -i '' '/uid:/d' "$file"
	sed -i '' '/dontautoexpand:/d' "$file"
	sed -i '' 's/snippet:/replace:/g' "$file"
	sed -i '' 's/name:/label:/g' "$file"
	sed -i '' 's/  keyword:/- trigger:/g' "$file"
	sed -i '' 's/{cursor}/\$\|\$/g' "$file"
	sed -i '' 's/\\U0001F3DD/🏝/g' "$file"
	sed -i '' 's/\\U0001F34F/🐚/g' "$file"
	sed -i '' 's/\\U0001F4BE/🍏/g' "$file"
	# rule without explicit trigger, mostly for search bar
	# (§ does not trigger anything in espanso)
	sed -i '' 's/"§§§"/"§§§"/g' "$file"

	temp=$(mktemp)
	mv -f "$file" "$temp"
	printf "# https://espanso.org/docs/\n# ------------------------------------------\n\nmatches:\n" > "$file"
	cat "$temp" >> "$file"

done

# figuring out how to sort the trigger key up with yq takes too long
# doing that last bit by hand 🙈

# also, indentation is still missing, but was too lazy to code that
