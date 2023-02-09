#!/usr/bin/env zsh
# shellcheck disable=2154
pass_path="$PASSWORD_STORE_DIR"
entry="$*"
[[ -z "$pass_path" ]] && pass_path="$HOME/.password-store"

open -R "$pass_path/$entry.gpg"
