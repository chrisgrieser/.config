#!/usr/bin/env zsh
ne | tr "
" "%" | sed -e 's/==== SUMMARY ====/# Summary/' -e 's/%/
- /g' | sed '$d'
