#!/usr/bin/env zsh
# shellcheck disable=SC2154

currentVolume=$(spt playback --format=%v)
if [[ "$*" == "up" ]] ; then
	newVolume=$((currentVolume + vol_increment))
else
	newVolume=$((currentVolume - vol_increment))
fi

spt playback --volume="$newVolume" &> /dev/null

# for notification
currentVolume=$(spt playback --format=%v)
echo -n "$currentVolume% 🔊"
