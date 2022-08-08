#!/bin/zsh

PODCAST_LOCATION=~"/Library/Group Containers/243LU875E5.groups.com.apple.podcasts/Library/Cache/"
PODCAST_TARGET="/Volumes/OpenSwim/"

#-------------------------------------------------------------------------------

# in case mounting is lagging
i=1
while [[ ! -e "$PODCAST_TARGET" ]] && [[ $i -lt 20 ]]; do
	sleep 0.5
	i=$((i+1))
done
[[ -e "$PODCAST_TARGET" ]] || exit 1

# -n = do not overwrite existing file
cp -n "$PODCAST_LOCATION"/*.mp3 "$PODCAST_TARGET" || true
open "$PODCAST_TARGET"
