#!/usr/bin/env zsh
# shellcheck disable=2154

# GUARD
if [[ ! -f $donetxt_filepath ]]; then
	echo -n "⚠️ Archive does not exist."
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────

to_be_archived_count=$(grep -c "^x " "$todotxt_filepath")

# archive completed tasks
grep "^x " "$todotxt_filepath" >>"$donetxt_filepath"

# remove completed tasks
grep -v "^x " "$todotxt_filepath" >"$todotxt_filepath.tmp"
mv "$todotxt_filepath.tmp" "$todotxt_filepath"

echo -n "$to_be_archived_count todos"
