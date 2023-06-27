#!/usr/bin/env zsh

page_no="$1"
# shellcheck disable=2154
open "highlights://$filename#page=$page_no"
