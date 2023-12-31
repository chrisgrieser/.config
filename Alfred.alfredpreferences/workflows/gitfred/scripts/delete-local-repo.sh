#!/usr/bin/env zsh

repo_path="$*"
rm -r "$repo_path" && echo -n "✅ Local repo deleted."
