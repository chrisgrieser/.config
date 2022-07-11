#!/bin/zsh
KARABINER_CLI="/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

PROFILE_1=$($KARABINER_CLI --list-profile-names | sed -n 1p)
PROFILE_2=$($KARABINER_CLI --list-profile-names | sed -n 2p)

if [[ $($KARABINER_CLI --show-current-profile-name) == "$PROFILE_1" ]] ; then
	$KARABINER_CLI --select-profile "$PROFILE_2"
	MSG="$PROFILE_2"
else
	$KARABINER_CLI --select-profile "$PROFILE_1"
	MSG="$PROFILE_1"
fi
echo -n "Karabiner: $MSG"
