#!/usr/bin/env zsh

location="/tmp/screenshots" # CONFIG
mkdir -p "$location"
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
screenshot_file="$location/Screenshot_$timestamp.png"
screencapture -ui "$screenshot_file" 
