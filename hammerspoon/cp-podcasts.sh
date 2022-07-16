#!/bin/zsh
PODCAST_LOCATION=~"/Library/Group Containers/243LU875E5.groups.com.apple.podcasts/Library/Cache/"
cp -n "$PODCAST_LOCATION"/*.mp3 "/Volumes/OpenSwim/"
open "/Volumes/OpenSwim/"
