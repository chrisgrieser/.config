#!/usr/bin/env zsh

entry="$*"
pass delete "$entry" 2>&1 
echo "$entry"
