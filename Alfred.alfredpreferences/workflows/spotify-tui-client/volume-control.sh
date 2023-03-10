#!/usr/bin/env zsh
# shellcheck disable=SC2154

currentDevice=$(spt playback --format=%d)
currentVolume=$(spt playback --format=%v)
if [[ "$*" == "up" ]] ; then
	newVolume=$((currentVolume + vol_increment))
else
	newVolume=$((currentVolume - vol_increment))
fi

spt playback --volume="$newVolume" --device="$currentDevice" &> /dev/null

# for notification
currentVolume=$(spt playback --format=%v)
echo -n "$currentVolume% 🔊"
