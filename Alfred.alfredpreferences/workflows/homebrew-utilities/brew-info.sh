#!/usr/bin/env zsh
type=$(echo "$*" | cut -d' ' -f1)
name=$(echo "$*" | cut -d' ' -f2)

brew info "$type" "$name" 
