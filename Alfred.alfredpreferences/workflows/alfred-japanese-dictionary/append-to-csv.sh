#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred var
#───────────────────────────────────────────────────────────────────────────────

if [[ ! -f "$csv_file" ]]; then
	mkdir -p "$(dirname "$csv_file")"

	# anki csv metadata
	if [[ "$use_anki_csv_metadata" == "1" ]]; then
		echo "#separator:comma" > "$csv_file"
		echo "#html:false" >> "$csv_file"
		echo "#tags column:4" >> "$csv_file"
	fi
fi

csv_line="$*"
echo "$csv_line" >> "$csv_file"
