#!/usr/bin/env zsh
# CONFIG the two profiles to toggle between
profile_1="Default"
profile_2="disabled"
#───────────────────────────────────────────────────────────────────────────────

karabiner_cli="/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
current_profile=$("$karabiner_cli" --show-current-profile-name)
change_to=$([[ "$current_profile" == "$profile_1" ]] && echo "$profile_2" || echo "$profile_1")

emoji=$([[ "$change_to" == "$profile_1" ]] && echo "✅" || echo "📴")
msg=$("$karabiner_cli" --select-profile="$change_to")
if [[ -z "$msg" ]]; then # INFO on non-existing profile, still exits 0
	echo "$emoji $change_to profile"
else
	echo "❌ $msg"
fi
