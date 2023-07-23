#!/usr/bin/env zsh

# INFO Browser app needs to be forced, since Twitter.app takes over twitter urls
# (BROWSER_APP from .zshenv)
open -a "$BROWSER_APP" "https://twitter.com/compose/tweet"
open "https://pkm.social/publish"
