#!/usr/bin/env zsh
# shellcheck disable=SC2086,SC2154
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

notification=$(spt playback --$1 --format="$format")

current_status="$(spt playback --status --format=%s)"
[[ "$current_status" != "⏸" ]] && echo -n "$notification"
