#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred var
#───────────────────────────────────────────────────────────────────────────────

if [[ ! -f "$csv_file" ]]; then
	mkdir -p "$(dirname "$csv_file")"

	# csv metadata
	if [[ "$csv_metadata" == "anki" ]]; then
		echo "#separator:comma" > "$csv_file"
		echo "#html:false" >> "$csv_file"
		echo "#tags column:4" >> "$csv_file"
	elif [[ "$csv_metadata" == "header_row" ]]; then
		echo '"kanji","kana","english","word type' > "$csv_file"
	fi
fi

csv_line="$*"
echo "$csv_line" >> "$csv_file"
