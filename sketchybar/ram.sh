#!/usr/bin/env zsh

memory_free=$(memory_pressure | tail -n1 | grep --only-matching '[0-9.]*')
memory_usage=$((100 - memory_free))

sketchybar --set "$NAME" label="$memory_usage%" drawing=true
