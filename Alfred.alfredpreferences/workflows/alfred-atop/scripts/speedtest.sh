#!/usr/bin/env zsh
networkQuality |
	tr "\n" "%" |
	sed -e 's/==== SUMMARY ====/# Summary/' -e 's/%/\n- /g' |
	sed '$d'
