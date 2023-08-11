#!/usr/bin/env zsh

image="$*"
width=$(sips --getProperty pixelWidth "$image" | tail -n1 | cut -d: -f2 | tr -d " ")

sips -Z $width "$image" --out "$image".iconset/icon_512x512.png
