#!/usr/bin/env zsh
# shellcheck disable=2154
cd "${default_folder/#\~/$HOME}" || exit 1
[[ -z "$(ls)" ]] && echo -n "empty"
