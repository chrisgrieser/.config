#!/usr/bin/env bash
# shellcheck disable=2154
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

cmd="$*"
result=$(bash -c "$(cat << EOF | ${cmd}
${selection}
EOF
)")

echo -n "$result"
