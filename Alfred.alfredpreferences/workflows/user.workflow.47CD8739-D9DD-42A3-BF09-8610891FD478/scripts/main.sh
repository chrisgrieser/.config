#!/bin/zsh --no-rcs

cat << EOB
{
    "items": [
    	$("./scripts/settings.sh")
    	$([[ "${showGeneral}" -eq 1 ]] && "./scripts/general.sh")
    	$([[ "${showAccessibility}" -eq 1 ]] && "./scripts/accessibility.sh")
    	$([[ "${showPrivacySecurity}" -eq 1 ]] && "./scripts/privacySecurity.sh")
    ]}
EOB