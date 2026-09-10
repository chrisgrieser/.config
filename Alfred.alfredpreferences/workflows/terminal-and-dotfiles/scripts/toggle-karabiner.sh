#!/usr/bin/env zsh
profile_1="Default profile"
profile_2="Disabled"
#───────────────────────────────────────────────────────────────────────────────

karabiner_cli="/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
current_profile=$("$karabiner_cli" --show-current-profile-name)
change_to=$([[ "$current_profile" == "$profile_1" ]] && echo "$profile_2" || echo "$profile_1")

emoji=$([[ "$change_to" == "$profile_1" ]] && echo "✅" || echo "📴")
msg=$("$karabiner_cli" --select-profile="$change_to")

if [[ -z "$msg" ]]; then # INFO on non-existing profile, still exits 0, thus check for empty
	echo "$emoji $change_to profile"
else
	echo "❌ $msg"
fi
