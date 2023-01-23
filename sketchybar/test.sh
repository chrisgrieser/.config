#!/usr/bin/env zsh

# dark colors
BG_COLOR="0xff333333"
FONT_COLOR="0xffffffff"

# light colors
BG_COLOR="0xffcdcdcd"
FONT_COLOR="0xff000000"

sketchybar --bar color="$BG_COLOR" \
	set drafts icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
	set sync-indicator icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
	set clock icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
	set covid-stats icon.color="$FONT_COLOR" label.color="$FONT_COLOR"
