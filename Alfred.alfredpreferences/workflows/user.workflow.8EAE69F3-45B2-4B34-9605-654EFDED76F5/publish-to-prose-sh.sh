#!/bin/zsh

open -g "obsidian://advanced-uri?commandid=workspace%253Acopy-path"
sleep 0.1

scp "$(pbpaste)" prose.sh:/
